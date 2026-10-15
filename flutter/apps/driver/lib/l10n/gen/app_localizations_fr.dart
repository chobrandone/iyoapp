// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get placeholderBadge => 'Chauffeur';

  @override
  String get placeholderFlowLabel => 'Chauffeur · 00';

  @override
  String get placeholderTitle => 'Conduisez avec iyodriver. Gagnez à votre rythme.';

  @override
  String get placeholderSubtitle => 'Acceptez des courses et des remises de véhicules à Douala et Yaoundé.';

  @override
  String placeholderSampleFare(String fare) {
    return 'Gains du jour : $fare';
  }

  @override
  String placeholderSampleTime(String time) {
    return 'Heure locale (Douala) : $time';
  }

  @override
  String placeholderSamplePhone(String phone) {
    return 'Numéro de paiement : $phone';
  }

  @override
  String get placeholderPrimary => 'Commencer';

  @override
  String get placeholderSecondary => 'Switch to English';
}
