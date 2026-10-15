import 'package:driver/src/app.dart';
import 'package:driver/src/screens/onboarding_screens.dart';
import 'package:driver/src/state/driver_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

const _fast = DemoTiming(
  review: Duration(seconds: 1),
  offerEvery: Duration(seconds: 1),
  offerWindow: Duration(seconds: 15),
);

/// Location without the platform plugin.
class _FakeLocation extends DriverLocationService {
  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<DriverPosition?> current() async => const DriverPosition(GeoPoint(4.0483, 9.7008));

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

/// The hidden input inside an OTP / PIN widget (earlier routes keep their own fields in the tree).
Finder codeField(Type input) =>
    find.descendant(of: find.byType(input), matching: find.byType(EditableText));

Finder field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(EditableText),
);

void main() {
  late DemoBackend backend;

  Future<void> pumpApp(WidgetTester tester, {Locale locale = const Locale('en', 'US')}) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    backend = DemoBackend(role: AppRole.driver, timing: _fast);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...driverOverrides,
          backendProvider.overrideWithValue(backend),
          driverLocationServiceProvider.overrideWithValue(_FakeLocation()),
          documentPickerProvider.overrideWithValue((_) async => '/tmp/doc.jpg'),
        ],
        child: const DriverApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  GoRouter routerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(DriverApp))).read(routerProvider);

  testWidgets('welcome follows a French device', (tester) async {
    await pumpApp(tester, locale: const Locale('fr', 'CM'));
    expect(find.text('Conduisez.\nGagnez.'), findsOneWidget);
    backend.dispose();
  });

  testWidgets('signed-out drivers cannot reach the tabs', (tester) async {
    await pumpApp(tester);
    routerOf(tester).go('/home');
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    backend.dispose();
  });

  testWidgets('sign up → onboarding → approval → online → ride → earnings', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Full name (as on your ID)'), 'Patrick Essomba');
    await tester.enterText(field('Mobile number'), '682334455');
    await tester.tap(find.text('Create account & verify'));
    await pumpUntil(tester, find.text('Check your messages'));
    await tester.enterText(codeField(IyoOtpInput), demoOtpCode);
    await pumpUntil(tester, find.text('Let’s get you road-ready'));

    // Verification gate: the tabs are not reachable yet.
    routerOf(tester).go('/home');
    await tester.pumpAndSettle();
    expect(find.text('Let’s get you road-ready'), findsOneWidget);

    // DRIVER SETUP · 01: validation, then a valid form.
    await tester.tap(find.text('Save & continue to documents'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a plate like LT 123 AB.'), findsOneWidget);
    await tester.enterText(field('Driving licence number'), 'LT-DL-552210');
    await tester.enterText(field('National ID card number (CNI)'), '445566778');
    await tester.enterText(field('Vehicle registration'), 'LT 777 ZZ');

    // Date of birth: the date picker in text-entry mode.
    await tester.ensureVisible(find.text('Date of birth'));
    await tester.tap(field('Date of birth'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '05/14/1991');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Vehicle make & model: one field, details in a sheet.
    await tester.tap(field('Vehicle make & model'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    Finder sheetField(String label) => find.descendant(
      of:
          find
              .ancestor(
                of: find.descendant(of: sheet, matching: find.text(label)),
                matching: find.byType(Column),
              )
              .first,
      matching: find.byType(EditableText),
    );
    await tester.enterText(sheetField('Make'), 'Toyota');
    await tester.enterText(sheetField('Model'), 'Corolla');
    await tester.enterText(sheetField('Year'), '2018');
    await tester.enterText(sheetField('Colour'), 'Blanc');
    await tester.tap(find.descendant(of: sheet, matching: find.text('Save')));
    await tester.pumpAndSettle();
    expect(find.text('Toyota Corolla · 2018 · Blanc'), findsWidgets);

    await tester.ensureVisible(find.text('Save & continue to documents'));
    await tester.tap(find.text('Save & continue to documents'));
    await pumpUntil(tester, find.text('A quick safety check'));

    // DRIVER SETUP · 02: the footer button always uploads the next document (camera stubbed).
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.textContaining('Upload ').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a photo'));
      await tester.pump();
      await pumpUntil(
        tester,
        find.byWidgetPredicate((w) => w is LinearProgressIndicator),
        maxFrames: 5,
      );
      await tester.pump(const Duration(seconds: 1));
    }
    await pumpUntil(tester, find.text('4 OF 4 DOCUMENTS READY'));
    await tester.tap(find.text('Submit for review'));
    await pumpUntil(tester, find.text('Under review'));

    // D7: simulated review approves after 1 s.
    await pumpUntil(tester, find.text("You're approved"), maxFrames: 30);
    await tester.tap(find.text('Start driving'));
    await pumpUntil(tester, find.text('You’re offline. Ready when you are.'));

    // DRIVER · 02 / 03: go online → a full-screen request with the countdown.
    await tester.tap(find.text('Go online'));
    await pumpUntil(tester, find.text('You’re online'));
    await pumpUntil(tester, find.text('A new ride nearby'), maxFrames: 40);
    expect(find.text('YOUR EST. EARNINGS'), findsOneWidget);
    await tester.tap(find.textContaining('Accept ride'));
    await pumpUntil(tester, find.text('I’ve arrived at pickup'));

    // DRIVER · 04 → 05: arrive, wrong PIN, right PIN.
    await tester.tap(find.text('I’ve arrived at pickup'));
    await pumpUntil(tester, find.text('Start ride'));
    await tester.enterText(codeField(IyoPinInput), '1111');
    await tester.pump();
    await tester.tap(find.text('Start ride'));
    await pumpUntil(tester, find.text('Wrong PIN · 4 attempts left'));
    await tester.enterText(codeField(IyoPinInput), demoPin);
    await tester.pump();
    await tester.tap(find.text('Start ride'));
    await pumpUntil(tester, find.text('End ride at destination'));

    // DRIVER · 06 → ride complete → home with today's earnings.
    await tester.tap(find.text('End ride at destination'));
    await pumpUntil(tester, find.text('Ride complete'));
    expect(find.text('Your earnings'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await pumpUntil(tester, find.text('You’re online'));
    await pumpUntil(tester, find.textContaining('1 trip ·'));

    await tester.tap(find.text('Go offline'));
    await pumpUntil(tester, find.text('You’re offline. Ready when you are.'));
    backend.dispose();
    await tester.pump(const Duration(seconds: 2));
  });
}
