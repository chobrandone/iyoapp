// On-device capture of every design screen, for comparison with the Figma frames:
//   flutter drive --driver=test_driver/screenshots.dart \
//     --target=integration_test/design_screens_test.dart -d <device>
// PNGs land in build/device_screens/. Only the app's own surface is captured.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rider/src/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture every design screen', (tester) async {
    tester.platformDispatcher.localesTestValue = [const Locale('en', 'US')];
    // Compare at 1.0x text like the Figma frames; the device's own font size is left untouched.
    tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(const ProviderScope(child: RiderApp()));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    for (final (path, _) in designScreens) {
      router.go(path);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      // The surface image lags a frame behind; give the new route time to reach the screen.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await binding.takeScreenshot(path.substring(1).replaceAll('/', '_'));
    }
    router.go('/welcome');
    await tester.pumpAndSettle();
  });
}
