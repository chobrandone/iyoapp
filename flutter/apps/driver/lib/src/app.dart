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
import 'screens/bookings_screens.dart';
import 'screens/earnings_screens.dart';
import 'screens/home_screens.dart';
import 'screens/onboarding_screens.dart';
import 'screens/rental_screens.dart';
import 'screens/safety_screens.dart';
import 'screens/trip_screens.dart';
import 'widgets/driver_widgets.dart';

/// Overrides every driver ProviderScope needs (main, tests).
final driverOverrides = [appRoleProvider.overrideWithValue(AppRole.driver)];

/// Every screen built from the Figma frames (sample content), for the snapshot test, the
/// on-device capture and the debug index.
const List<(String, String)> designScreens = [
  ('/design/setup-identity', 'DRIVER SETUP · 01 · Identity and vehicle'),
  ('/design/setup-documents', 'DRIVER SETUP · 02 · Documents'),
  ('/design/home-offline', 'DRIVER · 01 · Home offline'),
  ('/design/home-online', 'DRIVER · 02 · Home online'),
  ('/design/request', 'DRIVER · 03 · New ride request'),
  ('/design/to-pickup', 'DRIVER · 04 · Head to rider'),
  ('/design/at-pickup', 'DRIVER · 05 · At the pickup'),
  ('/design/live', 'DRIVER · 06 · Drive to destination'),
  ('/design/rental-pickup', 'DRIVER RENTAL · 01 · Airport pickup'),
  ('/design/rental-handover', 'DRIVER RENTAL · 02 · Handover checklist'),
  ('/design/earnings', 'DRIVER · Earnings and payout history'),
  ('/design/payout', 'DRIVER · Payout details'),
  ('/design/bookings', 'DRIVER · Bookings and trip history'),
  ('/design/account', 'DRIVER · Account and vehicle'),
];

const _authRoutes = {'/welcome', '/login', '/sign-up', '/verify'};

/// Where a signed-in driver must be, given the verification status (spec §7: no tabs until
/// approved). Null = anywhere.
String? _gate(DriverAccount account, String path) {
  final inOnboarding = path.startsWith('/onboarding');
  if (account.status == VerificationStatus.approved) return null;
  final target = switch (account.status) {
    VerificationStatus.pending when !account.identityComplete || account.vehicle == null =>
      '/onboarding/identity',
    VerificationStatus.pending => '/onboarding/documents',
    _ => '/onboarding/status',
  };
  if (!inOnboarding) return target;
  // Allow moving between identity and documents while the application is still editable.
  final editable =
      account.status == VerificationStatus.pending ||
      account.status == VerificationStatus.actionNeeded;
  if (editable && path != '/onboarding/status') return null;
  return path == target ? null : target;
}

class _Refresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _Refresh();
  ref.listen(profileProvider, (_, _) => refresh.ping());
  ref.listen(driverAccountProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      final profile = ref.read(profileProvider);
      if (profile.isLoading) return null;
      final path = state.uri.path;
      final signedIn = profile.value != null;
      if (path.startsWith('/dev') || path.startsWith('/design')) return null;
      if (!signedIn) return _authRoutes.contains(path) ? null : '/welcome';
      if (_authRoutes.contains(path)) return '/home';
      final account = ref.read(driverAccountProvider).value;
      if (account == null) return null;
      return _gate(account, path);
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: '/verify',
        builder: (_, state) => VerifyScreen(args: state.extra! as VerifyArgs),
      ),
      GoRoute(path: '/onboarding/identity', builder: (_, _) => const IdentityVehicleScreen()),
      GoRoute(path: '/onboarding/documents', builder: (_, _) => const DocumentsScreen()),
      GoRoute(path: '/onboarding/status', builder: (_, _) => const VerificationStatusScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabsShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const DriverHomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/earnings', builder: (_, _) => const EarningsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/account', builder: (_, _) => const DriverAccountScreen())],
          ),
        ],
      ),
      // Design previews with the Figma sample content (no sign-in, no live data).
      GoRoute(
        path: '/design/home-offline',
        builder:
            (_, _) =>
                const _PreviewTabs(index: 0, child: DriverHomeScreen(preview: HomePreview.offline)),
      ),
      GoRoute(
        path: '/design/home-online',
        builder:
            (_, _) =>
                const _PreviewTabs(index: 0, child: DriverHomeScreen(preview: HomePreview.online)),
      ),
      GoRoute(path: '/design/request', builder: (_, _) => const RideRequestScreen()),
      GoRoute(
        path: '/design/setup-identity',
        builder: (_, _) => const IdentityVehicleScreen(preview: true),
      ),
      GoRoute(
        path: '/design/setup-documents',
        builder: (_, _) => const DocumentsScreen(preview: true),
      ),
      GoRoute(
        path: '/design/earnings',
        builder: (_, _) => const _PreviewTabs(index: 1, child: EarningsScreen(preview: true)),
      ),
      GoRoute(path: '/design/payout', builder: (_, _) => const PayoutDetailsScreen()),
      GoRoute(path: '/design/rental-pickup', builder: (_, _) => const RentalDeliveryScreen()),
      GoRoute(path: '/design/rental-handover', builder: (_, _) => const RentalHandoverScreen()),
      GoRoute(
        path: '/design/bookings',
        builder: (_, _) => const _PreviewTabs(index: 2, child: BookingsScreen(preview: true)),
      ),
      GoRoute(
        path: '/design/account',
        builder: (_, _) => const _PreviewTabs(index: 3, child: DriverAccountScreen(preview: true)),
      ),
      GoRoute(
        path: '/payout/:id',
        builder: (_, state) => PayoutDetailsScreen(payoutId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/design/to-pickup',
        builder: (_, _) => const TripPreview(status: RideStatus.driverArriving),
      ),
      GoRoute(
        path: '/design/at-pickup',
        builder: (_, _) => const TripPreview(status: RideStatus.driverArrived),
      ),
      GoRoute(
        path: '/design/live',
        builder: (_, _) => const TripPreview(status: RideStatus.inProgress),
      ),
      if (kDebugMode) GoRoute(path: '/dev/screens', builder: (_, _) => const _ScreenIndex()),
      GoRoute(
        path: '/incident',
        builder:
            (_, state) => IncidentReportScreen(
              rideId: state.uri.queryParameters['ride'],
              rentalBookingId: state.uri.queryParameters['rental'],
              rentalRef: state.uri.queryParameters['ref'],
            ),
        routes: [
          GoRoute(
            path: 'sent',
            builder: (_, state) => ReportSentScreen(args: state.extra as ReportSentArgs?),
          ),
        ],
      ),
      GoRoute(
        path: '/rental/:id',
        builder: (_, state) => RentalDeliveryScreen(bookingId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'handover',
            builder: (_, state) => RentalHandoverScreen(bookingId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'inspect/:type',
            builder:
                (_, state) => InspectionScreen(
                  bookingId: state.pathParameters['id']!,
                  type: InspectionType.fromValue(state.pathParameters['type']!),
                ),
          ),
        ],
      ),
      GoRoute(
        path: '/trip/:id',
        builder: (_, state) => DriverTripScreen(rideId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'chat',
            builder: (_, state) => DriverChatScreen(rideId: state.pathParameters['id']!),
          ),
        ],
      ),
      if (kDebugMode)
        GoRoute(
          path: '/dev/components',
          builder:
              (context, _) => ComponentGallery(
                flowLabel: 'DRIVER · DEV',
                badge: context.t.badge,
                onBack: () => context.pop(),
              ),
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Home · Earnings · Bookings · Account.
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

List<IyoTabItem> _tabItems(BuildContext context) {
  final t = context.t;
  return [
    IyoTabItem(key: '0', label: t.tabHome, icon: LucideIcons.house),
    IyoTabItem(key: '1', label: t.tabEarnings, icon: LucideIcons.clock3),
    IyoTabItem(key: '2', label: t.tabBookings, icon: LucideIcons.calendarDays),
    IyoTabItem(key: '3', label: t.tabAccount, icon: LucideIcons.userRound),
  ];
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
      header: const DriverHeader(flowLabel: 'DRIVER · DEV'),
      heading: IyoPageHeading(title: 'All screens', onBack: context.pop),
      children: [
        IyoCard(
          children: [
            for (final (path, name) in designScreens)
              IyoListRow(title: name, subtitle: path, onPressed: () => context.push(path)),
          ],
        ),
      ],
    );
  }
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'iyodriver Driver',
      debugShowCheckedModeBanner: false,
      theme: const IyoTheme().toThemeData(),
      routerConfig: ref.watch(routerProvider),
      // Driver frames: content blocks 14 apart.
      builder: (context, child) => IyoScreenDefaults(blockGap: 14, child: child!),
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
