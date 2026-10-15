// Supabase implementation of the repositories, on top of supabase/migrations (RPCs, RLS,
// Realtime) and supabase/functions (Places, Routes, fares, matching). Every price, status change
// and PIN check happens server-side; this class only calls those entry points.
import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/db_enums.dart';
import '../supabase/server_errors.dart';
import 'models.dart';
import 'repositories.dart';

const _activeStatuses = [
  'requested',
  'searching',
  'driver_assigned',
  'driver_arriving',
  'driver_arrived',
  'in_progress',
];

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

  @override
  Future<Ride> requestRide(FareOption option, PaymentMethodType method) => _call(() async {
    String? methodId;
    if (method != PaymentMethodType.cash) {
      final row =
          await _db
              .from('payment_methods')
              .select('id')
              .eq('type', method.value)
              .order('is_default', ascending: false)
              .limit(1)
              .maybeSingle();
      methodId = row?['id'] as String?;
      if (methodId == null) throw const BackendException('invalid_payment_method');
    }
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
        rideSub = _db.from('rides').stream(primaryKey: ['id']).eq('id', rideId).listen((rows) {
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
        }, onError: out.addError,);
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
  }) => _call(() async {
    await _db
        .from('driver_profiles')
        .update({
          'city_code': cityCode,
          'licence_number': licenceNumber,
          'national_id_number': nationalIdNumber,
        })
        .eq('user_id', _uid);
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

  @override
  Future<List<CompletedTrip>> recentTrips() => _call(() async {
    final rows = await _db
        .from('rides')
        .select('id, dropoff_address, fare_amount, driver_earnings, completed_at')
        .eq('driver_id', _uid)
        .eq('status', 'completed')
        .order('completed_at', ascending: false)
        .limit(30);
    return [
      for (final r in rows)
        CompletedTrip(
          rideId: r['id'] as String,
          dropoffName: (r['dropoff_address'] as String).split(',').first,
          fareAmount: r['fare_amount'] as int,
          earnings: r['driver_earnings'] as int,
          completedAt: DateTime.parse(r['completed_at'] as String),
        ),
    ];
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
