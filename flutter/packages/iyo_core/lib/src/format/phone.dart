/// Cameroon (+237) mobile numbers: 9 digits starting with 6 (MTN, Orange, Nexttel, Camtel).
const String cmCountryCode = '237';
final RegExp _cmMobile = RegExp(r'^6\d{8}$');

/// Strips spaces/dashes and a leading +237 / 00237 / 237, returning the 9-digit national number.
String toNationalNumber(String input) {
  final digits = input.replaceAll(RegExp(r'[^\d+]'), '');
  return digits
      .replaceFirst(RegExp(r'^(\+|00)?237(?=\d{9}$)'), '')
      .replaceFirst(RegExp(r'^\+'), '');
}

bool isCameroonMobile(String input) => _cmMobile.hasMatch(toNationalNumber(input));

/// `"6 71 23 45 67"` → `"+237671234567"`. Returns null if not a valid mobile.
String? toE164(String input) {
  final national = toNationalNumber(input);
  return _cmMobile.hasMatch(national) ? '+$cmCountryCode$national' : null;
}

/// Display format: `+237 6 71 23 45 67`. Falls back to the raw input if invalid.
String formatPhone(String input) {
  final national = toNationalNumber(input);
  if (!_cmMobile.hasMatch(national)) return input;
  final rest = RegExp(r'.{2}').allMatches(national.substring(1)).map((m) => m[0]).join(' ');
  return '+$cmCountryCode ${national[0]} $rest';
}
