import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider/src/app.dart';

Future<void> pumpWithDeviceLocale(WidgetTester tester, Locale locale) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(const ProviderScope(child: RiderApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('follows a French device and switches to English', (tester) async {
    await pumpWithDeviceLocale(tester, const Locale('fr', 'CM'));
    expect(find.text('Votre ville. À votre façon.'), findsOneWidget);

    await tester.tap(find.text('Switch to English'));
    await tester.pumpAndSettle();
    expect(find.text('Your city. Your way.'), findsOneWidget);
  });

  testWidgets('follows an English device', (tester) async {
    await pumpWithDeviceLocale(tester, const Locale('en', 'US'));
    expect(find.text('Your city. Your way.'), findsOneWidget);
  });

  testWidgets('falls back to French for other device languages', (tester) async {
    await pumpWithDeviceLocale(tester, const Locale('de', 'DE'));
    expect(find.text('Votre ville. À votre façon.'), findsOneWidget);
  });
}
