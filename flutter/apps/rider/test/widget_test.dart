import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rider/src/app.dart';

Future<void> pumpApp(WidgetTester tester, Locale locale) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(ProviderScope(overrides: riderOverrides, child: const RiderApp()));
  await tester.pumpAndSettle();
}

GoRouter routerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(RiderApp))).read(routerProvider);

Finder field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(EditableText),
);

void main() {
  testWidgets('welcome follows a French device', (tester) async {
    await pumpApp(tester, const Locale('fr', 'CM'));
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('signed-out riders are sent to welcome', (tester) async {
    await pumpApp(tester, const Locale('en', 'US'));
    routerOf(tester).go('/home');
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('sign up → SMS code (demo) → home tabs', (tester) async {
    await pumpApp(tester, const Locale('en', 'US'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Validation: nothing entered yet.
    await tester.tap(find.text('Create account & verify'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);

    await tester.enterText(field('Full name'), 'Aïcha Ngo Mbappe');
    await tester.enterText(field('Mobile number'), '6 71 23 45 67');
    await tester.tap(find.text('Create account & verify'));
    await tester.pumpAndSettle();
    expect(find.text('Check your messages'), findsOneWidget);
    expect(find.textContaining('123456'), findsOneWidget); // demo hint

    await tester.enterText(find.byType(EditableText).first, '000000');
    await tester.pumpAndSettle();
    expect(find.textContaining('not right'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, '123456');
    await tester.pumpAndSettle();
    expect(find.text('Where to, Aïcha?'), findsOneWidget);

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Your activity'), findsOneWidget);
  });

  testWidgets('every design screen builds without overflow', (tester) async {
    await pumpApp(tester, const Locale('en', 'US'));
    for (final (path, _) in designScreens) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
    }
  });
}
