import 'package:flutter/material.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// The only text primitive apps should use; enforces Poppins and the measured sizes.
/// Text scales with the system setting up to 1.6× (dynamic type), like the RN build.
class IyoText extends StatelessWidget {
  const IyoText(
    this.text, {
    super.key,
    this.variant = IyoTextVariant.body,
    this.color = IyoPalette.ink,
    this.align,
    this.maxLines,
    this.header = false,
    this.style,
  });

  final String text;
  final IyoTextVariant variant;
  final Color color;
  final TextAlign? align;
  final int? maxLines;

  /// Announce as a heading to screen readers.
  final bool header;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final widget = Text(
      variant.uppercase ? text.toUpperCase() : text,
      style: variant.style.copyWith(color: color).merge(style),
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6),
    );
    return header ? Semantics(header: true, child: widget) : widget;
  }
}

/// Lucide outline icon at the design-system sizes. Decorative: the parent control carries the label.
class IyoIcon extends StatelessWidget {
  const IyoIcon(this.icon, {super.key, this.size = IyoSizes.icon, this.color = IyoPalette.ink});

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: Icon(icon, size: size, color: color));
}

/// Tap target with opacity feedback (the RN `Pressable` pattern), button semantics and a
/// minimum 44 px hit area even when the visual is smaller.
class IyoPressable extends StatefulWidget {
  const IyoPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.pressedOpacity = 0.85,
    this.disabled = false,
    this.selected,
    this.minHitSize = IyoSizes.minTouchTarget,
    this.isButton = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final double pressedOpacity;
  final bool disabled;
  final bool? selected;

  /// Expands the hit area (not the visual) to at least this size.
  final double minHitSize;
  final bool isButton;

  @override
  State<IyoPressable> createState() => _IyoPressableState();
}

class _IyoPressableState extends State<IyoPressable> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.disabled;

  void _setPressed(bool value) {
    if (_enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.isButton,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _enabled ? widget.onPressed : null,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.minHitSize, minHeight: widget.minHitSize),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: AnimatedOpacity(
              opacity: widget.disabled ? 0.5 : (_pressed ? widget.pressedOpacity : 1),
              duration: const Duration(milliseconds: 90),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class IyoDivider extends StatelessWidget {
  const IyoDivider({super.key});

  @override
  Widget build(BuildContext context) => Container(height: 1, color: IyoPalette.border);
}

enum IyoBadgeTone { accent, neutral, dark, success, danger }

/// Status pill (Figma "Status"): 10 px Medium uppercase, radius 6, padding 10 × 5.
/// Also exported as [IyoPill]: the spec calls status pills both Badge and Pill.
class IyoBadge extends StatelessWidget {
  const IyoBadge(
    this.label, {
    super.key,
    this.tone = IyoBadgeTone.accent,
    this.dot = false,
    this.trailingIcon,
  });

  final String label;
  final IyoBadgeTone tone;

  /// Leading dot, e.g. "● ACCEPTING RIDE REQUESTS".
  final bool dot;

  /// Small icon after the label, e.g. the chevron in "NOW · 1 RIDER ⌄".
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final iyo = context.iyo;
    final (bg, fg) = switch (tone) {
      IyoBadgeTone.accent => (iyo.accentSoft, IyoPalette.ink),
      IyoBadgeTone.neutral => (IyoPalette.surface, IyoPalette.ink),
      IyoBadgeTone.dark => (IyoPalette.ink, IyoPalette.white),
      IyoBadgeTone.success => (IyoPalette.successSoft, IyoPalette.success),
      IyoBadgeTone.danger => (IyoPalette.dangerSoft, IyoPalette.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(IyoRadii.xs)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          IyoText(label, variant: IyoTextVariant.status, color: fg),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            IyoIcon(trailingIcon!, size: 12, color: fg),
          ],
        ],
      ),
    );
  }
}

typedef IyoPill = IyoBadge;

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return (first + last).toUpperCase();
}

/// Portrait photo, or initials on the pale-yellow circle when there is no photo.
class IyoAvatar extends StatelessWidget {
  const IyoAvatar({super.key, required this.name, this.photoUrl, this.size = IyoSizes.avatar});

  final String name;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = IyoText(
      initialsOf(name),
      variant: IyoTextVariant.avatar,
      style: size < 48 ? TextStyle(fontSize: size * 0.36, height: 1.4) : null,
    );
    return Semantics(
      label: name,
      image: true,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: photoUrl == null ? context.iyo.accentSoft : IyoPalette.surface,
          image:
              photoUrl == null
                  ? null
                  : DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover),
        ),
        child: photoUrl == null ? initials : null,
      ),
    );
  }
}
