import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iyo_core/iyo_core.dart';

/// Result of asking for the rider's position (foreground only, per the spec).
sealed class LocationState {
  const LocationState();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationFound extends LocationState {
  const LocationFound(this.point);
  final GeoPoint point;
}

/// Permission denied or services off: the rider types the pickup instead.
class LocationUnavailable extends LocationState {
  const LocationUnavailable({required this.permanently});
  final bool permanently;
}

/// Douala (Akwa) — used when location is unavailable.
const GeoPoint doualaDefault = GeoPoint(4.0469, 9.6953);

class LocationController extends AsyncNotifier<LocationState> {
  @override
  Future<LocationState> build() => _locate();

  Future<LocationState> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationUnavailable(permanently: false);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationUnavailable(permanently: true);
      }
      if (permission == LocationPermission.denied) {
        return const LocationUnavailable(permanently: false);
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationFound(GeoPoint(p.latitude, p.longitude));
    } on Exception {
      // Plugin missing in tests, timeout, etc.: fall back to typing the pickup.
      return const LocationUnavailable(permanently: false);
    }
  }

  Future<void> retry() async {
    state = const AsyncData(LocationLoading());
    state = AsyncData(await _locate());
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}

final locationProvider = AsyncNotifierProvider<LocationController, LocationState>(
  LocationController.new,
);
