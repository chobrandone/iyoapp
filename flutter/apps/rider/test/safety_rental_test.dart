import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:rider/src/app.dart';

const _fast = DemoTiming(matching: Duration(seconds: 1));

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

  GoRouter routerOf(ProviderContainer c) => c.read(routerProvider);

  Future<void> tapText(WidgetTester tester, String text) async {
    final f = find.text(text).last;
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
    final e = tester.takeException();
    if (e != null) fail('after tapping "$text": $e');
  }

  testWidgets('add a trusted contact, raise an alert, contact is texted', (tester) async {
    final c = await pumpSignedIn(tester);
    unawaited(routerOf(c).push('/trusted-contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Add someone you trust'), findsOneWidget);

    await tapText(tester, 'Add trusted contact');
    final fields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(EditableText),
    );
    await tester.enterText(fields.at(0), 'Mireille Ngo');
    await tester.enterText(fields.at(1), '699003352');
    await tester.enterText(fields.at(2), 'Sister');
    await tapText(tester, 'Save contact');
    expect(find.text('Mireille Ngo'), findsOneWidget);
    expect(find.text('Sister · +237 6 99 00 33 52'), findsOneWidget);
    expect(find.text('ALERTS ON'), findsOneWidget);

    unawaited(routerOf(c).push('/safety-alert'));
    await tester.pumpAndSettle();
    expect(find.text('NO ACTIVE TRIP'), findsOneWidget);
    expect(find.text('Mireille Ngo · +237 6 99 00 33 52'), findsOneWidget);
    await tapText(tester, 'Send security alert');
    await pumpUntil(tester, find.text('Mireille notified'));
    expect(find.text('Back to home'), findsOneWidget);
  });

  testWidgets('rent a car: book, pay, handover, active, return, deposit released', (tester) async {
    final c = await pumpSignedIn(tester);
    routerOf(c).go('/home?service=rent');
    await tester.pumpAndSettle();
    expect(find.text('A car for your plans'), findsOneWidget);
    // Default suggestion: tomorrow 10:00, three days.
    await tapText(tester, 'Corolla · ${formatFcfa(75000)} for 3 days');
    expect(find.text('Toyota Corolla'), findsOneWidget);
    await tapText(tester, 'Choose dates · ${formatFcfa(25000)} / day');

    expect(find.text('Make time for your plans'), findsOneWidget);
    expect(find.text('3 DAYS · ${formatFcfa(75000)} BASE PRICE'), findsOneWidget);
    await tapText(tester, 'Continue · 3 days');

    expect(find.text('Where should we meet?'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).last, 'Rue Joss, Akwa');
    await tapText(tester, 'Save pickup & review');

    expect(find.text('Ready for your getaway?'), findsOneWidget);
    final pay = find.widgetWithText(IyoButton, 'Confirm & pay ${formatFcfa(75000)}');
    expect(tester.widget<IyoButton>(pay).onPressed, isNull); // terms not accepted yet
    final terms = find.textContaining('I accept the rental terms');
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    await tester.tap(pay);
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntil(tester, find.text('Your car is booked'));
    await tapText(tester, 'View my rental');
    expect(find.text('Manage your rental'), findsOneWidget);

    // Payment, driver assignment, handover checklist and PIN at the car (simulated).
    await pumpUntil(tester, find.text('The keys are yours'));
    await tapText(tester, 'View return instructions');
    await tapText(tester, 'I’m returning the car');
    await pumpUntil(tester, find.text('INSPECTION COMPLETE'));
    await tapText(tester, 'Confirm return summary');
    await pumpUntil(tester, find.text('Deposit released in full'));

    routerOf(c).go('/activity');
    await tester.pumpAndSettle();
    expect(find.text('Toyota Corolla'), findsOneWidget);
  });
}
