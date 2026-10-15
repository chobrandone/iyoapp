// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class CommonLocalizationsFr extends CommonLocalizations {
  CommonLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get validationPhoneInvalid =>
      'Saisissez un numéro mobile camerounais valide (9 chiffres commençant par 6).';

  @override
  String get validationOtpInvalid => 'Saisissez le code à 6 chiffres.';

  @override
  String get validationPinInvalid => 'Saisissez le code PIN à 4 chiffres.';

  @override
  String get validationRequired => 'Ce champ est obligatoire.';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorOffline =>
      'Vous êtes hors ligne. Nous réessaierons dès le retour de la connexion.';

  @override
  String get languageEn => 'English';

  @override
  String get languageFr => 'Français';
}
