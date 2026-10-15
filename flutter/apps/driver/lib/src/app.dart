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
import 'screens/auth_screens.dart';
import 'screens/home_screens.dart';
import 'screens/onboarding_screens.dart';
import 'screens/rental_screens.dart';
import 'screens/safety_screens.dart';
import 'screens/trip_screens.dart';
import 'widgets/driver_widgets.dart';

/// Overrides every driver ProviderScope needs (main, tests).
final driverOverrides = [appRoleProvider.overrideWithValue(AppRole.driver)];

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
      if (path.startsWith('/dev')) return null;
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
    final t = context.t;
    return Scaffold(
      backgroundColor: IyoPalette.white,
      body: shell,
      bottomNavigationBar: IyoBottomTabBar(
        items: [
          IyoTabItem(key: '0', label: t.tabHome, icon: LucideIcons.house),
          IyoTabItem(key: '1', label: t.tabEarnings, icon: LucideIcons.wallet),
          IyoTabItem(key: '2', label: t.tabBookings, icon: LucideIcons.listChecks),
          IyoTabItem(key: '3', label: t.tabAccount, icon: LucideIcons.userRound),
        ],
        activeKey: '${shell.currentIndex}',
        onSelect: (key) {
          final index = int.parse(key);
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
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
