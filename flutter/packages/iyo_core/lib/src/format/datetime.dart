/// All user-facing dates use Africa/Douala (WAT, UTC+01:00, no daylight saving).
/// The fixed offset is applied manually so output does not depend on the device's time zone.
const String appTimeZone = 'Africa/Douala';
const Duration _doualaOffset = Duration(hours: 1);

String _pad(int n) => n.toString().padLeft(2, '0');

DateTime _toDouala(DateTime input) => input.toUtc().add(_doualaOffset);

/// `DD/MM/YYYY` in Africa/Douala.
String formatDate(DateTime input) {
  final d = _toDouala(input);
  return '${_pad(d.day)}/${_pad(d.month)}/${d.year}';
}

/// 24-hour `HH:mm` in Africa/Douala.
String formatTime(DateTime input) {
  final d = _toDouala(input);
  return '${_pad(d.hour)}:${_pad(d.minute)}';
}

/// `DD/MM/YYYY HH:mm` in Africa/Douala.
String formatDateTime(DateTime input) => '${formatDate(input)} ${formatTime(input)}';

/// `mm:ss` countdown/timer label, e.g. wait time `01:24`.
String formatDuration(num totalSeconds) {
  final s = totalSeconds.floor() < 0 ? 0 : totalSeconds.floor();
  return '${_pad(s ~/ 60)}:${_pad(s % 60)}';
}

/// Distances are always kilometres: `850 m`, `4.2 km`.
String formatDistance(num meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
