// Supabase implementation of the repositories, on top of supabase/migrations (RPCs, RLS,
// Realtime) and supabase/functions (Places, Routes, fares, matching). Every price, status change
// and PIN check happens server-side; this class only calls those entry points.
import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/db_enums.dart';
import '../supabase/server_errors.dart';
import 'earnings_models.dart';
import 'models.dart';
import 'safety_rental_models.dart';
import 'repositories.dart';

const _activeStatuses = [
  'requested',
  'searching',
  'driver_assigned',
  'driver_arriving',
  'driver_arrived',
  'in_progress',
];

const _shareBase = String.fromEnvironment(
  'TRIP_SHARE_BASE_URL',
  defaultValue: 'https://iyodriver.cm/trip',
);

class SupabaseBackend implements IyoBackend {
  SupabaseBackend({required this.role, SupabaseClient? client})
    : _db = client ?? Supabase.instance.client;

  final AppRole role;

  @override
  bool get isDemo => false;
  final SupabaseClient _db;

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const BackendException('not_authenticated');
    return id;
  }

  /// Runs a call and turns server errors into [BackendException]s with our error codes.
  Future<T> _call<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on PostgrestException catch (e) {
      throw BackendException(serverErrorCode(e.message) ?? 'internal_error', e.message);
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map && details['error'] is String ? details['error'] as String : null;
      throw BackendException(code ?? 'upstream_error', details);
    } on AuthException catch (e) {
      throw BackendException(
        e.code == 'otp_expired' ? 'otp_invalid' : (e.code ?? 'not_authenticated'),
        e.message,
      );
    } on SocketException catch (e) {
      throw BackendException('offline', e.message);
    }
  }

  Future<Map<String, dynamic>> _invoke(String fn, Map<String, Object?> body) => _call(() async {
    final res = await _db.functions.invoke(fn, body: body);
    return Map<String, dynamic>.from(res.data as Map);
  });

  // ---------------------------------------------------------------------------
  // Auth (phone OTP; the profile row is created by the on_auth_user_created trigger)
  // ---------------------------------------------------------------------------

  UserProfile? _profile;

  @override
  UserProfile? get currentProfile => _profile;

  Future<UserProfile?> _loadProfile() async {
    final user = _db.auth.currentUser;
    if (user == null) return _profile = null;
    final row = await _db.from('profiles').select().eq('id', user.id).maybeSingle();
    return _profile = row == null ? null : _profileFrom(row);
  }

  UserProfile _profileFrom(Map<String, dynamic> r) => UserProfile(
    id: r['id'] as String,
    role: AppRole.fromValue(r['role'] as String),
    fullName: r['full_name'] as String? ?? '',
    phone: r['phone'] as String? ?? '',
    language: AppLanguage.fromValue(r['language'] as String? ?? 'fr'),
    rating: (r['rating'] as num?)?.toDouble(),
    ratingCount: r['rating_count'] as int? ?? 0,
  );

  @override
  Stream<UserProfile?> watchProfile() async* {
    yield await _loadProfile();
    await for (final _ in _db.auth.onAuthStateChange) {
      yield await _loadProfile();
    }
  }

  SignUpDetails? _pendingSignUp;

  @override
  Future<void> sendOtp(String phoneE164) => _call(
    () => _db.auth.signInWithOtp(
      phone: phoneE164,
      // Read by handle_new_auth_user() on first sign-up only.
      data: {
        'app_role': role.value,
        if (_pendingSignUp != null) 'full_name': _pendingSignUp!.fullName,
        if (_pendingSignUp?.language != null) 'language': _pendingSignUp!.language!.value,
      },
    ),
  );

  /// Call before [sendOtp] on the sign-up screen so the name lands in the new profile.
  void prepareSignUp(SignUpDetails details) => _pendingSignUp = details;

  @override
  Future<UserProfile> verifyOtp(String phoneE164, String code, {SignUpDetails? signUp}) =>
      _call(() async {
        await _db.auth.verifyOTP(type: OtpType.sms, phone: phoneE164, token: code);
        final profile = await _loadProfile();
        if (profile == null) throw const BackendException('not_authenticated');
        if (profile.role != role) {
          await _db.auth.signOut();
          throw const BackendException('wrong_role');
        }
        _pendingSignUp = null;
        return profile;
      });

  @override
  Future<void> signOut() => _db.auth.signOut();

  // ---------------------------------------------------------------------------
  // Places (Edge Functions; keys stay server-side)
  // ---------------------------------------------------------------------------

  String get _lang => _profile?.language.value ?? 'fr';

  @override
  Future<List<Place>> autocomplete(
    String input, {
    required String sessionToken,
    GeoPoint? near,
  }) async {
    final data = await _invoke('places-autocomplete', {
      'input': input,
      'sessionToken': sessionToken,
      'language': _lang,
      if (near != null) 'bias': {'lat': near.lat, 'lng': near.lng},
    });
    return [
      for (final s in (data['suggestions'] as List).cast<Map<String, dynamic>>())
        Place(
          name: s['primaryText'] as String,
          address: s['secondaryText'] as String,
          placeId: s['placeId'] as String,
        ),
    ];
  }

  @override
  Future<Place> details(Place suggestion, {required String sessionToken}) async {
    final data = await _invoke('place-details', {
      'placeId': suggestion.placeId,
      'sessionToken': sessionToken,
      'language': _lang,
    });
    final p = data['place'] as Map<String, dynamic>;
    final loc = p['location'] as Map<String, dynamic>;
    return Place(
      name: p['name'] as String,
      address: p['address'] as String,
      placeId: p['placeId'] as String,
      location: GeoPoint((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble()),
    );
  }

  @override
  Future<List<Place>> savedPlaces() => _call(() async {
    final rows = await _db
        .from('saved_places')
        .select('label, address, place_id, lat, lng')
        .order('created_at');
    return [
      for (final r in rows)
        Place(
          name: r['label'] as String,
          address: r['address'] as String,
          placeId: r['place_id'] as String?,
          location: GeoPoint((r['lat'] as num).toDouble(), (r['lng'] as num).toDouble()),
        ),
    ];
  });

  // ---------------------------------------------------------------------------
  // Rides
  // ---------------------------------------------------------------------------

  Map<String, Object?> _placeBody(Place p) => {
    'lat': p.location!.lat,
    'lng': p.location!.lng,
    'address': p.name == p.address ? p.address : '${p.name}, ${p.address}',
    if (p.placeId != null) 'placeId': p.placeId,
  };

  @override
  Future<FareEstimate> estimateFares(Place pickup, Place dropoff) async {
    final data = await _invoke('estimate-fares', {
      'pickup': _placeBody(pickup),
      'dropoff': _placeBody(dropoff),
    });
    final route = data['route'] as Map<String, dynamic>;
    return FareEstimate(
      route: RouteInfo(
        distanceMeters: route['distanceMeters'] as int,
        durationSeconds: route['durationSeconds'] as int,
        points: decodePolyline(route['polyline'] as String? ?? ''),
      ),
      options: [
        for (final o in (data['options'] as List).cast<Map<String, dynamic>>())
          FareOption(
            quoteId: o['quoteId'] as String,
            categoryCode: o['categoryCode'] as String,
            nameEn: o['nameEn'] as String,
            nameFr: o['nameFr'] as String,
            seats: o['seats'] as int,
            fareAmount: o['fareAmount'] as int,
            expiresAt: DateTime.parse(o['expiresAt'] as String),
            isPlaceholder: o['isPlaceholder'] as bool? ?? false,
          ),
      ],
    );
  }

  Place _place(Map<String, dynamic> r, String prefix) => Place(
    name: (r['${prefix}_address'] as String).split(',').first,
    address: r['${prefix}_address'] as String,
    placeId: r['${prefix}_place_id'] as String?,
    location: GeoPoint(
      (r['${prefix}_lat'] as num).toDouble(),
      (r['${prefix}_lng'] as num).toDouble(),
    ),
  );

  Ride _rideFrom(Map<String, dynamic> r, {String? pin, Map<String, dynamic>? location}) => Ride(
    id: r['id'] as String,
    status: RideStatus.fromValue(r['status'] as String),
    pickup: _place(r, 'pickup'),
    dropoff: _place(r, 'dropoff'),
    categoryCode: r['category_code'] as String,
    fareAmount: r['fare_amount'] as int,
    paymentMethod: PaymentMethodType.fromValue(r['payment_method'] as String),
    distanceMeters: r['distance_m'] as int,
    durationSeconds: r['duration_s'] as int,
    requestedAt: DateTime.parse(r['requested_at'] as String),
    commissionRate: (r['commission_rate'] as num).toDouble(),
    cancelReason: r['cancel_reason'] as String?,
    startedAt: r['started_at'] == null ? null : DateTime.parse(r['started_at'] as String),
    completedAt: r['completed_at'] == null ? null : DateTime.parse(r['completed_at'] as String),
    pin: pin,
    driverLocation:
        location == null
            ? null
            : GeoPoint((location['lat'] as num).toDouble(), (location['lng'] as num).toDouble()),
    driverHeading: (location?['heading'] as num?)?.toDouble(),
  );

  @override
  Future<Ride?> openRide() => _call(() async {
    final row =
        await _db
            .from('rides')
            .select()
            .eq('rider_id', _uid)
            .inFilter('status', _activeStatuses)
            .maybeSingle();
    return row == null ? null : _rideFrom(row);
  });

  Future<String?> _paymentMethodId(PaymentMethodType method) async {
    if (method == PaymentMethodType.cash) return null;
    final row =
        await _db
            .from('payment_methods')
            .select('id')
            .eq('type', method.value)
            .order('is_default', ascending: false)
            .limit(1)
            .maybeSingle();
    final id = row?['id'] as String?;
    if (id == null) throw const BackendException('invalid_payment_method');
    return id;
  }

  @override
  Future<Ride> requestRide(FareOption option, PaymentMethodType method) => _call(() async {
    final methodId = await _paymentMethodId(method);
    final row = await _db.rpc<Map<String, dynamic>>(
      'request_ride',
      params: {
        'p_quote_id': option.quoteId,
        'p_payment_method': method.value,
        if (methodId != null) 'p_payment_method_id': methodId,
      },
    );
    final ride = _rideFrom(row);
    unawaited(_invoke('match-ride', {'rideId': ride.id}).catchError((_) => <String, dynamic>{}));
    return ride;
  });

  @override
  Stream<Ride> watchRide(String rideId) {
    late final StreamController<Ride> out;
    StreamSubscription<List<Map<String, dynamic>>>? rideSub, locSub;
    Timer? matchPing;
    Map<String, dynamic>? lastRow, lastLoc;
    String? pin, watchedDriver;

    void push() {
      if (lastRow != null) out.add(_rideFrom(lastRow!, pin: pin, location: lastLoc));
    }

    out = StreamController<Ride>(
      onListen: () async {
        if (role == AppRole.rider) {
          final p = await _db.from('ride_pins').select('pin').eq('ride_id', rideId).maybeSingle();
          pin = p?['pin'] as String?;
        }
        void onRows(List<Map<String, dynamic>> rows) {
          if (rows.isEmpty) return;
          lastRow = rows.first;
          final status = lastRow!['status'] as String;
          // Keep matching alive while searching (match-ride is idempotent).
          if (role == AppRole.rider && status == 'searching') {
            matchPing ??= Timer.periodic(const Duration(seconds: 5), (_) {
              _invoke('match-ride', {'rideId': rideId}).ignore();
            });
          } else {
            matchPing?.cancel();
            matchPing = null;
          }
          final driver = lastRow!['driver_id'] as String?;
          if (role == AppRole.rider && driver != null && driver != watchedDriver) {
            watchedDriver = driver;
            locSub?.cancel();
            locSub = _db
                .from('driver_locations')
                .stream(primaryKey: ['driver_id'])
                .eq('driver_id', driver)
                .listen((l) {
                  lastLoc = l.isEmpty ? null : l.first;
                  push();
                });
          }
          push();
        }

        rideSub = _db
            .from('rides')
            .stream(primaryKey: ['id'])
            .eq('id', rideId)
            .listen(onRows, onError: out.addError);
      },
      onCancel: () async {
        matchPing?.cancel();
        await rideSub?.cancel();
        await locSub?.cancel();
      },
    );
    return out.stream;
  }

  Counterpart? _counterpartFrom(dynamic json) {
    if (json == null) return null;
    final m = Map<String, dynamic>.from(json as Map);
    final v = m['vehicle'] as Map<String, dynamic>?;
    return Counterpart(
      id: m['id'] as String,
      firstName: (m['first_name'] ?? (m['full_name'] as String? ?? '').split(' ').first) as String,
      fullName: m['full_name'] as String?,
      phone: m['phone'] as String?,
      rating: (m['rating'] as num?)?.toDouble(),
      ratingCount: m['rating_count'] as int? ?? 0,
      avatarUrl: m['avatar_url'] as String?,
      vehicle:
          v == null
              ? null
              : VehicleInfo(
                make: v['make'] as String,
                model: v['model'] as String,
                color: v['color'] as String,
                plate: v['plate'] as String,
                categoryCode: v['category_code'] as String,
              ),
    );
  }

  @override
  Future<Counterpart?> driverFor(String rideId) => _call(
    () async => _counterpartFrom(
      await _db.rpc<dynamic>('get_ride_counterpart', params: {'p_ride_id': rideId}),
    ),
  );

  @override
  Future<Ride> cancel(String rideId, {String? reason}) => _call(
    () async => _rideFrom(
      await _db.rpc<Map<String, dynamic>>(
        'cancel_ride_as_rider',
        params: {'p_ride_id': rideId, 'p_reason': reason},
      ),
    ),
  );

  @override
  Future<void> rate(String rideId, int stars, {int tip = 0, String? comment}) => _call(
    () => _db.rpc<dynamic>(
      'rate_ride',
      params: {'p_ride_id': rideId, 'p_stars': stars, 'p_tip_amount': tip, 'p_comment': comment},
    ),
  );

  // ---------------------------------------------------------------------------
  // Chat (messages table, RLS: ride parties, open until 1 h after the trip)
  // ---------------------------------------------------------------------------

  @override
  Stream<List<ChatEntry>> watchMessages(String rideId) => _db
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('ride_id', rideId)
      .order('created_at')
      .map(
        (rows) => [
          for (final r in rows)
            ChatEntry(
              id: r['id'] as String,
              body: r['body'] as String,
              senderId: r['sender_id'] as String,
              sentAt: DateTime.parse(r['created_at'] as String),
              readAt: r['read_at'] == null ? null : DateTime.parse(r['read_at'] as String),
            ),
        ],
      );

  @override
  Future<void> send(String rideId, String body) => _call(
    () => _db.from('messages').insert({'ride_id': rideId, 'sender_id': _uid, 'body': body}),
  );

  // ---------------------------------------------------------------------------
  // Driver
  // ---------------------------------------------------------------------------

  Future<DriverAccount> _loadAccount() async {
    final d = await _db.from('driver_profiles').select().eq('user_id', _uid).single();
    final v =
        await _db
            .from('vehicles')
            .select()
            .eq('driver_id', _uid)
            .order('created_at')
            .limit(1)
            .maybeSingle();
    final docs = await _db.from('driver_documents').select().eq('driver_id', _uid);
    return DriverAccount(
      status: VerificationStatus.fromValue(d['verification_status'] as String),
      cityCode: d['city_code'] as String?,
      licenceNumber: d['licence_number'] as String?,
      dateOfBirth: _date(d['date_of_birth']),
      nationalIdNumber: d['national_id_number'] as String?,
      payoutMethod:
          d['payout_method'] == null
              ? null
              : PaymentMethodType.fromValue(d['payout_method'] as String),
      payoutPhone: d['payout_phone'] as String?,
      reviewNotes: d['review_notes'] as String?,
      vehicle:
          v == null
              ? null
              : VehicleInfo(
                make: v['make'] as String,
                model: v['model'] as String,
                color: v['color'] as String,
                plate: v['plate'] as String,
                categoryCode: v['category_code'] as String,
                year: v['year'] as int?,
                seats: v['seats'] as int? ?? 4,
              ),
      documents: {
        for (final r in docs)
          DocumentType.fromValue(r['type'] as String): DriverDocument(
            type: DocumentType.fromValue(r['type'] as String),
            status: ReviewStatus.fromValue(r['status'] as String),
            rejectionReason: r['rejection_reason'] as String?,
            expiresOn: _date(r['expires_on']),
          ),
      },
    );
  }

  @override
  Stream<DriverAccount> watchAccount() => _db
      .from('driver_profiles')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', _uid)
      .asyncMap((_) => _loadAccount());

  @override
  Future<void> saveIdentity({
    required String cityCode,
    required String licenceNumber,
    required String nationalIdNumber,
    required VehicleInfo vehicle,
    String? legalName,
    DateTime? dateOfBirth,
  }) => _call(() async {
    await _db
        .from('driver_profiles')
        .update({
          'city_code': cityCode,
          'licence_number': licenceNumber,
          'national_id_number': nationalIdNumber,
          if (dateOfBirth != null)
            'date_of_birth':
                '${dateOfBirth.year.toString().padLeft(4, '0')}-'
                '${dateOfBirth.month.toString().padLeft(2, '0')}-'
                '${dateOfBirth.day.toString().padLeft(2, '0')}',
        })
        .eq('user_id', _uid);
    if (legalName != null && legalName.trim().isNotEmpty) {
      await _db.from('profiles').update({'full_name': legalName.trim()}).eq('id', _uid);
    }
    final values = {
      'category_code': vehicle.categoryCode,
      'make': vehicle.make,
      'model': vehicle.model,
      'year': vehicle.year,
      'color': vehicle.color,
      'plate': vehicle.plate,
      'seats': vehicle.seats,
    };
    final existing =
        await _db.from('vehicles').select('id').eq('driver_id', _uid).limit(1).maybeSingle();
    if (existing == null) {
      await _db.from('vehicles').insert({...values, 'driver_id': _uid});
    } else {
      await _db.from('vehicles').update(values).eq('id', existing['id'] as String);
    }
  });

  @override
  Future<void> uploadDocument(
    DocumentType type,
    String localPath, {
    void Function(double)? onProgress,
  }) => _call(() async {
    final ext = localPath.split('.').last.toLowerCase();
    final path = '$_uid/${type.value}.$ext';
    onProgress?.call(0.1);
    await _db.storage
        .from('driver-documents')
        .upload(path, File(localPath), fileOptions: const FileOptions(upsert: true));
    onProgress?.call(0.9);
    final existing =
        await _db.from('driver_documents').select('id').eq('type', type.value).maybeSingle();
    final mime = ext == 'pdf' ? 'application/pdf' : (ext == 'png' ? 'image/png' : 'image/jpeg');
    if (existing == null) {
      await _db.from('driver_documents').insert({
        'driver_id': _uid,
        'type': type.value,
        'storage_path': path,
        'mime_type': mime,
      });
    } else {
      await _db
          .from('driver_documents')
          .update({'storage_path': path, 'mime_type': mime})
          .eq('id', existing['id'] as String);
    }
    onProgress?.call(1);
  });

  @override
  Future<void> submitApplication() => _call(() => _db.rpc<dynamic>('submit_driver_application'));

  @override
  Stream<bool> watchOnline() => _db
      .from('driver_locations')
      .stream(primaryKey: ['driver_id'])
      .eq('driver_id', _uid)
      .map((rows) => rows.isNotEmpty && rows.first['is_online'] == true);

  @override
  Future<void> setOnline(bool online, {GeoPoint? at}) => _call(
    () => _db.rpc<dynamic>(
      'set_driver_online',
      params: {'p_online': online, 'p_lat': at?.lat, 'p_lng': at?.lng},
    ),
  );

  @override
  Future<void> updateLocation(GeoPoint at, {double? heading, double? speedMps}) => _call(
    () => _db.rpc<dynamic>(
      'update_driver_location',
      params: {'p_lat': at.lat, 'p_lng': at.lng, 'p_heading': heading, 'p_speed_mps': speedMps},
    ),
  );

  @override
  Stream<RideOffer?> watchOffers() => _db
      .from('ride_offers')
      .stream(primaryKey: ['id'])
      .eq('driver_id', _uid)
      .asyncMap((rows) async {
        final now = DateTime.now();
        final pending = rows.where(
          (r) => r['status'] == 'pending' && DateTime.parse(r['expires_at'] as String).isAfter(now),
        );
        if (pending.isEmpty) return null;
        final o = pending.first;
        final rideRow = await _db.from('rides').select().eq('id', o['ride_id'] as String).single();
        final rider = _counterpartFrom(
          await _db.rpc<dynamic>('get_ride_counterpart', params: {'p_ride_id': o['ride_id']}),
        );
        return RideOffer(
          id: o['id'] as String,
          ride: _rideFrom(rideRow),
          rider: rider!,
          expiresAt: DateTime.parse(o['expires_at'] as String),
          pickupDistanceMeters: o['distance_m'] as int?,
          pickupEtaSeconds: o['eta_seconds'] as int?,
        );
      });

  @override
  Future<Ride?> respond(RideOffer offer, {required bool accept}) => _call(() async {
    final row = await _db.rpc<dynamic>(
      'respond_to_ride_offer',
      params: {'p_offer_id': offer.id, 'p_accept': accept},
    );
    return row == null ? null : _rideFrom(Map<String, dynamic>.from(row as Map));
  });

  @override
  Future<Counterpart?> riderFor(String rideId) => _call(
    () async => _counterpartFrom(
      await _db.rpc<dynamic>('get_ride_counterpart', params: {'p_ride_id': rideId}),
    ),
  );

  @override
  Future<Ride> updateStatus(String rideId, RideStatus status, {String? reason}) => _call(
    () async => _rideFrom(
      await _db.rpc<Map<String, dynamic>>(
        'driver_update_ride_status',
        params: {'p_ride_id': rideId, 'p_status': status.value, 'p_reason': reason},
      ),
    ),
  );

  @override
  Future<PinCheck> verifyPin(String rideId, String pin) => _call(() async {
    final r = Map<String, dynamic>.from(
      await _db.rpc<dynamic>('verify_pickup_pin', params: {'p_ride_id': rideId, 'p_pin': pin})
          as Map,
    );
    return PinCheck(
      ok: r['ok'] as bool,
      locked: r['locked'] as bool,
      attemptsLeft: r['attempts_left'] as int,
    );
  });

  @override
  Future<void> rateRider(String rideId, int stars) =>
      _call(() => _db.rpc<dynamic>('rate_ride', params: {'p_ride_id': rideId, 'p_stars': stars}));

  @override
  Future<DriverDaySummary> today() => _call(() async {
    final start = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    final rows = await _db
        .from('rides')
        .select('fare_amount, driver_earnings')
        .eq('driver_id', _uid)
        .eq('status', 'completed')
        .gte('completed_at', start.toIso8601String());
    return DriverDaySummary(
      earnings: rows.fold(0, (s, r) => s + (r['driver_earnings'] as int)),
      trips: rows.length,
      onlineSeconds: 0, // TODO(Phase 11): track online sessions server-side.
    );
  });

  static const _tripSelect =
      'id, pickup_address, dropoff_address, fare_amount, driver_earnings, started_at, completed_at, '
      'ratings(tip_amount, rater_role)';

  CompletedTrip _tripFrom(Map<String, dynamic> r) {
    final started = _date(r['started_at']);
    final completed = DateTime.parse(r['completed_at'] as String);
    final tip = [
      for (final x in (r['ratings'] as List? ?? const []).cast<Map<String, dynamic>>())
        if (x['rater_role'] == 'rider') x['tip_amount'] as int? ?? 0,
    ].fold(0, (a, b) => a + b);
    return CompletedTrip(
      rideId: r['id'] as String,
      pickupName: (r['pickup_address'] as String?)?.split(',').first,
      dropoffName: (r['dropoff_address'] as String).split(',').first,
      fareAmount: r['fare_amount'] as int,
      earnings: r['driver_earnings'] as int,
      tip: tip,
      startedAt: started,
      completedAt: completed,
      durationSeconds: started == null ? 0 : completed.difference(started).inSeconds,
    );
  }

  @override
  Future<List<CompletedTrip>> recentTrips() => _call(() async {
    final rows = await _db
        .from('rides')
        .select(_tripSelect)
        .eq('driver_id', _uid)
        .eq('status', 'completed')
        .order('completed_at', ascending: false)
        .limit(30);
    return rows.map(_tripFrom).toList();
  });

  @override
  Future<List<CompletedTrip>> tripsSince(DateTime from) => _call(() async {
    final rows = await _db
        .from('rides')
        .select(_tripSelect)
        .eq('driver_id', _uid)
        .eq('status', 'completed')
        .gte('completed_at', from.toUtc().toIso8601String())
        .order('completed_at', ascending: false);
    return rows.map(_tripFrom).toList();
  });

  @override
  Future<List<Payout>> payouts() => _call(() async {
    final rows = await _db
        .from('driver_payouts')
        .select()
        .eq('driver_id', _uid)
        .order('requested_at', ascending: false)
        .limit(26);
    return [
      for (final r in rows)
        Payout(
          id: r['id'] as String,
          amount: r['amount'] as int,
          method: PaymentMethodType.fromValue(r['method'] as String),
          phone: r['phone'] as String,
          status: PayoutStatus.fromValue(r['status'] as String),
          requestedAt: DateTime.parse(r['requested_at'] as String),
          periodStart: _date(r['period_start']),
          periodEnd: _date(r['period_end']),
          paidAt: _date(r['paid_at']),
          providerReference: r['provider_reference'] as String?,
          failureReason: r['failure_reason'] as String?,
        ),
    ];
  });

  // ---------------------------------------------------------------------------
  // Safety (trusted contacts are capped at 5 by a trigger; alerts snapshot the trip server-side)
  // ---------------------------------------------------------------------------

  TrustedContact _contactFrom(Map<String, dynamic> r) => TrustedContact(
    id: r['id'] as String,
    name: r['name'] as String,
    phone: r['phone'] as String,
    relationship: r['relationship'] as String?,
    notifyOnAlert: r['notify_on_alert'] as bool? ?? true,
  );

  @override
  Future<List<TrustedContact>> trustedContacts() => _call(() async {
    final rows = await _db
        .from('trusted_contacts')
        .select()
        .eq('user_id', _uid)
        .order('created_at');
    return rows.map(_contactFrom).toList();
  });

  @override
  Future<TrustedContact> addTrustedContact({
    required String name,
    required String phoneE164,
    String? relationship,
  }) => _call(() async {
    final row =
        await _db
            .from('trusted_contacts')
            .insert({
              'user_id': _uid,
              'name': name,
              'phone': phoneE164,
              if (relationship != null && relationship.isNotEmpty) 'relationship': relationship,
            })
            .select()
            .single();
    return _contactFrom(row);
  });

  @override
  Future<void> removeTrustedContact(String id) =>
      _call(() => _db.from('trusted_contacts').delete().eq('id', id));

  @override
  Future<void> setNotifyOnAlert(String id, {required bool notify}) =>
      _call(() => _db.from('trusted_contacts').update({'notify_on_alert': notify}).eq('id', id));

  @override
  Future<List<EmergencyNumber>> emergencyNumbers() async {
    try {
      final row =
          await _db.from('app_config').select('value').eq('key', 'emergency_numbers').maybeSingle();
      final list = row?['value'];
      if (list is! List || list.isEmpty) return defaultEmergencyNumbers;
      return [
        for (final e in list.cast<Map<String, dynamic>>())
          EmergencyNumber(service: e['service'] as String, number: e['number'] as String),
      ];
    } on Object {
      // Offline: the numbers must still be callable.
      return defaultEmergencyNumbers;
    }
  }

  @override
  Future<SafetyAlert> raiseAlert({String? rideId, GeoPoint? at, String? reason, String? note}) =>
      _call(() async {
        final row = await _db.rpc<Map<String, dynamic>>(
          'raise_safety_alert',
          params: {
            'p_ride_id': rideId,
            'p_lat': at?.lat,
            'p_lng': at?.lng,
            'p_reason': reason,
            'p_note': note,
          },
        );
        return SafetyAlert(
          id: row['id'] as String,
          createdAt: DateTime.parse(row['created_at'] as String),
          rideId: row['ride_id'] as String?,
        );
      });

  @override
  Future<int> notifyTrustedContacts(String alertId) async =>
      (await _invoke('safety-notify', {'alertId': alertId}))['notified'] as int? ?? 0;

  @override
  Future<TripShare> shareTrip(String rideId) => _call(() async {
    final row = await _db.rpc<Map<String, dynamic>>(
      'create_trip_share',
      params: {'p_ride_id': rideId},
    );
    final token = row['token'] as String;
    return TripShare(
      token: token,
      expiresAt: DateTime.parse(row['expires_at'] as String),
      url: '$_shareBase?t=$token',
    );
  });

  @override
  Future<IncidentReport> reportIncident({
    required String category,
    String? description,
    String? rideId,
    String? rentalBookingId,
    GeoPoint? at,
    bool urgent = false,
  }) => _call(() async {
    final row = await _db.rpc<Map<String, dynamic>>(
      'report_incident',
      params: {
        'p_category': category,
        'p_description': description,
        'p_ride_id': rideId,
        'p_rental_booking_id': rentalBookingId,
        'p_lat': at?.lat,
        'p_lng': at?.lng,
        'p_is_urgent': urgent,
      },
    );
    return IncidentReport(
      id: row['id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      category: row['category'] as String,
    );
  });

  // ---------------------------------------------------------------------------
  // Rentals (prices and availability are computed by create_rental_booking)
  // ---------------------------------------------------------------------------

  static const _bookingSelect =
      '*, vehicle:rental_vehicles(*), inspections:rental_inspections(*), '
      'pin:rental_handover_pins(pin)';

  RentalVehicle _vehicleFrom(Map<String, dynamic> r) => RentalVehicle(
    id: r['id'] as String,
    cityCode: r['city_code'] as String,
    make: r['make'] as String,
    model: r['model'] as String,
    year: r['year'] as int?,
    category: r['category'] as String,
    transmission: TransmissionType.fromValue(r['transmission'] as String),
    seats: r['seats'] as int,
    fuelType: FuelType.fromValue(r['fuel_type'] as String),
    plate: r['plate'] as String,
    color: r['color'] as String?,
    dailyRate: r['daily_rate'] as int,
    depositAmount: r['deposit_amount'] as int,
    kmPerDay: r['km_per_day'] as int,
    extraKmRate: r['extra_km_rate'] as int? ?? 0,
    features: List<String>.from(r['features'] as List? ?? const []),
    airportPickupAvailable: r['airport_pickup_available'] as bool? ?? false,
    imagePaths: List<String>.from(r['image_paths'] as List? ?? const []),
    isPlaceholderPricing: r['is_placeholder_pricing'] as bool? ?? true,
  );

  RentalInspection _inspectionFrom(Map<String, dynamic> r) => RentalInspection(
    type: InspectionType.fromValue(r['type'] as String),
    fuelLevel: r['fuel_level'] as int,
    odometerKm: r['odometer_km'] as int,
    photoPaths: Map<String, String>.from(r['photo_paths'] as Map? ?? const {}),
    damageNotes: r['damage_notes'] as String?,
    depositHoldAmount: r['deposit_hold_amount'] as int? ?? 0,
    inspectorConfirmedAt: _date(r['inspector_confirmed_at']),
    riderConfirmedAt: _date(r['rider_confirmed_at']),
  );

  static DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);

  RentalBooking _bookingFrom(
    Map<String, dynamic> r, {
    Map<String, dynamic>? rider,
    Counterpart? driver,
  }) {
    // One-to-one embed: an object (rider), or null / empty when RLS hides it (driver).
    final pinRow = r['pin'] is List ? ((r['pin'] as List).firstOrNull) : r['pin'];
    final inspections = [
      for (final i in (r['inspections'] as List? ?? const []).cast<Map<String, dynamic>>())
        _inspectionFrom(i),
    ];
    RentalInspection? find(InspectionType t) {
      for (final i in inspections) {
        if (i.type == t) return i;
      }
      return null;
    }

    return RentalBooking(
      id: r['id'] as String,
      reference: r['reference'] as String,
      vehicle: _vehicleFrom(Map<String, dynamic>.from(r['vehicle'] as Map)),
      status: RentalBookingStatus.fromValue(r['status'] as String),
      startsAt: DateTime.parse(r['starts_at'] as String),
      endsAt: DateTime.parse(r['ends_at'] as String),
      pickupType: RentalPickupType.fromValue(r['pickup_type'] as String),
      days: r['days'] as int,
      dailyRate: r['daily_rate'] as int,
      rentalAmount: r['rental_amount'] as int,
      airportFee: r['airport_fee'] as int? ?? 0,
      depositAmount: r['deposit_amount'] as int,
      totalAmount: r['total_amount'] as int,
      kmAllowance: r['km_allowance'] as int,
      paymentMethod: PaymentMethodType.fromValue(r['payment_method'] as String),
      pickupAddress: r['pickup_address'] as String?,
      airportCode: r['airport_code'] as String?,
      terminal: r['terminal'] as String?,
      flightNumber: r['flight_number'] as String?,
      flightArrivalAt: _date(r['flight_arrival_at']),
      depositStatus: DepositStatus.fromValue(r['deposit_status'] as String),
      depositHeldAmount: r['deposit_held_amount'] as int? ?? 0,
      assignedDriverId: r['assigned_driver_id'] as String?,
      riderName: rider?['name'] as String?,
      riderPhone: rider?['phone'] as String?,
      handover: find(InspectionType.handover),
      returnInspection: find(InspectionType.return_),
      protectionAmount: r['protection_amount'] as int? ?? 0,
      handoverPin: pinRow is Map ? pinRow['pin'] as String? : null,
      driver: driver,
    );
  }

  /// Re-runs [load] whenever any of [triggers] emits (bookings and their inspections change apart).
  Stream<T> _reloadOn<T>(List<Stream<Object?>> triggers, Future<T> Function() load) {
    late final StreamController<T> out;
    final subs = <StreamSubscription<Object?>>[];
    var loading = false, again = false;
    Future<void> reload() async {
      if (loading) {
        again = true;
        return;
      }
      loading = true;
      try {
        do {
          again = false;
          final v = await load();
          if (!out.isClosed) out.add(v);
        } while (again);
      } on Object catch (e, s) {
        if (!out.isClosed) out.addError(e, s);
      } finally {
        loading = false;
      }
    }

    out = StreamController<T>(
      onListen: () {
        for (final t in triggers) {
          subs.add(t.listen((_) => unawaited(reload()), onError: out.addError));
        }
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return out.stream;
  }

  Stream<Object?> _inspectionChanges() => _db.from('rental_inspections').stream(primaryKey: ['id']);

  @override
  Future<List<RentalVehicle>> rentalVehicles(String cityCode) => _call(() async {
    final rows = await _db
        .from('rental_vehicles')
        .select()
        .eq('city_code', cityCode)
        .eq('status', 'available')
        .order('daily_rate');
    return rows.map(_vehicleFrom).toList();
  });

  @override
  Future<List<Airport>> airports() => _call(() async {
    final rows = await _db.from('airports').select().order('code');
    return [
      for (final r in rows)
        Airport(
          code: r['code'] as String,
          name: r['name'] as String,
          cityCode: r['city_code'] as String,
          pickupFee: r['pickup_fee'] as int,
          terminals: List<String>.from(r['terminals'] as List? ?? const []),
        ),
    ];
  });

  Future<RentalBooking> _loadBooking(String id, {bool withRider = false}) async {
    final row = await _db.from('rental_bookings').select(_bookingSelect).eq('id', id).single();
    Counterpart? driver;
    if (role == AppRole.rider && row['assigned_driver_id'] != null) {
      final d = await _db.rpc<dynamic>('get_rental_driver', params: {'p_booking_id': id});
      if (d is Map) {
        final name = (d['name'] as String?) ?? '';
        driver = Counterpart(
          id: d['id'] as String,
          firstName: name.split(' ').first,
          fullName: name,
          phone: d['phone'] as String?,
          rating: (d['rating'] as num?)?.toDouble(),
          ratingCount: d['rating_count'] as int? ?? 0,
        );
      }
    }
    return _bookingFrom(row, rider: withRider ? await _rentalRider(id) : null, driver: driver);
  }

  Future<Map<String, dynamic>> _rentalRider(String bookingId) async => Map<String, dynamic>.from(
    await _db.rpc<dynamic>('get_rental_rider', params: {'p_booking_id': bookingId}) as Map,
  );

  @override
  Future<RentalBooking> bookRental(RentalRequest r) => _call(() async {
    final methodId = await _paymentMethodId(r.paymentMethod);
    final airport = r.pickupType == RentalPickupType.airport;
    final row = await _db.rpc<Map<String, dynamic>>(
      'create_rental_booking',
      params: {
        'p_vehicle_id': r.vehicle.id,
        'p_starts_at': r.startsAt.toUtc().toIso8601String(),
        'p_ends_at': r.endsAt.toUtc().toIso8601String(),
        'p_pickup_type': r.pickupType.value,
        'p_payment_method': r.paymentMethod.value,
        'p_payment_method_id': methodId,
        'p_protection': r.protection,
        if (!airport) 'p_pickup_address': r.pickupAddress,
        if (airport) 'p_airport_code': r.airport?.code,
        if (airport) 'p_terminal': r.terminal,
        if (airport) 'p_flight_number': r.flightNumber?.toUpperCase().replaceAll(' ', ''),
        if (airport) 'p_flight_arrival_at': r.flightArrivalAt?.toUtc().toIso8601String(),
      },
    );
    // TODO(payments): start the provider flow (USSD push / card sheet) here once one is chosen;
    // until then the payment row stays pending and the payment webhook confirms it.
    return _loadBooking(row['id'] as String);
  });

  @override
  Stream<List<RentalBooking>> watchMyRentals() => _reloadOn(
    [
      _db.from('rental_bookings').stream(primaryKey: ['id']).eq('rider_id', _uid),
      _inspectionChanges(),
    ],
    () async {
      final rows = await _db
          .from('rental_bookings')
          .select(_bookingSelect)
          .eq('rider_id', _uid)
          .order('starts_at', ascending: false);
      return rows.map(_bookingFrom).toList();
    },
  );

  @override
  Stream<RentalBooking> watchRental(String bookingId) {
    final triggers = [
      _db.from('rental_bookings').stream(primaryKey: ['id']).eq('id', bookingId),
      _db.from('rental_inspections').stream(primaryKey: ['id']).eq('booking_id', bookingId),
    ];
    return _reloadOn(triggers, () => _loadBooking(bookingId, withRider: role == AppRole.driver));
  }

  @override
  Future<RentalBooking> cancelRental(String bookingId, {String? reason}) => _call(() async {
    await _db.rpc<dynamic>(
      'cancel_rental_booking',
      params: {'p_booking_id': bookingId, 'p_reason': reason},
    );
    return _loadBooking(bookingId);
  });

  @override
  Future<void> confirmInspection(String bookingId, InspectionType type) => _call(
    () => _db.rpc<dynamic>(
      'confirm_rental_inspection',
      params: {'p_booking_id': bookingId, 'p_type': type.value},
    ),
  );

  @override
  Future<void> requestReturn(String bookingId) => _call(() async {
    // Nothing to write: the assigned driver meets the rider and submits the return inspection.
    final b = await _loadBooking(bookingId);
    if (b.status != RentalBookingStatus.active) throw const BackendException('return_not_allowed');
  });

  @override
  Future<int> rentalProtectionDaily() async {
    try {
      final row =
          await _db
              .from('app_config')
              .select('value')
              .eq('key', 'rental_protection_daily')
              .maybeSingle();
      return (row?['value'] as num?)?.toInt() ?? 0;
    } on Object {
      return 0;
    }
  }

  @override
  Future<PinCheck> confirmHandoverPin(String bookingId, String pin) => _call(() async {
    final r = Map<String, dynamic>.from(
      await _db.rpc<dynamic>(
            'confirm_rental_handover_pin',
            params: {'p_booking_id': bookingId, 'p_pin': pin},
          )
          as Map,
    );
    return PinCheck(
      ok: r['ok'] as bool,
      locked: r['locked'] as bool,
      attemptsLeft: r['attempts_left'] as int,
    );
  });

  @override
  Stream<List<RentalBooking>> watchAssignedRentals() => _reloadOn(
    [
      _db.from('rental_bookings').stream(primaryKey: ['id']).eq('assigned_driver_id', _uid),
      _inspectionChanges(),
    ],
    () async {
      final rows = await _db
          .from('rental_bookings')
          .select(_bookingSelect)
          .eq('assigned_driver_id', _uid)
          .neq('status', 'cancelled')
          .order('starts_at');
      return [for (final r in rows) _bookingFrom(r, rider: await _rentalRider(r['id'] as String))];
    },
  );

  @override
  Future<void> submitInspection(
    String bookingId,
    InspectionType type,
    InspectionDraft draft, {
    void Function(double)? onProgress,
  }) => _call(() async {
    if (!inspectionSides.every(draft.localPhotos.containsKey)) {
      throw const BackendException('photos_missing');
    }
    final paths = <String, String>{};
    var done = 0;
    for (final side in inspectionSides) {
      final path = '$bookingId/${type.value}/$side.jpg';
      await _db.storage
          .from('inspection-photos')
          .upload(
            path,
            File(draft.localPhotos[side]!),
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      paths[side] = path;
      onProgress?.call(++done / (inspectionSides.length + 1));
    }
    await _db.rpc<dynamic>(
      'submit_rental_inspection',
      params: {
        'p_booking_id': bookingId,
        'p_type': type.value,
        'p_fuel_level': draft.fuelLevel,
        'p_odometer_km': draft.odometerKm,
        'p_photo_paths': paths,
        'p_damage_notes': draft.damageNotes,
        'p_checklist': draft.checklist,
        'p_deposit_hold_amount': draft.depositHoldAmount,
      },
    );
    onProgress?.call(1);
  });
}

/// Decodes a Google encoded polyline.
List<GeoPoint> decodePolyline(String encoded) {
  final points = <GeoPoint>[];
  var index = 0, lat = 0, lng = 0;
  while (index < encoded.length) {
    for (var i = 0; i < 2; i++) {
      var shift = 0, result = 0, b = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final delta = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      if (i == 0) {
        lat += delta;
      } else {
        lng += delta;
      }
    }
    points.add(GeoPoint(lat / 1e5, lng / 1e5));
  }
  return points;
}
