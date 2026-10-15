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
import 'screens/auth_flow_screens.dart';
import 'screens/auth_screens.dart';
import 'screens/rental_screens.dart';
import 'screens/ride_screens.dart';
import 'screens/safety_screens.dart';
import 'screens/trip_view.dart';
import 'widgets/rider_widgets.dart';

/// Overrides every rider ProviderScope needs (main, tests).
final riderOverrides = [appRoleProvider.overrideWithValue(AppRole.rider)];

/// Every screen built from the Figma frames (sample content), for the debug "All screens" index,
/// the snapshot test and the on-device capture.
const List<(String, String)> designScreens = [
  ('/welcome', 'START · 01 · Welcome'),
  ('/sign-up', 'ACCOUNT · 05 · Sign up'),
  ('/design/verify', 'ACCOUNT · 06 · Verify'),
  ('/login', 'Log in (no frame attached)'),
  ('/design/home', 'RIDER · 01 · Home'),
  ('/design/plan', 'RIDER · 02 · Plan your ride'),
  ('/trip/arriving', 'RIDER · 05 · Driver on the way'),
  ('/trip/live', 'RIDER · 06 · On your way'),
  ('/trip/complete', 'RIDER · 07 · Arrived & rating'),
  ('/trip/chat', 'Chat with driver'),
  ('/trip/no-drivers', 'No drivers nearby'),
  ('/design/safety-alert', 'RIDER · SAFETY · Safety alert'),
  ('/design/safety-sent', 'RIDER · SAFETY SENT · Alert sent'),
  ('/design/activity', 'Your activity'),
  ('/design/notifications', 'Notifications'),
  ('/saved-places', 'Saved places'),
  ('/design/trusted-contacts', 'Trusted contacts'),
  ('/wallet', 'Wallet'),
  ('/support', 'iyodriver support'),
  ('/design/account', 'Account (interim, no frame attached)'),
];

const _authRoutes = {'/welcome', '/login', '/sign-up', '/verify'};

/// Routes that need a signed-in rider.
bool _needsAuth(String path) => const [
  '/home',
  '/activity',
  '/safety',
  '/account',
  '/plan',
  '/choose',
  '/ride',
  '/safety-alert',
  '/safety-sent',
  '/trusted-contacts',
  '/rent',
  '/rentals',
].any((p) => path == p || path.startsWith('$p/'));

/// Re-runs the redirect when the signed-in profile changes.
class _AuthRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.listen(profileProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      final profile = ref.read(profileProvider);
      if (profile.isLoading) return null;
      final signedIn = profile.value != null;
      final path = state.uri.path;
      if (!signedIn && _needsAuth(path)) return '/welcome';
      if (signedIn && _authRoutes.contains(path)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: '/verify',
        builder: (_, state) => VerifyScreen(args: state.extra as VerifyArgs?),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabsShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen(live: true)),
            ],
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
      GoRoute(path: '/choose', builder: (_, _) => const ChooseRideScreen()),
      GoRoute(
        path: '/ride/:id',
        builder: (_, state) => RideFlowScreen(rideId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'chat',
            builder: (_, state) => TripChatScreen(rideId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/rent',
        builder: (_, _) => const RentBrowseScreen(),
        routes: [
          GoRoute(path: 'car', builder: (_, _) => const RentalCarScreen()),
          GoRoute(path: 'dates', builder: (_, _) => const RentalDatesScreen()),
          GoRoute(path: 'review', builder: (_, _) => const RentalReviewScreen()),
        ],
      ),
      GoRoute(
        path: '/rentals',
        builder: (_, _) => const MyRentalsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => RentalBookingScreen(bookingId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/safety-alert',
        builder: (_, state) => SafetyScreen(rideId: state.uri.queryParameters['ride']),
      ),
      GoRoute(
        path: '/safety-sent',
        builder: (_, state) => AlertSentScreen(args: state.extra as AlertSentArgs?),
      ),
      GoRoute(path: '/saved-places', builder: (_, _) => const SavedPlacesScreen()),
      GoRoute(path: '/trusted-contacts', builder: (_, _) => const TrustedContactsScreen()),
      GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
      GoRoute(path: '/support', builder: (_, _) => const SupportChatScreen()),
      // Design previews with the Figma sample content (no sign-in, no live data).
      GoRoute(path: '/design/safety-alert', builder: (_, _) => const SafetyScreen(preview: true)),
      GoRoute(path: '/design/safety-sent', builder: (_, _) => const AlertSentScreen()),
      GoRoute(
        path: '/design/trusted-contacts',
        builder: (_, _) => const TrustedContactsScreen(preview: true),
      ),
      GoRoute(path: '/design/verify', builder: (_, _) => const VerifyScreen()),
      GoRoute(
        path: '/design/home',
        builder: (_, _) => const _PreviewTabs(index: 0, child: HomeScreen(preview: true)),
      ),
      GoRoute(path: '/design/plan', builder: (_, _) => const PlanRideScreen(preview: true)),
      GoRoute(
        path: '/design/activity',
        builder: (_, _) => const _PreviewTabs(index: 1, child: ActivityScreen()),
      ),
      GoRoute(
        path: '/design/notifications',
        builder: (_, _) => const _PreviewTabs(index: 3, child: NotificationsScreen()),
      ),
      GoRoute(
        path: '/design/account',
        builder: (_, _) => const _PreviewTabs(index: 3, child: AccountScreen()),
      ),
      GoRoute(
        path: '/trip/arriving',
        builder: (context, _) => DriverArrivingView(view: TripView.sample(context)),
      ),
      GoRoute(
        path: '/trip/live',
        builder: (context, _) => OnYourWayView(view: TripView.sample(context)),
      ),
      GoRoute(
        path: '/trip/complete',
        builder: (context, _) => TripCompleteView(view: TripView.sample(context)),
      ),
      GoRoute(path: '/trip/chat', builder: (_, _) => const TripChatScreen()),
      GoRoute(
        path: '/trip/no-drivers',
        builder: (context, _) => NoDriversView(view: TripView.sample(context)),
      ),
      if (kDebugMode) ...[
        GoRoute(path: '/dev/screens', builder: (_, _) => const _ScreenIndex()),
        GoRoute(
          path: '/dev/components',
          builder:
              (context, _) =>
                  ComponentGallery(flowLabel: 'RIDER · DEV', onBack: () => context.pop()),
        ),
      ],
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

List<IyoTabItem> _tabItems(BuildContext context) {
  final t = context.t;
  return [
    IyoTabItem(key: '0', label: t.tabHome, icon: LucideIcons.house),
    IyoTabItem(key: '1', label: t.tabActivity, icon: LucideIcons.clock3),
    IyoTabItem(key: '2', label: t.tabSafety, icon: LucideIcons.shieldCheck),
    IyoTabItem(key: '3', label: t.tabAccount, icon: LucideIcons.userRound),
  ];
}

/// Home · Activity · Safety · Account.
class _TabsShell extends StatelessWidget {
  const _TabsShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IyoPalette.white,
      body: shell,
      bottomNavigationBar: IyoBottomTabBar(
        items: _tabItems(context),
        activeKey: '${shell.currentIndex}',
        onSelect: (key) {
          final index = int.parse(key);
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
    );
  }
}

/// Static tab bar around a design preview.
class _PreviewTabs extends StatelessWidget {
  const _PreviewTabs({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: IyoPalette.white,
    body: child,
    bottomNavigationBar: IyoBottomTabBar(
      items: _tabItems(context),
      activeKey: '$index',
      onSelect: (_) {},
    ),
  );
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
      routerConfig: ref.watch(routerProvider),
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
