import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/dev.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../l10n/gen/app_localizations.dart';
import 'home_placeholder_screen.dart';
import 'locale_controller.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePlaceholderScreen()),
    // Hidden component gallery; debug builds only.
    if (kDebugMode)
      GoRoute(
        path: '/dev/components',
        builder:
            (context, state) => Builder(
              builder:
                  (context) =>
                      ComponentGallery(flowLabel: 'RIDER · DEV', onBack: () => context.pop()),
            ),
      ),
  ],
);

class RiderApp extends ConsumerWidget {
  const RiderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'iyodriver',
      debugShowCheckedModeBanner: false,
      theme: const IyoTheme().toThemeData(),
      routerConfig: _router,
      locale: ref.watch(localeControllerProvider),
      supportedLocales: supportedLocales,
      localeListResolutionCallback: resolveAppLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        CommonLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
