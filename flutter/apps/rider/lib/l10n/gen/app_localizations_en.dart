// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get placeholderFlowLabel => 'Rider · 00';

  @override
  String get placeholderTitle => 'Your city. Your way.';

  @override
  String get placeholderSubtitle => 'Rides and car rentals across Douala and Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Sample fare: $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Local time (Douala): $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Support line: $phone';
  }

  @override
  String get placeholderPrimary => 'Get started';

  @override
  String get placeholderSecondary => 'Switch to Français';
}
