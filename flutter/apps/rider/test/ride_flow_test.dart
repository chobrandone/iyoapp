import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:rider/src/app.dart';
import 'package:rider/src/state/booking.dart';

const _fast = DemoTiming(
  matching: Duration(seconds: 2),
  tick: Duration(milliseconds: 200),
  approachTicks: 3,
  tripTicks: 3,
  waitAtPickup: Duration(seconds: 1),
);

/// Pumps 100 ms frames until [finder] matches (the simulation runs on timers).
Future<void> pumpUntil(WidgetTester tester, Finder finder, {int maxFrames = 100}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

void main() {
  late DemoBackend backend;

  Future<ProviderContainer> pumpSignedIn(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    backend = DemoBackend(timing: _fast);
    addTearDown(backend.dispose);
    // The demo backend simulates network latency; run sign-in on the real clock.
    await tester.runAsync(
      () => backend.verifyOtp(
        '+237671234567',
        demoOtpCode,
        signUp: const SignUpDetails(fullName: 'Aïcha Ngo Mbappe', role: AppRole.rider),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...riderOverrides, backendProvider.overrideWithValue(backend)],
        child: const RiderApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(RiderApp)));
  }

  Future<void> chooseTrip(WidgetTester tester, ProviderContainer c, String category) async {
    final booking = c.read(bookingProvider.notifier);
    booking.setPickup(doualaPlaces[4]); // 12 Rue Joss, Akwa
    booking.setDropoff(doualaPlaces[0]); // Gare de Bessengué
    await tester.pump(const Duration(seconds: 1));
    final options = c.read(bookingProvider).estimate!.options;
    booking.select(options.firstWhere((o) => o.categoryCode == category));
    c.read(routerProvider).go('/choose');
    await tester.pumpAndSettle();
  }

  testWidgets('book → match → arrive → trip → rate → home', (tester) async {
    final c = await pumpSignedIn(tester);
    expect(find.text('Where to, Aïcha?'), findsOneWidget);

    await chooseTrip(tester, c, 'standard');
    expect(find.text('Choose a ride'), findsOneWidget);
    // Upfront price from the placeholder formula, rounded to 50 FCFA.
    final fare = c.read(bookingProvider).selected!.fareAmount;
    expect(fare % 50, 0);

    await tester.tap(find.textContaining('Book Standard'));
    await pumpUntil(tester, find.text('Finding your driver'));
    await pumpUntil(tester, find.text('Jean-Paul is on the way'));
    expect(find.text('YOUR PICKUP PIN · 4826'), findsOneWidget);
    await pumpUntil(tester, find.text('Jean-Paul has arrived'));
    await pumpUntil(tester, find.text("You're on your way"));
    await pumpUntil(tester, find.text("You've arrived"));
    expect(find.text(formatFcfa(fare)), findsWidgets);

    await tester.tap(find.text('Submit rating & finish'));
    await tester.pumpAndSettle();
    expect(find.text('Where to, Aïcha?'), findsOneWidget);
    backend.dispose();
  });

  testWidgets('no XL drivers in Douala → no drivers screen', (tester) async {
    final c = await pumpSignedIn(tester);
    await chooseTrip(tester, c, 'xl');
    await tester.tap(find.textContaining('Book XL'));
    await pumpUntil(tester, find.text('No drivers nearby'));
    backend.dispose();
  });

  testWidgets('rider can cancel while the driver is on the way', (tester) async {
    final c = await pumpSignedIn(tester);
    await chooseTrip(tester, c, 'standard');
    await tester.tap(find.textContaining('Book Standard'));
    await pumpUntil(tester, find.text('Jean-Paul is on the way'));

    await tester.tap(find.text('View pickup details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel ride').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel ride').last);
    await tester.pumpAndSettle();
    expect(find.text('You cancelled this ride.'), findsOneWidget);
    backend.dispose();
  });
}
