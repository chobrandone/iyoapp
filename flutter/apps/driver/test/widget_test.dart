import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver/src/app.dart';

Future<void> pumpWithDeviceLocale(WidgetTester tester, Locale locale) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(const ProviderScope(child: DriverApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('follows a French device and switches to English', (tester) async {
    await pumpWithDeviceLocale(tester, const Locale('fr', 'CM'));
    expect(find.text('Conduisez avec iyodriver. Gagnez à votre rythme.'), findsOneWidget);

    await tester.tap(find.text('Switch to English'));
    await tester.pumpAndSettle();
    expect(find.text('Drive with iyodriver. Earn on your schedule.'), findsOneWidget);
  });

  testWidgets('follows an English device', (tester) async {
    await pumpWithDeviceLocale(tester, const Locale('en', 'US'));
    expect(find.text('Drive with iyodriver. Earn on your schedule.'), findsOneWidget);
  });

  testWidgets('falls back to French for other device languages', (tester) async {
    await pumpWithDeviceLocale(tester, const Locale('de', 'DE'));
    expect(find.text('Conduisez avec iyodriver. Gagnez à votre rythme.'), findsOneWidget);
  });
}
