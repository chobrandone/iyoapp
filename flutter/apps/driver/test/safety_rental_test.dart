import 'dart:async';

import 'package:driver/src/app.dart';
import 'package:driver/src/screens/onboarding_screens.dart';
import 'package:driver/src/state/driver_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

const _fast = DemoTiming(matching: Duration(seconds: 1), offerEvery: Duration(hours: 1));

class _FakeLocation extends DriverLocationService {
  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<DriverPosition?> current() async => const DriverPosition(GeoPoint(4.0511, 9.7679));

  @override
  void start({
    required Duration interval,
    required String notificationTitle,
    required String notificationBody,
    required void Function(DriverPosition) onPosition,
  }) {}
}

Future<void> pumpUntil(WidgetTester tester, Finder finder, {int maxFrames = 100}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

void main() {
  late DemoBackend backend;

  Future<GoRouter> pumpApproved(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    backend = DemoBackend(role: AppRole.driver, timing: _fast);
    addTearDown(backend.dispose);
    await tester.runAsync(
      () => backend.verifyOtp(
        '+237682334455',
        demoOtpCode,
        signUp: const SignUpDetails(fullName: 'Patrick Essomba', role: AppRole.driver),
      ),
    );
    backend.approveDemoDriver();
    var shot = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...driverOverrides,
          backendProvider.overrideWithValue(backend),
          driverLocationServiceProvider.overrideWithValue(_FakeLocation()),
          documentPickerProvider.overrideWithValue((_) async => '/tmp/photo${shot++}.jpg'),
        ],
        child: const DriverApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(DriverApp))).read(routerProvider);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final f = find.text(text).last;
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
    final e = tester.takeException();
    if (e != null) fail('after tapping "$text": $e');
  }

  testWidgets('airport rental: checklist photos, rider PIN, rental starts', (tester) async {
    final router = await pumpApproved(tester);
    router.go('/bookings');
    await tester.pumpAndSettle();
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('AIRPORT PICKUP · CONFIRMED'), findsOneWidget);
    await tapText(tester, 'View handover requirements');

    expect(find.text('Airport rental pickup'), findsOneWidget);
    expect(find.text('Airport pickup requirements'), findsOneWidget);
    await tapText(tester, 'Start the handover');

    expect(find.text('A smooth handover'), findsOneWidget);
    await tapText(tester, 'Vehicle condition photos');

    // Photo checklist: validation first, then the five sides and the odometer.
    await tapText(tester, 'Submit for rider confirmation');
    expect(find.text('All five photos are required.'), findsOneWidget);
    for (final side in ['Front', 'Back', 'Left side', 'Right side', 'Interior']) {
      await tapText(tester, side);
    }
    await tester.enterText(
      find.descendant(
        of: find.ancestor(of: find.text('Odometer (km)'), matching: find.byType(Column)).first,
        matching: find.byType(EditableText),
      ),
      '41200',
    );
    await tapText(tester, 'Submit for rider confirmation');
    await pumpUntil(tester, find.text('A smooth handover'));
    await pumpUntil(tester, find.textContaining('5 photos saved'));

    // Identity check, then the rider's handover PIN.
    await tapText(tester, 'Identity & licence checked');
    await tester.enterText(
      find.descendant(of: find.byType(IyoPinInput), matching: find.byType(EditableText)),
      '0000',
    );
    await tester.pump();
    await tapText(tester, 'Confirm handover & start rental');
    await pumpUntil(tester, find.text('Wrong PIN · 4 attempts left'));
    await tester.enterText(
      find.descendant(of: find.byType(IyoPinInput), matching: find.byType(EditableText)),
      demoHandoverPin,
    );
    await tester.pump();
    await tapText(tester, 'Confirm handover & start rental');
    await pumpUntil(tester, find.textContaining('WITH RIDER · UNTIL'));
    expect(find.text('Start return inspection'), findsOneWidget);
  });

  testWidgets('incident report: category required, then report sent', (tester) async {
    final router = await pumpApproved(tester);
    unawaited(router.push('/incident'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Send report');
    expect(find.text('Choose what happened.'), findsOneWidget);

    await tester.tap(find.byType(IyoSelectField<String>));
    await tester.pumpAndSettle();
    await tapText(tester, 'Damage to the vehicle');
    await tapText(tester, 'This is urgent');
    await tapText(tester, 'Send report');
    await pumpUntil(tester, find.text('Report sent'));
    expect(find.text('Damage to the vehicle'), findsOneWidget);
    expect(find.textContaining('keep your phone on'), findsOneWidget);
  });
}
