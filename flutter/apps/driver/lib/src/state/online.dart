import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iyo_core/iyo_core.dart';

import 'driver_location.dart';

/// Result of trying to go online.
enum GoOnlineResult { ok, locationDenied, notApproved, failed }

/// Coordinates the online switch with location streaming. While online the app sends its
/// position every 5 s (3 s on a trip); going offline stops all tracking (spec §7).
class OnlineController extends Notifier<bool> {
  @override
  bool build() => false; // true while a toggle is in progress

  IyoBackend get _backend => ref.read(backendProvider);
  DriverLocationService get _location => ref.read(driverLocationServiceProvider);

  Future<GoOnlineResult> goOnline({
    required String notificationTitle,
    required String notificationBody,
  }) async {
    state = true;
    try {
      if (!await _location.ensurePermission()) return GoOnlineResult.locationDenied;
      final fix = await _location.current();
      final here = fix ?? ref.read(lastPositionProvider.notifier).current;
      ref.read(lastPositionProvider.notifier).set(here);
      await _backend.setOnline(true, at: here.point);
      _stream(const Duration(seconds: 5), notificationTitle, notificationBody);
      return GoOnlineResult.ok;
    } on BackendException catch (e) {
      return e.code == 'driver_not_approved' ? GoOnlineResult.notApproved : GoOnlineResult.failed;
    } finally {
      state = false;
    }
  }

  /// Faster updates while on a trip.
  void setOnTrip(
    bool onTrip, {
    required String notificationTitle,
    required String notificationBody,
  }) => _stream(Duration(seconds: onTrip ? 3 : 5), notificationTitle, notificationBody);

  void _stream(Duration interval, String title, String body) {
    _location.start(
      interval: interval,
      notificationTitle: title,
      notificationBody: body,
      onPosition: (p) {
        ref.read(lastPositionProvider.notifier).set(p);
        _backend.updateLocation(p.point, heading: p.heading, speedMps: p.speed).ignore();
      },
    );
  }

  Future<bool> goOffline() async {
    state = true;
    try {
      await _backend.setOnline(false);
      _location.stop();
      return true;
    } on BackendException {
      return false; // e.g. finish_active_ride_first
    } finally {
      state = false;
    }
  }
}

final onlineControllerProvider = NotifierProvider<OnlineController, bool>(OnlineController.new);

/// Ride the driver is currently on (set when an offer is accepted).
class ActiveRide extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

final activeRideProvider = NotifierProvider<ActiveRide, String?>(ActiveRide.new);
