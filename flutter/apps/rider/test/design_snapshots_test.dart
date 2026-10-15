// Renders every design screen at the Figma frame size (390 × 844 @1x) with the real fonts, for
// side-by-side review against the frames:
//   flutter test test/design_snapshots_test.dart --update-goldens --tags snapshots
// Output: test/snapshots/*.png (gitignored). Skipped in normal runs.
@Tags(['snapshots'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rider/src/app.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File(f).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

String _pubCache() {
  final local = Platform.environment['LOCALAPPDATA'];
  return local != null ? '$local/Pub/Cache' : '${Platform.environment['HOME']}/.pub-cache';
}

void main() {
  setUpAll(() async {
    const ui = '../../packages/iyo_ui/fonts';
    await _loadFont('packages/iyo_ui/Poppins', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) '$ui/Poppins-$w.ttf',
    ]);
    final lucide = Directory(
      '${_pubCache()}/hosted/pub.dev',
    ).listSync().firstWhere((d) => d.path.contains('lucide_icons_flutter-'));
    await _loadFont('packages/lucide_icons_flutter/Lucide', ['${lucide.path}/assets/lucide.ttf']);
    await _loadFont('packages/lucide_icons_flutter/Lucide600', [
      '${lucide.path}/assets/build_font/LucideVariable-w600.ttf',
    ]);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    ]);
  });

  testWidgets('snapshot every design screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [const Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(ProviderScope(overrides: riderOverrides, child: const RiderApp()));
    for (final (path, _) in designScreens) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      // Let Image.asset decode.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      final name = path.substring(1).replaceAll('/', '_');
      await expectLater(find.byType(RiderApp), matchesGoldenFile('snapshots/$name.png'));
    }
  });
}

GoRouter routerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(RiderApp))).read(routerProvider);
