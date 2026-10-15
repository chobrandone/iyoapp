// In-memory backend for builds without a Supabase project. It follows the same rules as the
// server (state machine, PIN lock, placeholder fare formula) and plays the other app:
//   * rider app: a simulated driver accepts, drives to the pickup, starts and finishes the trip;
//   * driver app: simulated riders send ride requests while the driver is online.
// Nothing leaves the device. Demo SMS code: 123456.
import 'dart:async';
import 'dart:math' as math;

import '../format/currency.dart';
import '../rides/ride_status.dart';
import '../supabase/db_enums.dart';
import 'models.dart';
import 'safety_rental_models.dart';
import 'repositories.dart';

/// Timings of the simulation; tests shrink them.
class DemoTiming {
  const DemoTiming({
    this.matching = const Duration(seconds: 4),
    this.tick = const Duration(seconds: 1),
    this.approachTicks = 18,
    this.tripTicks = 24,
    this.waitAtPickup = const Duration(seconds: 6),
    this.offerEvery = const Duration(seconds: 8),
    this.offerWindow = const Duration(seconds: 15),
    this.review = const Duration(seconds: 5),
  });

  /// Rider: time before a driver accepts.
  final Duration matching;
  final Duration tick;

  /// Rider: driver position updates until the pickup / destination.
  final int approachTicks;
  final int tripTicks;

  /// Rider: how long the simulated driver waits before entering the PIN.
  final Duration waitAtPickup;

  /// Driver: delay before the next simulated request, and its accept window.
  final Duration offerEvery;
  final Duration offerWindow;

  /// Driver: simulated document review after submitting the application.
  final Duration review;
}

const demoOtpCode = '123456';
const demoPin = '4826';

/// Douala places used for search and simulated trips.
const List<Place> doualaPlaces = [
  Place(
    name: 'Gare de Bessengué',
    address: 'Bessengué, Douala',
    location: GeoPoint(4.0560, 9.7280),
    placeId: 'demo-bessengue',
  ),
  Place(
    name: 'Marché Sandaga',
    address: 'Boulevard de la Liberté, Akwa, Douala',
    location: GeoPoint(4.0490, 9.7020),
    placeId: 'demo-sandaga',
  ),
  Place(
    name: 'Aéroport international de Douala',
    address: 'Hall des arrivées, Douala',
    location: GeoPoint(4.0061, 9.7195),
    placeId: 'demo-dla',
  ),
  Place(
    name: 'Rue Njo-Njo',
    address: 'Bonapriso, Douala',
    location: GeoPoint(4.0310, 9.6920),
    placeId: 'demo-njonjo',
  ),
  Place(
    name: '12 Rue Joss',
    address: 'Akwa, Douala',
    location: GeoPoint(4.0469, 9.6953),
    placeId: 'demo-joss',
  ),
  Place(
    name: 'Carrefour Bonamoussadi',
    address: 'Bonamoussadi, Douala',
    location: GeoPoint(4.0940, 9.7400),
    placeId: 'demo-bonamoussadi',
  ),
  Place(
    name: 'Douala Grand Mall',
    address: 'Bonamoussadi, Douala',
    location: GeoPoint(4.0870, 9.7440),
    placeId: 'demo-mall',
  ),
  Place(
    name: 'Hôpital Laquintinie',
    address: 'Akwa, Douala',
    location: GeoPoint(4.0480, 9.7090),
    placeId: 'demo-laquintinie',
  ),
  Place(
    name: 'Stade de la Réunification',
    address: 'Bépanda, Douala',
    location: GeoPoint(4.0650, 9.7290),
    placeId: 'demo-stade',
  ),
  Place(
    name: 'Université de Douala',
    address: 'Ndogbong, Douala',
    location: GeoPoint(4.0590, 9.7400),
    placeId: 'demo-univ',
  ),
  Place(
    name: 'Rond-point Deïdo',
    address: 'Deïdo, Douala',
    location: GeoPoint(4.0620, 9.7080),
    placeId: 'demo-deido',
  ),
  Place(
    name: 'Makepe Missoké',
    address: 'Makepe, Douala',
    location: GeoPoint(4.0800, 9.7530),
    placeId: 'demo-makepe',
  ),
];

const _categories = [
  (code: 'standard', en: 'Standard', fr: 'Standard', seats: 4, multiplier: 1.0),
  (code: 'comfort', en: 'Comfort', fr: 'Confort', seats: 4, multiplier: 1.35),
  (code: 'xl', en: 'XL', fr: 'XL', seats: 6, multiplier: 1.7),
];

const _demoDriver = Counterpart(
  id: 'demo-driver',
  firstName: 'Jean-Paul',
  fullName: 'Jean-Paul Mbarga',
  phone: '+237677889900',
  rating: 4.9,
  ratingCount: 1248,
  vehicle: VehicleInfo(
    make: 'Toyota',
    model: 'Corolla',
    color: 'Blanc',
    plate: 'LT 123 AB',
    categoryCode: 'standard',
    year: 2018,
  ),
);

const _demoRiders = [
  Counterpart(
    id: 'demo-rider-1',
    firstName: 'Aïcha',
    phone: '+237671234567',
    rating: 4.8,
    ratingCount: 37,
  ),
  Counterpart(
    id: 'demo-rider-2',
    firstName: 'Christian',
    phone: '+237699112233',
    rating: 4.6,
    ratingCount: 12,
  ),
  Counterpart(
    id: 'demo-rider-3',
    firstName: 'Mireille',
    phone: '+237655443322',
    rating: 4.9,
    ratingCount: 58,
  ),
];

int _haversine(GeoPoint a, GeoPoint b) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.lat - a.lat), dLng = rad(b.lng - a.lng);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLng / 2), 2);
  return (2 * r * math.asin(math.sqrt(h))).round();
}

GeoPoint _lerp(GeoPoint a, GeoPoint b, double t) =>
    GeoPoint(a.lat + (b.lat - a.lat) * t, a.lng + (b.lng - a.lng) * t);

double _bearing(GeoPoint a, GeoPoint b) {
  final deg = math.atan2(b.lng - a.lng, b.lat - a.lat) * 180 / math.pi;
  return (deg + 360) % 360;
}

/// Road distance ≈ 1.3 × straight line; 22 km/h average in Douala traffic.
RouteInfo demoRoute(GeoPoint a, GeoPoint b) {
  final meters = (_haversine(a, b) * 1.3).round();
  return RouteInfo(distanceMeters: meters, durationSeconds: (meters / (22000 / 3600)).round());
}

/// Same formula and PLACEHOLDER values as public.compute_fare / fare_config (Douala).
int demoFare(int meters, int seconds, double multiplier) {
  final metered = 500 + 150 * meters / 1000 + 25 * seconds / 60;
  return roundToNearest50((metered < 1000 ? 1000 : metered) * multiplier);
}

/// Demo rental fleet (same cars and PLACEHOLDER prices as supabase/seed.sql).
const List<RentalVehicle> demoRentalFleet = [
  RentalVehicle(
    id: 'demo-car-corolla',
    cityCode: 'douala',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    category: 'sedan',
    transmission: TransmissionType.automatic,
    seats: 5,
    fuelType: FuelType.petrol,
    plate: 'LT 211 RB',
    color: 'Blanc',
    dailyRate: 25000,
    depositAmount: 100000,
    kmPerDay: 200,
    extraKmRate: 150,
    features: ['ac', 'bluetooth'],
    airportPickupAvailable: true,
  ),
  RentalVehicle(
    id: 'demo-car-rav4',
    cityCode: 'douala',
    make: 'Toyota',
    model: 'RAV4',
    year: 2021,
    category: 'suv',
    transmission: TransmissionType.automatic,
    seats: 5,
    fuelType: FuelType.petrol,
    plate: 'LT 210 RA',
    color: 'Gris',
    dailyRate: 35000,
    depositAmount: 150000,
    kmPerDay: 200,
    extraKmRate: 200,
    features: ['ac', 'bluetooth', 'reverse_camera'],
    airportPickupAvailable: true,
  ),
  RentalVehicle(
    id: 'demo-car-tucson',
    cityCode: 'douala',
    make: 'Hyundai',
    model: 'Tucson',
    year: 2022,
    category: 'suv',
    transmission: TransmissionType.automatic,
    seats: 5,
    fuelType: FuelType.diesel,
    plate: 'LT 212 RC',
    color: 'Noir',
    dailyRate: 40000,
    depositAmount: 150000,
    kmPerDay: 200,
    extraKmRate: 200,
    features: ['ac', 'carplay'],
    airportPickupAvailable: true,
  ),
  RentalVehicle(
    id: 'demo-car-prado',
    cityCode: 'douala',
    make: 'Toyota',
    model: 'Land Cruiser Prado',
    year: 2019,
    category: 'suv',
    transmission: TransmissionType.automatic,
    seats: 7,
    fuelType: FuelType.diesel,
    plate: 'LT 213 RD',
    color: 'Blanc',
    dailyRate: 60000,
    depositAmount: 250000,
    kmPerDay: 250,
    extraKmRate: 250,
    features: ['ac', '4x4'],
    airportPickupAvailable: true,
  ),
  RentalVehicle(
    id: 'demo-car-swift',
    cityCode: 'yaounde',
    make: 'Suzuki',
    model: 'Swift',
    year: 2021,
    category: 'economy',
    transmission: TransmissionType.manual,
    seats: 5,
    fuelType: FuelType.petrol,
    plate: 'CE 101 RA',
    color: 'Rouge',
    dailyRate: 20000,
    depositAmount: 80000,
    kmPerDay: 150,
    extraKmRate: 150,
    features: ['ac'],
  ),
  RentalVehicle(
    id: 'demo-car-hilux',
    cityCode: 'yaounde',
    make: 'Toyota',
    model: 'Hilux',
    year: 2020,
    category: 'pickup',
    transmission: TransmissionType.manual,
    seats: 5,
    fuelType: FuelType.diesel,
    plate: 'CE 102 RB',
    color: 'Blanc',
    dailyRate: 45000,
    depositAmount: 200000,
    kmPerDay: 200,
    extraKmRate: 250,
    features: ['ac', '4x4'],
    airportPickupAvailable: true,
  ),
];

/// PLACEHOLDER airport pickup fees (airports table).
const List<Airport> demoAirports = [
  Airport(
    code: 'DLA',
    name: 'Douala International Airport',
    cityCode: 'douala',
    pickupFee: 5000,
    terminals: ['Arrivals'],
  ),
  Airport(
    code: 'NSI',
    name: 'Yaoundé Nsimalen International Airport',
    cityCode: 'yaounde',
    pickupFee: 5000,
    terminals: ['Arrivals'],
  ),
];

const _shareBase = String.fromEnvironment(
  'TRIP_SHARE_BASE_URL',
  defaultValue: 'https://iyodriver.cm/trip',
);

class DemoBackend implements IyoBackend {
  DemoBackend({this.role = AppRole.rider, this.timing = const DemoTiming(), math.Random? random})
    : _random = random ?? math.Random();

  final AppRole role;

  @override
  bool get isDemo => true;
  final DemoTiming timing;
  final math.Random _random;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  UserProfile? _profile;
  final _profileCtrl = StreamController<UserProfile?>.broadcast();
  final Map<String, UserProfile> _accounts = {};

  @override
  UserProfile? get currentProfile => _profile;

  @override
  Stream<UserProfile?> watchProfile() async* {
    yield _profile;
    yield* _profileCtrl.stream;
  }

  @override
  Future<void> sendOtp(String phoneE164) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserProfile> verifyOtp(String phoneE164, String code, {SignUpDetails? signUp}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (code != demoOtpCode) throw const BackendException('otp_invalid');
    final existing = _accounts[phoneE164];
    final profile =
        existing ??
        UserProfile(
          id: 'demo-${phoneE164.substring(phoneE164.length - 4)}',
          role: signUp?.role ?? role,
          fullName:
              signUp?.fullName ??
              (role == AppRole.driver ? 'Chauffeur iyodriver' : 'Passager iyodriver'),
          phone: phoneE164,
          email: signUp?.email,
          language: signUp?.language ?? AppLanguage.fr,
        );
    if (profile.role != role) throw const BackendException('wrong_role');
    _accounts[phoneE164] = profile;
    _profile = profile;
    _profileCtrl.add(profile);
    return profile;
  }

  @override
  Future<void> signOut() async {
    await setOnline(false).catchError((_) {});
    _profile = null;
    _profileCtrl.add(null);
  }

  // ---------------------------------------------------------------------------
  // Places
  // ---------------------------------------------------------------------------

  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('ç', 'c');

  @override
  Future<List<Place>> autocomplete(
    String input, {
    required String sessionToken,
    GeoPoint? near,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final q = _fold(input.trim());
    if (q.length < 2) return const [];
    return [
      for (final p in doualaPlaces)
        if (_fold('${p.name} ${p.address}').contains(q))
          Place(name: p.name, address: p.address, placeId: p.placeId),
    ];
  }

  @override
  Future<Place> details(Place suggestion, {required String sessionToken}) async => doualaPlaces
      .firstWhere((p) => p.placeId == suggestion.placeId, orElse: () => doualaPlaces.first);

  @override
  Future<List<Place>> savedPlaces() async => [doualaPlaces[3], doualaPlaces[4]];

  // ---------------------------------------------------------------------------
  // Rides (shared state)
  // ---------------------------------------------------------------------------

  final Map<String, Ride> _rides = {};
  final Map<String, StreamController<Ride>> _rideCtrls = {};
  final Map<String, List<ChatEntry>> _chats = {};
  final Map<String, StreamController<List<ChatEntry>>> _chatCtrls = {};
  final Map<String, Counterpart> _riderOf = {};
  final List<Timer> _timers = [];
  int _seq = 0;

  String _id(String prefix) => '$prefix-${DateTime.now().millisecondsSinceEpoch}-${_seq++}';

  StreamController<Ride> _rideCtrl(String id) =>
      _rideCtrls.putIfAbsent(id, () => StreamController<Ride>.broadcast());

  Ride _emit(Ride ride) {
    _rides[ride.id] = ride;
    _rideCtrl(ride.id).add(ride);
    return ride;
  }

  Ride _transition(String rideId, RideStatus to, RideActor actor, {String? reason}) {
    final ride = _rides[rideId];
    if (ride == null) throw const BackendException('ride_not_found');
    if (!canTransition(ride.status, to, actor)) {
      throw BackendException('invalid_transition', '${ride.status.value} -> ${to.value}');
    }
    final now = DateTime.now();
    return _emit(
      ride.copyWith(
        status: to,
        cancelReason: reason,
        startedAt: to == RideStatus.inProgress ? now : null,
        completedAt: to == RideStatus.completed ? now : null,
      ),
    );
  }

  Timer _after(Duration d, void Function() f) {
    final t = Timer(d, f);
    _timers.add(t);
    return t;
  }

  Stream<Ride> _watch(String rideId) async* {
    final ride = _rides[rideId];
    if (ride == null) throw const BackendException('ride_not_found');
    yield ride;
    yield* _rideCtrl(rideId).stream;
  }

  // ---------------------------------------------------------------------------
  // Rider
  // ---------------------------------------------------------------------------

  final Map<String, (Place, Place, RouteInfo)> _quotes = {};

  @override
  Future<FareEstimate> estimateFares(Place pickup, Place dropoff) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final a = pickup.location, b = dropoff.location;
    if (a == null || b == null) throw const BackendException('invalid_request');
    final route = demoRoute(a, b);
    final expires = DateTime.now().add(const Duration(minutes: 10));
    final options = [
      for (final c in _categories)
        FareOption(
          quoteId: _id('quote'),
          categoryCode: c.code,
          nameEn: c.en,
          nameFr: c.fr,
          seats: c.seats,
          fareAmount: demoFare(route.distanceMeters, route.durationSeconds, c.multiplier),
          expiresAt: expires,
          etaMinutes: c.code == 'xl' ? null : 3 + _random.nextInt(4),
          isPlaceholder: true,
        ),
    ];
    for (final o in options) {
      _quotes[o.quoteId] = (pickup, dropoff, route);
    }
    return FareEstimate(route: route, options: options);
  }

  @override
  Future<Ride?> openRide() async => _rides.values.where((r) => r.isActive).firstOrNull;

  @override
  Future<Ride> requestRide(FareOption option, PaymentMethodType method) async {
    final q = _quotes.remove(option.quoteId);
    if (q == null) throw const BackendException('quote_not_found');
    if (option.expiresAt.isBefore(DateTime.now())) throw const BackendException('quote_expired');
    if (await openRide() != null) throw const BackendException('rider_has_open_ride');
    final (pickup, dropoff, route) = q;
    final ride = _emit(
      Ride(
        id: _id('ride'),
        status: RideStatus.requested,
        pickup: pickup,
        dropoff: dropoff,
        categoryCode: option.categoryCode,
        fareAmount: option.fareAmount,
        paymentMethod: method,
        distanceMeters: route.distanceMeters,
        durationSeconds: route.durationSeconds,
        requestedAt: DateTime.now(),
        pin: demoPin,
      ),
    );
    _after(
      const Duration(milliseconds: 300),
      () => _transition(ride.id, RideStatus.searching, RideActor.server),
    );
    _after(timing.matching, () => _simulateMatch(ride.id));
    return ride;
  }

  void _simulateMatch(String rideId) {
    final ride = _rides[rideId];
    if (ride == null || ride.status != RideStatus.searching) return;
    // Mirrors the seed data: no XL drivers in Douala.
    if (ride.categoryCode == 'xl') {
      _transition(rideId, RideStatus.noDriversFound, RideActor.server);
      return;
    }
    final pickup = ride.pickup.location!;
    final start = GeoPoint(pickup.lat + 0.008, pickup.lng + 0.006);
    _emit(
      _transition(rideId, RideStatus.driverAssigned, RideActor.driver).copyWith(
        driverLocation: start,
        driverHeading: _bearing(start, pickup),
        etaSeconds: timing.approachTicks * 10,
      ),
    );
    _after(timing.tick, () {
      if (_rides[rideId]?.status == RideStatus.driverAssigned) {
        _transition(rideId, RideStatus.driverArriving, RideActor.driver);
      }
    });
    _drive(
      rideId,
      start,
      pickup,
      timing.approachTicks,
      onArrive: () {
        if (_rides[rideId]?.status != RideStatus.driverArriving) return;
        _transition(rideId, RideStatus.driverArrived, RideActor.driver);
        _after(timing.waitAtPickup, () {
          if (_rides[rideId]?.status != RideStatus.driverArrived) return;
          _transition(rideId, RideStatus.inProgress, RideActor.driver);
          _drive(
            rideId,
            pickup,
            ride.dropoff.location!,
            timing.tripTicks,
            onArrive: () {
              if (_rides[rideId]?.status == RideStatus.inProgress) {
                _transition(rideId, RideStatus.completed, RideActor.driver);
              }
            },
          );
        });
      },
    );
  }

  /// Moves the simulated driver from [a] to [b] in [ticks] steps, then calls [onArrive].
  void _drive(
    String rideId,
    GeoPoint a,
    GeoPoint b,
    int ticks, {
    required void Function() onArrive,
  }) {
    var step = 0;
    final heading = _bearing(a, b);
    final timer = Timer.periodic(timing.tick, (t) {
      final ride = _rides[rideId];
      if (ride == null || !ride.isActive) {
        t.cancel();
        return;
      }
      step++;
      final left = ticks - step;
      _emit(
        ride.copyWith(
          driverLocation: _lerp(a, b, step / ticks),
          driverHeading: heading,
          etaSeconds: left * 10,
        ),
      );
      if (step >= ticks) {
        t.cancel();
        onArrive();
      }
    });
    _timers.add(timer);
  }

  @override
  Stream<Ride> watchRide(String rideId) => _watch(rideId);

  @override
  Future<Counterpart?> driverFor(String rideId) async {
    final ride = _rides[rideId];
    if (ride == null) throw const BackendException('ride_not_found');
    const assigned = {
      RideStatus.driverAssigned,
      RideStatus.driverArriving,
      RideStatus.driverArrived,
      RideStatus.inProgress,
      RideStatus.completed,
      RideStatus.cancelledByDriver,
    };
    return assigned.contains(ride.status) ? _demoDriver : null;
  }

  @override
  Future<Ride> cancel(String rideId, {String? reason}) async =>
      _transition(rideId, RideStatus.cancelledByRider, RideActor.rider, reason: reason);

  @override
  Future<void> rate(String rideId, int stars, {int tip = 0, String? comment}) async {
    final ride = _rides[rideId];
    if (ride == null || ride.status != RideStatus.completed) {
      throw const BackendException('ride_not_rateable');
    }
  }

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------

  StreamController<List<ChatEntry>> _chatCtrl(String id) =>
      _chatCtrls.putIfAbsent(id, () => StreamController<List<ChatEntry>>.broadcast());

  @override
  Stream<List<ChatEntry>> watchMessages(String rideId) async* {
    yield List.unmodifiable(_chats[rideId] ?? const <ChatEntry>[]);
    yield* _chatCtrl(rideId).stream;
  }

  void _addMessage(String rideId, String body, String senderId) {
    final list = _chats.putIfAbsent(rideId, () => []);
    list.add(ChatEntry(id: _id('msg'), body: body, senderId: senderId, sentAt: DateTime.now()));
    _chatCtrl(rideId).add(List.unmodifiable(list));
  }

  @override
  Future<void> send(String rideId, String body) async {
    final me = _profile?.id ?? 'me';
    final firstMessage = !(_chats[rideId]?.any((m) => m.senderId == me) ?? false);
    _addMessage(rideId, body, me);
    if (firstMessage) {
      // The simulated other party answers once.
      final other = role == AppRole.rider ? _demoDriver.id : (_riderOf[rideId]?.id ?? 'demo-rider');
      final reply =
          role == AppRole.rider ? "D'accord, j'arrive dans un instant." : 'Merci, je vous attends.';
      _after(const Duration(seconds: 2), () => _addMessage(rideId, reply, other));
    }
  }

  // ---------------------------------------------------------------------------
  // Driver
  // ---------------------------------------------------------------------------

  DriverAccount _account = const DriverAccount(status: VerificationStatus.pending);
  final _accountCtrl = StreamController<DriverAccount>.broadcast();
  bool _online = false;
  final _onlineCtrl = StreamController<bool>.broadcast();
  final _offerCtrl = StreamController<RideOffer?>.broadcast();
  RideOffer? _offer;
  Timer? _offerTimer;
  GeoPoint _driverAt = const GeoPoint(4.0483, 9.7008);
  final List<CompletedTrip> _trips = [];
  DateTime? _onlineSince;
  int _onlineSeconds = 0;
  int _pinAttempts = 0;

  /// Documents the application needs (app_config.required_driver_documents).
  static const requiredDocuments = DocumentType.values;

  void _setAccount(DriverAccount a) {
    _account = a;
    _accountCtrl.add(a);
    if (a.status == VerificationStatus.approved) _seedDriverRental();
  }

  @override
  Stream<DriverAccount> watchAccount() async* {
    yield _account;
    yield* _accountCtrl.stream;
  }

  @override
  Future<void> saveIdentity({
    required String cityCode,
    required String licenceNumber,
    required String nationalIdNumber,
    required VehicleInfo vehicle,
  }) async {
    if (!const [
      VerificationStatus.pending,
      VerificationStatus.actionNeeded,
    ].contains(_account.status)) {
      throw const BackendException('driver_identity_locked');
    }
    _setAccount(
      _account.copyWith(
        cityCode: cityCode,
        licenceNumber: licenceNumber,
        nationalIdNumber: nationalIdNumber,
        vehicle: vehicle,
      ),
    );
  }

  @override
  Future<void> uploadDocument(
    DocumentType type,
    String localPath, {
    void Function(double)? onProgress,
  }) async {
    for (var i = 1; i <= 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      onProgress?.call(i / 5);
    }
    _setAccount(
      _account.copyWith(
        documents: {
          ..._account.documents,
          type: DriverDocument(type: type, status: ReviewStatus.pending, localPath: localPath),
        },
      ),
    );
  }

  @override
  Future<void> submitApplication() async {
    if (!_account.identityComplete || _account.vehicle == null) {
      throw const BackendException('identity_incomplete');
    }
    final missing = requiredDocuments.where((t) => !_account.documents.containsKey(t));
    if (missing.isNotEmpty) {
      throw BackendException('documents_missing', missing.map((t) => t.value).join(','));
    }
    _setAccount(_account.copyWith(status: VerificationStatus.underReview));
    // Simulated review by the iyodriver team.
    _after(timing.review, () {
      _setAccount(
        _account.copyWith(
          status: VerificationStatus.approved,
          documents: {
            for (final e in _account.documents.entries)
              e.key: DriverDocument(
                type: e.key,
                status: ReviewStatus.approved,
                localPath: e.value.localPath,
              ),
          },
        ),
      );
    });
  }

  @override
  Stream<bool> watchOnline() async* {
    yield _online;
    yield* _onlineCtrl.stream;
  }

  @override
  Future<void> setOnline(bool online, {GeoPoint? at}) async {
    if (online == _online) return;
    if (online) {
      if (_account.status != VerificationStatus.approved) {
        throw const BackendException('driver_not_approved');
      }
      if (at == null) throw const BackendException('location_required');
      _driverAt = at;
      _onlineSince = DateTime.now();
      _scheduleOffer();
    } else {
      if (_activeDriverRide != null) throw const BackendException('finish_active_ride_first');
      _offerTimer?.cancel();
      _offer = null;
      _offerCtrl.add(null);
      if (_onlineSince != null) {
        _onlineSeconds += DateTime.now().difference(_onlineSince!).inSeconds;
      }
      _onlineSince = null;
    }
    _online = online;
    _onlineCtrl.add(online);
  }

  @override
  Future<void> updateLocation(GeoPoint at, {double? heading, double? speedMps}) async {
    if (!_online) throw const BackendException('driver_offline');
    _driverAt = at;
    final ride = _activeDriverRide;
    if (ride != null) _emit(ride.copyWith(driverLocation: at, driverHeading: heading));
  }

  Ride? get _activeDriverRide =>
      _rides.values.where((r) => r.isActive && _riderOf.containsKey(r.id)).firstOrNull;

  void _scheduleOffer() {
    _offerTimer?.cancel();
    _offerTimer = Timer(timing.offerEvery, () {
      if (!_online || _activeDriverRide != null) return;
      final pickup = GeoPoint(
        _driverAt.lat + 0.004 + _random.nextDouble() * 0.004,
        _driverAt.lng + 0.003,
      );
      final dropoff = doualaPlaces[_random.nextInt(doualaPlaces.length)];
      final route = demoRoute(pickup, dropoff.location!);
      final rider = _demoRiders[_random.nextInt(_demoRiders.length)];
      final ride = Ride(
        id: _id('ride'),
        status: RideStatus.searching,
        pickup: Place(name: 'Rue Joss', address: 'Akwa, Douala', location: pickup),
        dropoff: dropoff,
        categoryCode: 'standard',
        fareAmount: demoFare(route.distanceMeters, route.durationSeconds, 1),
        paymentMethod: PaymentMethodType.mtnMomo,
        distanceMeters: route.distanceMeters,
        durationSeconds: route.durationSeconds,
        requestedAt: DateTime.now(),
      );
      _rides[ride.id] = ride;
      _offer = RideOffer(
        id: _id('offer'),
        ride: ride,
        rider: rider,
        expiresAt: DateTime.now().add(timing.offerWindow),
        pickupDistanceMeters: _haversine(_driverAt, pickup),
        pickupEtaSeconds: (_haversine(_driverAt, pickup) * 1.3 / (22000 / 3600)).round(),
      );
      _offerCtrl.add(_offer);
      // Expire it if nobody answers; then offer the next one.
      _offerTimer = Timer(timing.offerWindow, () {
        if (_offer?.ride.id == ride.id) {
          _offer = null;
          _rides.remove(ride.id);
          _offerCtrl.add(null);
          _scheduleOffer();
        }
      });
    });
  }

  @override
  Stream<RideOffer?> watchOffers() async* {
    yield _offer;
    yield* _offerCtrl.stream;
  }

  @override
  Future<Ride?> respond(RideOffer offer, {required bool accept}) async {
    if (_offer?.id != offer.id) throw const BackendException('offer_not_pending');
    if (offer.expiresAt.isBefore(DateTime.now())) throw const BackendException('offer_expired');
    _offerTimer?.cancel();
    _offer = null;
    _offerCtrl.add(null);
    if (!accept) {
      _rides.remove(offer.ride.id);
      _scheduleOffer();
      return null;
    }
    _riderOf[offer.ride.id] = offer.rider;
    _pinAttempts = 0;
    return _emit(offer.ride.copyWith(status: RideStatus.driverAssigned, driverLocation: _driverAt));
  }

  @override
  Future<Counterpart?> riderFor(String rideId) async {
    final rider = _riderOf[rideId];
    final ride = _rides[rideId];
    if (rider == null || ride == null) return null;
    final started = ride.status == RideStatus.inProgress || ride.status == RideStatus.completed;
    // Same visibility rule as get_ride_counterpart(): full name once the trip starts.
    return Counterpart(
      id: rider.id,
      firstName: rider.firstName,
      fullName: started ? '${rider.firstName} ${_surnames[rider.id] ?? ''}'.trim() : null,
      phone: ride.isActive ? rider.phone : null,
      rating: rider.rating,
      ratingCount: rider.ratingCount,
    );
  }

  static const _surnames = {
    'demo-rider-1': 'Ngo Mbappe',
    'demo-rider-2': 'Fotso',
    'demo-rider-3': 'Tchoumi',
  };

  @override
  Future<Ride> updateStatus(String rideId, RideStatus status, {String? reason}) async {
    if (status == RideStatus.inProgress) throw const BackendException('status_not_allowed_here');
    final ride = _transition(rideId, status, RideActor.driver, reason: reason);
    if (status == RideStatus.completed) {
      _trips.insert(
        0,
        CompletedTrip(
          rideId: ride.id,
          dropoffName: ride.dropoff.name,
          fareAmount: ride.fareAmount,
          earnings: ride.driverEarnings,
          completedAt: DateTime.now(),
        ),
      );
    }
    if (!ride.isActive && _online) _scheduleOffer();
    return ride;
  }

  @override
  Future<PinCheck> verifyPin(String rideId, String pin) async {
    final ride = _rides[rideId];
    if (ride == null) throw const BackendException('ride_not_found');
    if (ride.status != RideStatus.driverArrived) throw const BackendException('driver_not_arrived');
    if (_pinAttempts >= 5) return const PinCheck(ok: false, locked: true, attemptsLeft: 0);
    if (pin == demoPin) {
      _transition(rideId, RideStatus.inProgress, RideActor.driver);
      return PinCheck(ok: true, locked: false, attemptsLeft: 5 - _pinAttempts);
    }
    _pinAttempts++;
    return PinCheck(ok: false, locked: _pinAttempts >= 5, attemptsLeft: 5 - _pinAttempts);
  }

  @override
  Future<void> rateRider(String rideId, int stars) async {}

  @override
  Future<DriverDaySummary> today() async {
    final now = DateTime.now();
    final todays = _trips.where((t) => t.completedAt.day == now.day);
    final live = _onlineSince == null ? 0 : now.difference(_onlineSince!).inSeconds;
    return DriverDaySummary(
      earnings: todays.fold(0, (s, t) => s + t.earnings),
      trips: todays.length,
      onlineSeconds: _onlineSeconds + live,
    );
  }

  @override
  Future<List<CompletedTrip>> recentTrips() async => List.unmodifiable(_trips);

  // ---------------------------------------------------------------------------
  // Safety
  // ---------------------------------------------------------------------------

  final List<TrustedContact> _contacts = [];

  @override
  Future<List<TrustedContact>> trustedContacts() async => List.unmodifiable(_contacts);

  @override
  Future<TrustedContact> addTrustedContact({
    required String name,
    required String phoneE164,
    String? relationship,
  }) async {
    if (_contacts.length >= 5) throw const BackendException('trusted_contacts_limit_reached');
    if (_contacts.any((c) => c.phone == phoneE164)) {
      throw const BackendException('invalid_request', 'duplicate');
    }
    final c = TrustedContact(
      id: _id('contact'),
      name: name,
      phone: phoneE164,
      relationship: relationship,
    );
    _contacts.add(c);
    return c;
  }

  @override
  Future<void> removeTrustedContact(String id) async => _contacts.removeWhere((c) => c.id == id);

  @override
  Future<void> setNotifyOnAlert(String id, {required bool notify}) async {
    final i = _contacts.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _contacts[i];
    _contacts[i] = TrustedContact(
      id: c.id,
      name: c.name,
      phone: c.phone,
      relationship: c.relationship,
      notifyOnAlert: notify,
    );
  }

  @override
  Future<List<EmergencyNumber>> emergencyNumbers() async => defaultEmergencyNumbers;

  @override
  Future<SafetyAlert> raiseAlert({
    String? rideId,
    GeoPoint? at,
    String? reason,
    String? note,
  }) async {
    if (role != AppRole.rider) throw const BackendException('wrong_role');
    return SafetyAlert(id: _id('alert'), createdAt: DateTime.now(), rideId: rideId);
  }

  @override
  Future<int> notifyTrustedContacts(String alertId) async =>
      _contacts.where((c) => c.notifyOnAlert).length; // demo: nothing is sent

  @override
  Future<TripShare> shareTrip(String rideId) async {
    final token = _id('share').hashCode.toRadixString(16).padLeft(8, '0') * 4;
    return TripShare(
      token: token,
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      url: '$_shareBase?t=$token',
    );
  }

  @override
  Future<IncidentReport> reportIncident({
    required String category,
    String? description,
    String? rideId,
    String? rentalBookingId,
    GeoPoint? at,
    bool urgent = false,
  }) async {
    if (role != AppRole.driver) throw const BackendException('wrong_role');
    return IncidentReport(id: _id('incident'), createdAt: DateTime.now(), category: category);
  }

  // ---------------------------------------------------------------------------
  // Rentals
  // ---------------------------------------------------------------------------

  final Map<String, RentalBooking> _rentals = {};
  final _rentalsCtrl = StreamController<void>.broadcast();

  void _saveRental(RentalBooking b) {
    _rentals[b.id] = b;
    _rentalsCtrl.add(null);
  }

  Stream<T> _rentalStream<T>(T Function() read) async* {
    yield read();
    await for (final _ in _rentalsCtrl.stream) {
      yield read();
    }
  }

  @override
  Future<List<RentalVehicle>> rentalVehicles(String cityCode) async =>
      demoRentalFleet.where((v) => v.cityCode == cityCode).toList();

  @override
  Future<List<Airport>> airports() async => demoAirports;

  @override
  Future<RentalBooking> bookRental(RentalRequest r) async {
    if (role != AppRole.rider) throw const BackendException('wrong_role');
    if (r.endsAt.isBefore(r.startsAt) || r.startsAt.isBefore(DateTime.now())) {
      throw const BackendException('invalid_rental_period');
    }
    if (r.pickupType == RentalPickupType.airport &&
        (!r.vehicle.airportPickupAvailable || !isValidFlightNumber(r.flightNumber ?? ''))) {
      throw const BackendException('airport_pickup_unavailable');
    }
    final overlap = _rentals.values.any(
      (b) =>
          b.vehicle.id == r.vehicle.id &&
          b.status != RentalBookingStatus.cancelled &&
          b.startsAt.isBefore(r.endsAt) &&
          r.startsAt.isBefore(b.endsAt),
    );
    if (overlap) throw const BackendException('vehicle_unavailable_for_dates');
    final booking = RentalBooking(
      id: _id('rental'),
      reference: 'RN-${1000 + _random.nextInt(9000)}',
      vehicle: r.vehicle,
      status:
          r.paymentMethod == PaymentMethodType.cash
              ? RentalBookingStatus.confirmed
              : RentalBookingStatus.pendingPayment,
      startsAt: r.startsAt,
      endsAt: r.endsAt,
      pickupType: r.pickupType,
      days: r.days,
      dailyRate: r.vehicle.dailyRate,
      rentalAmount: r.rentalAmount,
      airportFee: r.airportFee,
      depositAmount: r.vehicle.depositAmount,
      totalAmount: r.total,
      kmAllowance: r.kmAllowance,
      paymentMethod: r.paymentMethod,
      pickupAddress: r.pickupType == RentalPickupType.airport ? r.airport?.name : r.pickupAddress,
      airportCode: r.airport?.code,
      terminal: r.terminal,
      flightNumber: r.flightNumber?.toUpperCase().replaceAll(' ', ''),
      flightArrivalAt: r.flightArrivalAt,
    );
    _saveRental(booking);
    // Simulated: mobile money approved, then the team assigns a driver who hands the car over.
    _after(timing.matching, () {
      final b = _rentals[booking.id];
      if (b == null || b.status == RentalBookingStatus.cancelled) return;
      _saveRental(b.copyWith(status: RentalBookingStatus.confirmed));
      _after(timing.matching, () {
        final c = _rentals[booking.id];
        if (c == null || c.status != RentalBookingStatus.confirmed) return;
        _saveRental(
          c.copyWith(status: RentalBookingStatus.driverAssigned, assignedDriverId: _demoDriver.id),
        );
        _after(timing.matching, () {
          final d = _rentals[booking.id];
          if (d == null || d.status != RentalBookingStatus.driverAssigned) return;
          _saveRental(d.copyWith(handover: _demoInspection(InspectionType.handover, 8, 41200)));
        });
      });
    });
    return booking;
  }

  RentalInspection _demoInspection(
    InspectionType type,
    int fuel,
    int km, {
    int hold = 0,
    String? notes,
  }) => RentalInspection(
    type: type,
    fuelLevel: fuel,
    odometerKm: km,
    photoPaths: {for (final side in inspectionSides) side: 'demo/$side.jpg'},
    damageNotes: notes,
    depositHoldAmount: hold,
    inspectorConfirmedAt: DateTime.now(),
  );

  RentalBooking _rental(String id) {
    final b = _rentals[id];
    if (b == null) throw const BackendException('booking_not_found');
    return b;
  }

  @override
  Stream<List<RentalBooking>> watchMyRentals() => _rentalStream(
    () =>
        _rentals.values.where((b) => b.riderName == null).toList()
          ..sort((a, b) => b.startsAt.compareTo(a.startsAt)),
  );

  @override
  Stream<RentalBooking> watchRental(String bookingId) => _rentalStream(() => _rental(bookingId));

  @override
  Future<RentalBooking> cancelRental(String bookingId, {String? reason}) async {
    final b = _rental(bookingId);
    if (!b.isCancellable) throw const BackendException('booking_not_cancellable');
    final c = b.copyWith(status: RentalBookingStatus.cancelled);
    _saveRental(c);
    return c;
  }

  @override
  Future<void> confirmInspection(String bookingId, InspectionType type) async {
    final b = _rental(bookingId);
    if (type == InspectionType.handover) {
      if (b.status != RentalBookingStatus.driverAssigned || b.handover == null) {
        throw const BackendException('inspection_not_ready');
      }
      _saveRental(
        b.copyWith(status: RentalBookingStatus.active, depositStatus: DepositStatus.held),
      );
    } else {
      final r = b.returnInspection;
      if (b.status != RentalBookingStatus.returnPending || r == null) {
        throw const BackendException('inspection_not_ready');
      }
      _saveRental(
        b.copyWith(
          status: RentalBookingStatus.completed,
          depositHeldAmount: r.depositHoldAmount,
          depositStatus:
              r.depositHoldAmount == 0 ? DepositStatus.released : DepositStatus.partiallyHeld,
        ),
      );
    }
  }

  @override
  Future<void> requestReturn(String bookingId) async {
    final b = _rental(bookingId);
    if (b.status != RentalBookingStatus.active) throw const BackendException('return_not_allowed');
    // Simulated: the driver inspects the returned car (no damage → full deposit back).
    _after(timing.matching, () {
      final c = _rentals[bookingId];
      if (c == null || c.status != RentalBookingStatus.active) return;
      _saveRental(
        c.copyWith(
          status: RentalBookingStatus.returnPending,
          returnInspection: _demoInspection(InspectionType.return_, 6, 41200 + c.kmAllowance ~/ 2),
        ),
      );
    });
  }

  /// Driver: one airport delivery to practise the handover on, once approved.
  void _seedDriverRental() {
    if (_rentals.values.any((b) => b.riderName != null)) return;
    final car = demoRentalFleet[1];
    final start = DateTime.now().add(const Duration(days: 1, hours: 2));
    _saveRental(
      RentalBooking(
        id: _id('rental'),
        reference: 'RN-2048',
        vehicle: car,
        status: RentalBookingStatus.driverAssigned,
        startsAt: start,
        endsAt: start.add(const Duration(days: 3)),
        pickupType: RentalPickupType.airport,
        days: 3,
        dailyRate: car.dailyRate,
        rentalAmount: car.dailyRate * 3,
        airportFee: 5000,
        depositAmount: car.depositAmount,
        totalAmount: car.dailyRate * 3 + 5000,
        kmAllowance: car.kmPerDay * 3,
        paymentMethod: PaymentMethodType.mtnMomo,
        pickupAddress: demoAirports.first.name,
        airportCode: 'DLA',
        terminal: 'Arrivals',
        flightNumber: 'AF900',
        flightArrivalAt: start,
        assignedDriverId: _profile?.id,
        riderName: 'Aïcha Ngo Mbappe',
        riderPhone: '+237671234567',
      ),
    );
  }

  @override
  Stream<List<RentalBooking>> watchAssignedRentals() => _rentalStream(
    () =>
        _rentals.values
            .where((b) => b.riderName != null && b.status != RentalBookingStatus.cancelled)
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
  );

  @override
  Future<void> submitInspection(
    String bookingId,
    InspectionType type,
    InspectionDraft draft, {
    void Function(double)? onProgress,
  }) async {
    final b = _rental(bookingId);
    if (!inspectionSides.every(draft.localPhotos.containsKey)) {
      throw const BackendException('photos_missing');
    }
    if (type == InspectionType.handover && b.status != RentalBookingStatus.driverAssigned) {
      throw const BackendException('handover_not_allowed');
    }
    if (type == InspectionType.return_ && b.status != RentalBookingStatus.active) {
      throw const BackendException('return_not_allowed');
    }
    if (draft.depositHoldAmount < 0 || draft.depositHoldAmount > b.depositAmount) {
      throw const BackendException('invalid_deposit_hold');
    }
    for (var i = 1; i <= inspectionSides.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      onProgress?.call(i / inspectionSides.length);
    }
    final inspection = RentalInspection(
      type: type,
      fuelLevel: draft.fuelLevel,
      odometerKm: draft.odometerKm,
      photoPaths: draft.localPhotos,
      damageNotes: draft.damageNotes,
      depositHoldAmount: draft.depositHoldAmount,
      inspectorConfirmedAt: DateTime.now(),
    );
    if (type == InspectionType.handover) {
      _saveRental(b.copyWith(handover: inspection));
      // Simulated: the rider confirms the handover on their phone.
      _after(timing.matching, () {
        final c = _rentals[bookingId];
        if (c?.status == RentalBookingStatus.driverAssigned) {
          _saveRental(
            c!.copyWith(status: RentalBookingStatus.active, depositStatus: DepositStatus.held),
          );
        }
      });
    } else {
      _saveRental(
        b.copyWith(status: RentalBookingStatus.returnPending, returnInspection: inspection),
      );
      _after(timing.matching, () {
        final c = _rentals[bookingId];
        if (c?.status == RentalBookingStatus.returnPending) {
          _saveRental(
            c!.copyWith(
              status: RentalBookingStatus.completed,
              depositHeldAmount: draft.depositHoldAmount,
              depositStatus:
                  draft.depositHoldAmount == 0
                      ? DepositStatus.released
                      : DepositStatus.partiallyHeld,
            ),
          );
        }
      });
    }
  }

  /// Debug helper: make a new demo driver approved straight away.
  void approveDemoDriver() {
    _setAccount(
      DriverAccount(
        status: VerificationStatus.approved,
        cityCode: 'douala',
        licenceNumber: 'LT-DL-204518',
        nationalIdNumber: '112233445',
        payoutMethod: PaymentMethodType.mtnMomo,
        vehicle: _demoDriver.vehicle,
      ),
    );
  }

  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _offerTimer?.cancel();
  }
}
