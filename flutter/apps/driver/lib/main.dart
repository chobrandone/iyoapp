import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iyo_core/iyo_core.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // UI-only builds run without a Supabase project; data features need config/<env>.json.
  await initSupabase(IyoApp.driver);
  runApp(const ProviderScope(child: DriverApp()));
}
