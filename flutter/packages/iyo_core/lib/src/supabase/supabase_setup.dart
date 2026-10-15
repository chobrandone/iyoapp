import 'package:supabase_flutter/supabase_flutter.dart';

/// Values compiled into each app with `--dart-define-from-file=config/<env>.json`.
/// Only the public publishable (formerly "anon") key belongs here — never the service-role key.
class SupabaseEnv {
  const SupabaseEnv._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

/// Which app is running; sent as x-client-info so server logs can tell them apart.
enum IyoApp { rider, driver }

/// Initialises Supabase once, before runApp. Sessions are persisted by supabase_flutter
/// (shared_preferences); refresh tokens are short-lived and rotated by Supabase Auth.
/// Returns false when no Supabase project is configured yet (UI-only builds).
Future<bool> initSupabase(IyoApp app) async {
  if (!SupabaseEnv.isConfigured) return false;
  await Supabase.initialize(
    url: SupabaseEnv.url,
    publishableKey: SupabaseEnv.publishableKey,
    headers: {'x-client-info': 'iyodriver-${app.name}-flutter'},
    authOptions: const FlutterAuthClientOptions(detectSessionInUri: false),
  );
  return true;
}
