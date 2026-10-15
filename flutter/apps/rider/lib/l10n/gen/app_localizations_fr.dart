// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get placeholderFlowLabel => 'Passager · 00';

  @override
  String get placeholderTitle => 'Votre ville. À votre façon.';

  @override
  String get placeholderSubtitle => 'Courses et location de voitures à Douala et Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Exemple de tarif : $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Heure locale (Douala) : $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Ligne d\'assistance : $phone';
  }

  @override
  String get placeholderPrimary => 'Commencer';

  @override
  String get placeholderSecondary => 'Switch to English';
}
