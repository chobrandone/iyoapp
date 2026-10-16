// Phone numbers across Africa: a country picker with dial codes, auto-detection from a typed
// or pasted "+236…" / "00236…", validation by national number length and E.164 storage.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

@immutable
class PhoneCountry {
  const PhoneCountry(this.iso, this.dial, this.nameEn, this.nameFr, this.lengths);

  /// ISO 3166-1 alpha-2, e.g. "CF".
  final String iso;

  /// Country calling code without "+", e.g. "236".
  final String dial;
  final String nameEn;
  final String nameFr;

  /// Accepted national number lengths (digits after the country code, no trunk 0).
  final List<int> lengths;

  String name(String languageCode) => languageCode == 'fr' ? nameFr : nameEn;

  /// Regional-indicator flag, e.g. 🇨🇫.
  String get flag =>
      String.fromCharCodes(iso.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41));

  @override
  bool operator ==(Object other) => other is PhoneCountry && other.iso == iso;

  @override
  int get hashCode => iso.hashCode;
}

/// Central African Republic, the launch market (Bangui).
const PhoneCountry centralAfricanRepublic = PhoneCountry(
  'CF',
  '236',
  'Central African Republic',
  'République centrafricaine',
  [8],
);
const PhoneCountry cameroon = PhoneCountry('CM', '237', 'Cameroon', 'Cameroun', [9]);

/// Every African country, CEMAC first, then alphabetical (English).
const List<PhoneCountry> africanCountries = [
  centralAfricanRepublic,
  cameroon,
  PhoneCountry('TD', '235', 'Chad', 'Tchad', [8]),
  PhoneCountry('CG', '242', 'Congo', 'Congo', [9]),
  PhoneCountry('GA', '241', 'Gabon', 'Gabon', [7, 8]),
  PhoneCountry('GQ', '240', 'Equatorial Guinea', 'Guinée équatoriale', [9]),
  PhoneCountry('DZ', '213', 'Algeria', 'Algérie', [9]),
  PhoneCountry('AO', '244', 'Angola', 'Angola', [9]),
  PhoneCountry('BJ', '229', 'Benin', 'Bénin', [8, 10]),
  PhoneCountry('BW', '267', 'Botswana', 'Botswana', [7, 8]),
  PhoneCountry('BF', '226', 'Burkina Faso', 'Burkina Faso', [8]),
  PhoneCountry('BI', '257', 'Burundi', 'Burundi', [8]),
  PhoneCountry('CV', '238', 'Cape Verde', 'Cap-Vert', [7]),
  PhoneCountry('KM', '269', 'Comoros', 'Comores', [7]),
  PhoneCountry('CD', '243', 'DR Congo', 'RD Congo', [9]),
  PhoneCountry('CI', '225', 'Côte d’Ivoire', 'Côte d’Ivoire', [10]),
  PhoneCountry('DJ', '253', 'Djibouti', 'Djibouti', [8]),
  PhoneCountry('EG', '20', 'Egypt', 'Égypte', [10]),
  PhoneCountry('ER', '291', 'Eritrea', 'Érythrée', [7]),
  PhoneCountry('SZ', '268', 'Eswatini', 'Eswatini', [8]),
  PhoneCountry('ET', '251', 'Ethiopia', 'Éthiopie', [9]),
  PhoneCountry('GM', '220', 'Gambia', 'Gambie', [7]),
  PhoneCountry('GH', '233', 'Ghana', 'Ghana', [9]),
  PhoneCountry('GN', '224', 'Guinea', 'Guinée', [9]),
  PhoneCountry('GW', '245', 'Guinea-Bissau', 'Guinée-Bissau', [7, 9]),
  PhoneCountry('KE', '254', 'Kenya', 'Kenya', [9]),
  PhoneCountry('LS', '266', 'Lesotho', 'Lesotho', [8]),
  PhoneCountry('LR', '231', 'Liberia', 'Libéria', [8, 9]),
  PhoneCountry('LY', '218', 'Libya', 'Libye', [9]),
  PhoneCountry('MG', '261', 'Madagascar', 'Madagascar', [9]),
  PhoneCountry('MW', '265', 'Malawi', 'Malawi', [9]),
  PhoneCountry('ML', '223', 'Mali', 'Mali', [8]),
  PhoneCountry('MR', '222', 'Mauritania', 'Mauritanie', [8]),
  PhoneCountry('MU', '230', 'Mauritius', 'Maurice', [8]),
  PhoneCountry('MA', '212', 'Morocco', 'Maroc', [9]),
  PhoneCountry('MZ', '258', 'Mozambique', 'Mozambique', [9]),
  PhoneCountry('NA', '264', 'Namibia', 'Namibie', [9]),
  PhoneCountry('NE', '227', 'Niger', 'Niger', [8]),
  PhoneCountry('NG', '234', 'Nigeria', 'Nigéria', [10]),
  PhoneCountry('RW', '250', 'Rwanda', 'Rwanda', [9]),
  PhoneCountry('ST', '239', 'São Tomé and Príncipe', 'Sao Tomé-et-Principe', [7]),
  PhoneCountry('SN', '221', 'Senegal', 'Sénégal', [9]),
  PhoneCountry('SC', '248', 'Seychelles', 'Seychelles', [7]),
  PhoneCountry('SL', '232', 'Sierra Leone', 'Sierra Leone', [8]),
  PhoneCountry('SO', '252', 'Somalia', 'Somalie', [8, 9]),
  PhoneCountry('ZA', '27', 'South Africa', 'Afrique du Sud', [9]),
  PhoneCountry('SS', '211', 'South Sudan', 'Soudan du Sud', [9]),
  PhoneCountry('SD', '249', 'Sudan', 'Soudan', [9]),
  PhoneCountry('TZ', '255', 'Tanzania', 'Tanzanie', [9]),
  PhoneCountry('TG', '228', 'Togo', 'Togo', [8]),
  PhoneCountry('TN', '216', 'Tunisia', 'Tunisie', [8]),
  PhoneCountry('UG', '256', 'Uganda', 'Ouganda', [9]),
  PhoneCountry('ZM', '260', 'Zambia', 'Zambie', [9]),
  PhoneCountry('ZW', '263', 'Zimbabwe', 'Zimbabwe', [9]),
];

PhoneCountry? countryByIso(String iso) {
  final up = iso.toUpperCase();
  for (final c in africanCountries) {
    if (c.iso == up) return c;
  }
  return null;
}

/// The country whose dial code starts [digits] ("236751…" → CF), longest code first.
PhoneCountry? countryForDigits(String digits) {
  PhoneCountry? best;
  for (final c in africanCountries) {
    if (digits.startsWith(c.dial) && (best == null || c.dial.length > best.dial.length)) best = c;
  }
  return best;
}

/// The phone's region when it is African (fr_CF → CF), else the Central African Republic.
PhoneCountry defaultPhoneCountry({String? localeName}) {
  String locale;
  try {
    locale = localeName ?? Platform.localeName;
  } catch (_) {
    locale = '';
  }
  final region = RegExp(r'[_-]([A-Za-z]{2})\b').firstMatch(locale)?.group(1);
  return (region == null ? null : countryByIso(region)) ?? centralAfricanRepublic;
}

/// A number split into its country and national digits.
@immutable
class ParsedPhone {
  const ParsedPhone(this.country, this.national);

  final PhoneCountry country;

  /// Digits after the country code, without the trunk 0.
  final String national;

  bool get isValid => country.lengths.contains(national.length);

  String get e164 => '+${country.dial}$national';
}

/// Reads what the person typed. "+236 75 12 34 56" or "00236…" picks the country from the
/// number; anything else is national digits for [country].
ParsedPhone parsePhone(String input, {PhoneCountry? country}) {
  final raw = input.trim();
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final international = raw.startsWith('+') || digits.startsWith('00');
  if (international) {
    final rest = digits.startsWith('00') ? digits.substring(2) : digits;
    final detected = countryForDigits(rest);
    if (detected != null) {
      return ParsedPhone(detected, _dropTrunk(rest.substring(detected.dial.length), detected));
    }
  }
  final c = country ?? defaultPhoneCountry();
  // Typed with the code but no "+": "237 6 71 23 45 67" or "236 75 12 34 56". Only when the
  // digits are too long for the chosen country and fit the detected one exactly.
  if (!c.lengths.contains(digits.length) && !c.lengths.contains(digits.length - 1)) {
    final detected = countryForDigits(digits);
    if (detected != null && detected.lengths.contains(digits.length - detected.dial.length)) {
      return ParsedPhone(detected, digits.substring(detected.dial.length));
    }
  }
  return ParsedPhone(c, _dropTrunk(digits, c));
}

/// Some countries write a trunk 0 nationally ("0751…"); it is not part of the E.164 number.
String _dropTrunk(String national, PhoneCountry c) =>
    national.startsWith('0') && !c.lengths.contains(national.length)
        ? national.substring(1)
        : national;

bool isValidPhone(String input, {PhoneCountry? country}) =>
    parsePhone(input, country: country).isValid;

/// `"75 12 34 56"` (CF) → `"+23675123456"`. Null when the length is wrong for the country.
String? toE164(String input, {PhoneCountry? country}) {
  final p = parsePhone(input, country: country);
  return p.isValid ? p.e164 : null;
}

/// The national digits grouped in pairs: 9 digits as "6 71 23 45 67", 8 as "75 12 34 56".
String groupNational(String national) {
  if (national.length.isOdd) {
    final pairs = RegExp(r'.{2}').allMatches(national.substring(1)).map((m) => m[0]).join(' ');
    return '${national[0]} $pairs';
  }
  return RegExp(r'.{2}').allMatches(national).map((m) => m[0]).join(' ');
}

/// Display format, e.g. `+236 75 12 34 56` or `+237 6 71 23 45 67`. Numbers without a code
/// are read for [country]; anything unreadable is returned as typed.
String formatPhone(String input, {PhoneCountry? country}) {
  final p = parsePhone(input, country: country ?? _countryOf(input));
  if (!p.isValid) return input;
  return '+${p.country.dial} ${groupNational(p.national)}';
}

/// Bare national numbers in old data are Cameroonian (9 digits starting with 6).
PhoneCountry? _countryOf(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (input.trim().startsWith('+')) return null;
  if (RegExp(r'^6\d{8}$').hasMatch(digits)) return cameroon;
  return null;
}
