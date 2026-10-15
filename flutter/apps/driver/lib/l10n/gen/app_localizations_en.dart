// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get placeholderBadge => 'Driver';

  @override
  String get placeholderFlowLabel => 'Driver · 00';

  @override
  String get placeholderTitle => 'Drive with iyodriver. Earn on your schedule.';

  @override
  String get placeholderSubtitle => 'Accept rides and rental handovers in Douala and Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Today\'s earnings: $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Local time (Douala): $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Payout number: $phone';
  }

  @override
  String get placeholderPrimary => 'Get started';

  @override
  String get placeholderSecondary => 'Switch to Français';
}
