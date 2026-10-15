import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/dev.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../l10n/gen/app_localizations.dart';
import 'locale_controller.dart';
import 'screens/account_screens.dart';
import 'screens/auth_screens.dart';
import 'screens/ride_screens.dart';
import 'screens/safety_screens.dart';
import 'widgets/rider_widgets.dart';

/// Every screen built from the Figma frames, for the debug "All screens" index.
const List<(String, String)> designScreens = [
  ('/welcome', 'START · 01 · Welcome'),
  ('/sign-up', 'ACCOUNT · 05 · Sign up'),
  ('/verify', 'ACCOUNT · 06 · Verify'),
  ('/login', 'Log in (no frame attached)'),
  ('/home', 'RIDER · 01 · Home'),
  ('/plan', 'RIDER · 02 · Plan your ride'),
  ('/trip/arriving', 'RIDER · 05 · Driver on the way'),
  ('/trip/live', 'RIDER · 06 · On your way'),
  ('/trip/complete', 'RIDER · 07 · Arrived & rating'),
  ('/trip/chat', 'Chat with driver'),
  ('/trip/no-drivers', 'No drivers nearby'),
  ('/safety-alert', 'RIDER · SAFETY · Safety alert'),
  ('/safety-sent', 'RIDER · SAFETY SENT · Alert sent'),
  ('/activity', 'Your activity'),
  ('/account/notifications', 'Notifications'),
  ('/saved-places', 'Saved places'),
  ('/trusted-contacts', 'Trusted contacts'),
  ('/wallet', 'Wallet'),
  ('/support', 'iyodriver support'),
  ('/account', 'Account (interim, no frame attached)'),
];

final GoRouter router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
    GoRoute(path: '/verify', builder: (_, state) => VerifyScreen(phone: state.extra as String?)),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _TabsShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/safety', builder: (_, _) => const SafetyScreen(inTabs: true))],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (_, _) => const AccountScreen(),
              routes: [
                GoRoute(path: 'notifications', builder: (_, _) => const NotificationsScreen()),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/plan', builder: (_, _) => const PlanRideScreen()),
    GoRoute(path: '/trip/arriving', builder: (_, _) => const DriverArrivingScreen()),
    GoRoute(path: '/trip/live', builder: (_, _) => const OnYourWayScreen()),
    GoRoute(path: '/trip/complete', builder: (_, _) => const TripCompleteScreen()),
    GoRoute(path: '/trip/chat', builder: (_, _) => const TripChatScreen()),
    GoRoute(path: '/trip/no-drivers', builder: (_, _) => const NoDriversScreen()),
    GoRoute(path: '/safety-alert', builder: (_, _) => const SafetyScreen()),
    GoRoute(path: '/safety-sent', builder: (_, _) => const AlertSentScreen()),
    GoRoute(path: '/saved-places', builder: (_, _) => const SavedPlacesScreen()),
    GoRoute(path: '/trusted-contacts', builder: (_, _) => const TrustedContactsScreen()),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
    GoRoute(path: '/support', builder: (_, _) => const SupportChatScreen()),
    if (kDebugMode) ...[
      GoRoute(path: '/dev/screens', builder: (_, _) => const _ScreenIndex()),
      GoRoute(
        path: '/dev/components',
        builder:
            (context, _) => ComponentGallery(flowLabel: 'RIDER · DEV', onBack: () => context.pop()),
      ),
    ],
  ],
);

/// Home · Activity · Safety · Account.
class _TabsShell extends StatelessWidget {
  const _TabsShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final items = [
      IyoTabItem(key: '0', label: t.tabHome, icon: LucideIcons.house),
      IyoTabItem(key: '1', label: t.tabActivity, icon: LucideIcons.clock3),
      IyoTabItem(key: '2', label: t.tabSafety, icon: LucideIcons.shieldCheck),
      IyoTabItem(key: '3', label: t.tabAccount, icon: LucideIcons.userRound),
    ];
    return Scaffold(
      backgroundColor: IyoPalette.white,
      body: shell,
      bottomNavigationBar: IyoBottomTabBar(
        items: items,
        activeKey: '${shell.currentIndex}',
        onSelect: (key) {
          final index = int.parse(key);
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
    );
  }
}

/// Debug-only list of every screen, to review them against the Figma frames.
class _ScreenIndex extends StatelessWidget {
  const _ScreenIndex();

  @override
  Widget build(BuildContext context) {
    return IyoScreen(
      header: const IyoAppHeader(flowLabel: 'RIDER · DEV'),
      heading: IyoPageHeading(title: 'All screens', onBack: context.pop),
      children: [
        IyoCard(
          children: [
            for (final (path, name) in designScreens)
              IyoListRow(title: name, subtitle: path, onPressed: () => context.push(path)),
            IyoListRow(
              title: 'Component gallery',
              subtitle: '/dev/components',
              onPressed: () => context.push('/dev/components'),
            ),
          ],
        ),
      ],
    );
  }
}

class RiderApp extends ConsumerWidget {
  const RiderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'iyodriver',
      debugShowCheckedModeBanner: false,
      theme: const IyoTheme().toThemeData(),
      routerConfig: router,
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
