import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider/src/app.dart';

Future<void> pumpApp(WidgetTester tester, Locale locale) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(const ProviderScope(child: RiderApp()));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => router.go('/welcome'));

  testWidgets('welcome follows a French device', (tester) async {
    await pumpApp(tester, const Locale('fr', 'CM'));
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('welcome → sign up → verify → home tabs (English)', (tester) async {
    await pumpApp(tester, const Locale('en', 'US'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text("Let's get acquainted"), findsOneWidget);

    await tester.tap(find.text('Create account & verify'));
    await tester.pumpAndSettle();
    expect(find.text('Check your messages'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, '482619');
    await tester.pump();
    await tester.tap(find.text('Verify & continue'));
    await tester.pumpAndSettle();
    expect(find.text('Where to, Aïcha?'), findsOneWidget);

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Your activity'), findsOneWidget);
  });

  testWidgets('every design screen builds without overflow', (tester) async {
    await pumpApp(tester, const Locale('en', 'US'));
    for (final (path, _) in designScreens) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
    }
  });
}
