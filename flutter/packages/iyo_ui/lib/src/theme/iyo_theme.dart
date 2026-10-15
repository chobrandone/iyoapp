import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// The small set of tokens an app may override without touching widgets
/// (e.g. a distinct accent for the driver app later). Read it with `context.iyo`.
@immutable
class IyoTheme extends ThemeExtension<IyoTheme> {
  const IyoTheme({
    this.accent = IyoPalette.primary,
    this.accentSoft = IyoPalette.primarySoft,
    this.onAccent = IyoPalette.ink,
  });

  final Color accent;
  final Color accentSoft;

  /// Text / icon colour drawn on top of [accent].
  final Color onAccent;

  @override
  IyoTheme copyWith({Color? accent, Color? accentSoft, Color? onAccent}) => IyoTheme(
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    onAccent: onAccent ?? this.onAccent,
  );

  @override
  IyoTheme lerp(covariant IyoTheme? other, double t) {
    if (other == null) return this;
    return IyoTheme(
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }

  /// Material theme for MaterialApp: white screens, Poppins, accent selection colours,
  /// no Material ripples on our own controls (they use opacity feedback like the RN build).
  ThemeData toThemeData() {
    final textTheme = TextTheme(
      displayLarge: IyoTextVariant.hero.style,
      headlineMedium: IyoTextVariant.title.style,
      titleMedium: IyoTextVariant.cardTitle.style,
      bodyLarge: IyoTextVariant.input.style,
      bodyMedium: IyoTextVariant.body.style,
      bodySmall: IyoTextVariant.caption.style,
      labelLarge: IyoTextVariant.button.style,
    ).apply(bodyColor: IyoPalette.ink, displayColor: IyoPalette.ink);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      package: 'iyo_ui',
      scaffoldBackgroundColor: IyoPalette.white,
      colorScheme: ColorScheme.light(
        primary: accent,
        onPrimary: onAccent,
        secondary: accentSoft,
        surface: IyoPalette.white,
        onSurface: IyoPalette.ink,
        error: IyoPalette.danger,
      ),
      textTheme: textTheme,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: IyoPalette.ink,
        selectionColor: accent.withValues(alpha: 0.35),
        selectionHandleColor: accent,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [this],
    );
  }
}

extension IyoThemeContext on BuildContext {
  /// Per-app accent tokens; falls back to the Figma yellow when no extension is installed.
  IyoTheme get iyo => Theme.of(this).extension<IyoTheme>() ?? const IyoTheme();
}
