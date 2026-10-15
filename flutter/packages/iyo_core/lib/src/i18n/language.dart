import 'package:flutter/widgets.dart';

import '../../l10n/gen/common_localizations.dart';
import '../format/validators.dart';

/// Both apps ship English and French. Douala and Yaoundé are majority francophone, so French is
/// the fallback for any other device language.
const List<Locale> supportedLocales = [Locale('fr'), Locale('en')];
const Locale fallbackLocale = Locale('fr');

Locale resolveAppLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  for (final locale in deviceLocales ?? const <Locale>[]) {
    if (locale.languageCode == 'en' || locale.languageCode == 'fr') {
      return Locale(locale.languageCode);
    }
  }
  return fallbackLocale;
}

extension ValidationErrorText on ValidationError {
  String message(CommonLocalizations l10n) => switch (this) {
    ValidationError.phoneInvalid => l10n.validationPhoneInvalid,
    ValidationError.otpInvalid => l10n.validationOtpInvalid,
    ValidationError.pinInvalid => l10n.validationPinInvalid,
    ValidationError.required => l10n.validationRequired,
  };
}
