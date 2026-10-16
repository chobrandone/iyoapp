import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // UI-only builds run without a Supabase project; data features need config/<env>.json.
  await initSupabase(IyoApp.driver);
  runApp(
    ProviderScope(
      overrides: driverOverrides,
      // Logo splash, matching the Android launch screen, before the first screen.
      child: const IyoSplash(
        logo: AssetImage('assets/images/logo.png'),
        background: Color(0xFFD9AC1D),
        label: 'iyodriver Driver',
        child: DriverApp(),
      ),
    ),
  );
}
