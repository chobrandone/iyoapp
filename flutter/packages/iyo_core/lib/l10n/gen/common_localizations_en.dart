// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'common_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CommonLocalizationsEn extends CommonLocalizations {
  CommonLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionBack => 'Back';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDone => 'Done';

  @override
  String get validationPhoneInvalid => 'Enter a valid mobile number for the selected country.';

  @override
  String get validationOtpInvalid => 'Enter the 6-digit code.';

  @override
  String get validationPinInvalid => 'Enter the 4-digit PIN.';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorOffline => 'You\'re offline. We\'ll retry when you\'re back online.';

  @override
  String get languageEn => 'English';

  @override
  String get languageFr => 'Français';
}
