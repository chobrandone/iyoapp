import 'phone.dart';

/// Validation results are error keys; screens translate them with CommonLocalizations.
enum ValidationError { phoneInvalid, otpInvalid, pinInvalid, required }

ValidationError? validatePhone(String? value, {PhoneCountry? country}) =>
    value != null && isValidPhone(value, country: country) ? null : ValidationError.phoneInvalid;

ValidationError? validateOtp(String? value) =>
    value != null && RegExp(r'^\d{6}$').hasMatch(value) ? null : ValidationError.otpInvalid;

ValidationError? validatePin(String? value) =>
    value != null && RegExp(r'^\d{4}$').hasMatch(value) ? null : ValidationError.pinInvalid;

ValidationError? validateRequired(String? value) =>
    value == null || value.trim().isEmpty ? ValidationError.required : null;
