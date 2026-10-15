import 'package:flutter/material.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'primitives.dart';

enum IyoButtonVariant { primary, secondary, soft, danger, ghost }

enum IyoButtonSize { lg, sm }

/// Figma "Action": 52 px tall, radius 10, 14 px SemiBold label.
/// `sm` = 40 px quick action ("I'm here", "Call driver").
class IyoButton extends StatelessWidget {
  const IyoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = IyoButtonVariant.primary,
    this.size = IyoButtonSize.lg,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.iconSize = IyoSizes.iconSmall,
    this.mirrorIcon = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IyoButtonVariant variant;
  final IyoButtonSize size;
  final bool loading;
  final bool disabled;

  /// Icon rendered before the label.
  final IconData? icon;

  /// Defaults to 18; the home search button uses a tiny 11 px mirrored glass.
  final double iconSize;
  final bool mirrorIcon;

  /// Full width (default) or hug the content.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final iyo = context.iyo;
    final (bg, fg) = switch (variant) {
      IyoButtonVariant.primary => (iyo.accent, iyo.onAccent),
      IyoButtonVariant.secondary => (IyoPalette.surface, IyoPalette.ink),
      IyoButtonVariant.soft => (iyo.accentSoft, IyoPalette.ink),
      IyoButtonVariant.danger => (IyoPalette.danger, IyoPalette.white),
      IyoButtonVariant.ghost => (Colors.transparent, IyoPalette.ink),
    };
    final small = size == IyoButtonSize.sm;
    final isDisabled = disabled || loading;

    final content =
        loading
            ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Transform.flip(
                    flipX: mirrorIcon,
                    child: IyoIcon(icon!, size: iconSize, color: fg),
                  ),
                  const SizedBox(width: IyoSpacing.sm),
                ],
                Flexible(
                  child: IyoText(
                    label,
                    variant: small ? IyoTextVariant.buttonSmall : IyoTextVariant.button,
                    color: fg,
                    maxLines: 1,
                  ),
                ),
              ],
            );

    return IyoPressable(
      onPressed: onPressed,
      disabled: isDisabled,
      semanticLabel: label,
      child: Container(
        height: small ? IyoSizes.buttonSmallHeight : IyoSizes.buttonHeight,
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: IyoSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(IyoRadii.md)),
        child: content,
      ),
    );
  }
}

enum IyoIconButtonTone { soft, surface, white, accent, ghost }

/// Round icon-only button: call/contact (40 px, soft), map recenter (36 px, white),
/// send (32 px, accent). The touch target is always at least 44 px.
class IyoIconButton extends StatelessWidget {
  const IyoIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.tone = IyoIconButtonTone.soft,
    this.size = IyoSizes.contactButton,
    this.iconSize,
    this.rounded = false,
    this.disabled = false,
  });

  final IconData icon;

  /// Required: icon-only buttons need a spoken label.
  final String semanticLabel;
  final VoidCallback? onPressed;
  final IyoIconButtonTone tone;

  /// Visual diameter.
  final double size;
  final double? iconSize;

  /// Rounded square (radius 10) instead of a circle.
  final bool rounded;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final iyo = context.iyo;
    final bg = switch (tone) {
      IyoIconButtonTone.soft => iyo.accentSoft,
      IyoIconButtonTone.surface => IyoPalette.surface,
      IyoIconButtonTone.white => IyoPalette.white,
      IyoIconButtonTone.accent => iyo.accent,
      IyoIconButtonTone.ghost => Colors.transparent,
    };
    return IyoPressable(
      onPressed: onPressed,
      disabled: disabled,
      semanticLabel: semanticLabel,
      pressedOpacity: 0.8,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: rounded ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: rounded ? BorderRadius.circular(IyoRadii.md) : null,
          boxShadow: tone == IyoIconButtonTone.white ? IyoShadows.card : null,
        ),
        child: IyoIcon(icon, size: iconSize ?? (size * 0.48).roundToDouble()),
      ),
    );
  }
}
