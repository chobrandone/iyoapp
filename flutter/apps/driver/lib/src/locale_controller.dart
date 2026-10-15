import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The user's chosen language; null = follow the device (French fallback).
/// TODO(Phase 4): persist it and sync with profiles.language.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void set(Locale locale) => state = locale;
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
