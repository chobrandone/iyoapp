import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_setup.dart';

bool _started = false;

/// Keeps this device's Firebase token in public.push_tokens while someone is signed in, so the
/// server can reach the app in the background. Android only (no iOS Firebase app yet); demo
/// builds skip it. Notifications are optional: a failure here never affects the app.
Future<void> startPushNotifications(IyoApp app) async {
  if (_started || !SupabaseEnv.isConfigured || kIsWeb || !Platform.isAndroid) return;
  _started = true;
  try {
    await Firebase.initializeApp();
    final db = Supabase.instance.client;

    Future<void> save(String token) async {
      final user = db.auth.currentUser;
      if (user == null) return;
      await db.from('push_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'app': app.name,
        'platform': 'android',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    }

    Future<void> register() async {
      try {
        await FirebaseMessaging.instance.requestPermission();
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) await save(token);
      } catch (e) {
        debugPrint('Push registration failed: $e');
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((t) => unawaited(save(t).catchError(_log)));
    db.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.initialSession && state.session != null) {
        unawaited(register());
      }
    });
  } catch (e) {
    debugPrint('Push setup failed: $e');
  }
}

/// Call before signing out: the next person on this phone must not get this account's pushes.
Future<void> forgetPushToken() async {
  if (!_started) return;
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await Supabase.instance.client.from('push_tokens').delete().eq('token', token);
    }
  } catch (e) {
    debugPrint('Push token removal failed: $e');
  }
}

void _log(Object e) => debugPrint('Push token update failed: $e');
