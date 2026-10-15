import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iyo_core/iyo_core.dart';

/// Douala (Akwa), used until the first fix arrives.
const GeoPoint doualaDefault = GeoPoint(4.0483, 9.7008);

@immutable
class DriverPosition {
  const DriverPosition(this.point, {this.heading = 0, this.speed});

  final GeoPoint point;
  final double heading;
  final double? speed;
}

/// Location for the driver app: foreground + background while online or on a trip (spec §7),
/// nothing while offline. On Android the stream runs in a foreground service with a persistent
/// "You're online" notification.
class DriverLocationService {
  StreamSubscription<Position>? _sub;

  /// Asks for "while in use" then "always" permission. Returns false if refused.
  Future<bool> ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.whileInUse) {
        // Background updates need "always"; the OS may show its own settings page.
        p = await Geolocator.requestPermission();
      }
      return p == LocationPermission.always || p == LocationPermission.whileInUse;
    } on Exception {
      return false;
    }
  }

  Future<DriverPosition?> current() async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return DriverPosition(GeoPoint(p.latitude, p.longitude), heading: p.heading, speed: p.speed);
    } on Exception {
      return null;
    }
  }

  /// Streams positions every [interval] (5 s online, 3 s on a trip).
  void start({
    required Duration interval,
    required String notificationTitle,
    required String notificationBody,
    required void Function(DriverPosition) onPosition,
  }) {
    stop();
    final LocationSettings settings =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
              intervalDuration: interval,
              foregroundNotificationConfig: ForegroundNotificationConfig(
                notificationTitle: notificationTitle,
                notificationText: notificationBody,
                enableWakeLock: true,
                setOngoing: true,
              ),
            )
            : AppleSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
              activityType: ActivityType.automotiveNavigation,
              pauseLocationUpdatesAutomatically: false,
              showBackgroundLocationIndicator: true,
              allowBackgroundLocationUpdates: true,
            );
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (p) => onPosition(
        DriverPosition(GeoPoint(p.latitude, p.longitude), heading: p.heading, speed: p.speed),
      ),
      onError: (_) {},
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}

final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  final s = DriverLocationService();
  ref.onDispose(s.stop);
  return s;
});

/// Last known driver position (for the map).
class LastPosition extends Notifier<DriverPosition> {
  @override
  DriverPosition build() => const DriverPosition(doualaDefault);

  void set(DriverPosition p) => state = p;

  DriverPosition get current => state;
}

final lastPositionProvider = NotifierProvider<LastPosition, DriverPosition>(LastPosition.new);
