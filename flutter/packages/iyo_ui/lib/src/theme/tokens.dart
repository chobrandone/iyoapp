import 'package:flutter/painting.dart';

/// Colour tokens from the iyodriver Figma file. Apps never hard-code hex values: they read
/// `context.iyo` (which also carries the per-app accent overrides) or these constants.
abstract final class IyoPalette {
  static const Color primary = Color(0xFFF6C200);

  /// Pale yellow used for highlight cards, status pills, contact buttons and "my" chat bubbles.
  static const Color primarySoft = Color(0xFFFFF8DC);
  static const Color ink = Color(0xFF191919);

  /// Body copy inside highlight cards and form field labels.
  static const Color charcoal = Color(0xFF312C2C);
  static const Color black = Color(0xFF000000);
  static const Color danger = Color(0xFFFF0000);
  static const Color success = Color(0xFF008011);

  /// Secondary text: subtitles, captions, inactive tab labels (#747474 in every Figma frame).
  static const Color textSecondary = Color(0xFF747474);

  /// Placeholders, disabled text and inactive icons.
  static const Color muted = Color(0xFFAFAFAF);
  static const Color white = Color(0xFFFFFFFF);

  /// Light warm grey: secondary buttons, list cards, icon wells, chat bubbles.
  static const Color surface = Color(0xFFF6F6F3);

  /// Hairline borders, dividers and the tab bar top border.
  static const Color border = Color(0xFFE9E9E6);

  /// Background behind map tiles while they load.
  static const Color mapBackground = Color(0xFFECEEE9);

  /// Parks and water in the Google map style.
  static const Color mapPark = Color(0xFFDCE8D8);
  static const Color mapWater = Color(0xFFD3E3EA);

  /// Pale green behind "Accepting ride requests"-style success pills.
  static const Color successSoft = Color(0xFFEDF7EF);

  /// Pale red behind danger pills (derived; no Figma reference yet).
  static const Color dangerSoft = Color(0xFFFFECEC);

  /// Scrim behind sheets and modals (ink at 48%).
  static const Color overlay = Color(0x7A191919);

  /// Pickup halo on maps: primary at 22% opacity.
  static const Color primaryHalo = Color(0x38F6C200);

  /// Named swatches for the dev gallery.
  static const Map<String, Color> swatches = {
    'primary': primary,
    'primarySoft': primarySoft,
    'ink': ink,
    'charcoal': charcoal,
    'black': black,
    'danger': danger,
    'success': success,
    'textSecondary': textSecondary,
    'muted': muted,
    'white': white,
    'surface': surface,
    'border': border,
    'mapBackground': mapBackground,
    'mapPark': mapPark,
    'mapWater': mapWater,
    'successSoft': successSoft,
    'dangerSoft': dangerSoft,
  };
}

/// Spacing scale. Screens use [screenPadding] (24) as their horizontal gutter.
abstract final class IyoSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;

  /// Gap between stacked cards in a content column (Figma: 14).
  static const double stack = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double screenPadding = 24;
}

/// Fixed sizes measured from the Figma components.
abstract final class IyoSizes {
  static const double buttonHeight = 52;
  static const double buttonSmallHeight = 40;
  static const double inputMinHeight = 48;
  static const double digitHeight = 58;
  static const double minTouchTarget = 44;

  /// Header row height (wordmark + flow label).
  static const double headerHeight = 44;
  static const double icon = 22;
  static const double iconSmall = 18;
  static const double iconTab = 20;
  static const double iconStroke = 1.75;
  static const double iconWell = 36;
  static const double tabBarHeight = 64;
  static const double tileHeight = 64;
  static const double serviceOptionHeight = 56;
  static const double portrait = 52;
  static const double avatar = 56;
  static const double contactButton = 40;
  static const double mapRecenter = 36;
}

abstract final class IyoRadii {
  static const double none = 0;

  /// Status pills.
  static const double xs = 6;

  /// Car marker.
  static const double sm = 8;

  /// Buttons, inputs, tiles, icon wells.
  static const double md = 10;

  /// Cards, map card, chat bubbles.
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

abstract final class IyoShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
