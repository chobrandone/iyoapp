/// FCFA (XAF) has no minor unit in practice. Amounts are integers, grouped by thousands
/// with a non-breaking space so "2 500 FCFA" never wraps mid-number.
const String _nbsp = ' ';

String formatNumberGrouped(num value) {
  final rounded = value.round();
  final sign = rounded < 0 ? '-' : '';
  final digits = rounded.abs().toString();
  final grouped = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => _nbsp);
  return '$sign$grouped';
}

/// `formatFcfa(2500)` → `"2 500 FCFA"`.
String formatFcfa(num amount) => '${formatNumberGrouped(amount)}${_nbsp}FCFA';

/// Rounds to the nearest 50 FCFA, the fare granularity used by pricing.
int roundToNearest50(num amount) => (amount / 50).round() * 50;
