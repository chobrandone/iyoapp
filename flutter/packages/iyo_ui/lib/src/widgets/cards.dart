import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'primitives.dart';

enum IyoCardTone { surface, accent, white, success, danger }

/// Figma "Information card": radius 16, padding 16, gap 10.
class IyoCard extends StatelessWidget {
  const IyoCard({
    super.key,
    this.tone = IyoCardTone.surface,
    this.title,
    this.description,
    this.onPressed,
    this.children = const [],
  });

  final IyoCardTone tone;
  final String? title;

  /// Body copy under the title (charcoal on tinted cards, secondary on surface / white cards).
  final String? description;
  final VoidCallback? onPressed;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      IyoCardTone.surface => IyoPalette.surface,
      IyoCardTone.accent => context.iyo.accentSoft,
      IyoCardTone.white => IyoPalette.white,
      IyoCardTone.success => IyoPalette.successSoft,
      IyoCardTone.danger => IyoPalette.dangerSoft,
    };
    final neutral = tone == IyoCardTone.surface || tone == IyoCardTone.white;
    final items = <Widget>[
      if (title != null) IyoText(title!, variant: IyoTextVariant.cardTitle),
      if (description != null)
        IyoText(description!, color: neutral ? IyoPalette.textSecondary : IyoPalette.charcoal),
      ...children,
    ];

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(IyoSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(IyoRadii.lg),
        border: tone == IyoCardTone.white ? Border.all(color: IyoPalette.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            items[i],
          ],
        ],
      ),
    );
    if (onPressed == null) return card;
    return IyoPressable(onPressed: onPressed, semanticLabel: title, child: card);
  }
}

enum IyoIconWellTone { surface, accent, white }

/// Figma "Detail row": 36 px icon well, 13 px Medium title, 11 px secondary subtitle;
/// padding 9, gap 12.
class IyoListRow extends StatelessWidget {
  const IyoListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconWellTone = IyoIconWellTone.surface,
    this.leading,
    this.trailing,
    this.showChevron,
    this.onPressed,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;

  /// Icon shown in a 36 px rounded well on the left.
  final IconData? icon;
  final IyoIconWellTone iconWellTone;

  /// Custom left element (e.g. an avatar); overrides [icon].
  final Widget? leading;

  /// Custom right element; defaults to a chevron when [onPressed] is set.
  final Widget? trailing;
  final bool? showChevron;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final fg = destructive ? IyoPalette.danger : IyoPalette.ink;
    final wellBg = switch (iconWellTone) {
      IyoIconWellTone.surface => IyoPalette.surface,
      IyoIconWellTone.accent => context.iyo.accentSoft,
      IyoIconWellTone.white => IyoPalette.white,
    };
    final chevron = showChevron ?? onPressed != null;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: IyoSizes.minTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: IyoSpacing.md),
            ] else if (icon != null) ...[
              Container(
                width: IyoSizes.iconWell,
                height: IyoSizes.iconWell,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: wellBg,
                  borderRadius: BorderRadius.circular(IyoRadii.md),
                ),
                child: IyoIcon(icon!, size: IyoSizes.iconSmall, color: fg),
              ),
              const SizedBox(width: IyoSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IyoText(title, variant: IyoTextVariant.rowTitle, color: fg),
                  if (subtitle != null) ...[
                    const SizedBox(height: IyoSpacing.xxs),
                    IyoText(
                      subtitle!,
                      variant: IyoTextVariant.caption,
                      color: IyoPalette.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: IyoSpacing.md),
              trailing!,
            ] else if (chevron) ...[
              const SizedBox(width: IyoSpacing.md),
              const IyoIcon(
                LucideIcons.chevronRight,
                size: IyoSizes.iconSmall,
                color: IyoPalette.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
    if (onPressed == null) return row;
    return IyoPressable(
      onPressed: onPressed,
      pressedOpacity: 0.7,
      semanticLabel: subtitle == null ? title : '$title, $subtitle',
      child: row,
    );
  }
}

/// Figma "Trip action": 64 px tall, radius 10, 20 px icon over a 10 px Medium label.
/// `accent` = pale yellow (Safety); `surface` = grey (Message, Share trip).
class IyoActionTile extends StatelessWidget {
  const IyoActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.accent = false,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool accent;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return IyoPressable(
      onPressed: onPressed ?? () {},
      disabled: disabled,
      semanticLabel: label,
      pressedOpacity: 0.8,
      child: Container(
        height: IyoSizes.tileHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: accent ? context.iyo.accentSoft : IyoPalette.surface,
          borderRadius: BorderRadius.circular(IyoRadii.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IyoIcon(icon, size: IyoSizes.iconTab),
            const SizedBox(height: 5),
            IyoText(label, variant: IyoTextVariant.tileLabel, color: IyoPalette.black, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

/// Lays tiles out in an equal-width row with an 8 px gap.
class IyoActionTileRow extends StatelessWidget {
  const IyoActionTileRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: IyoSpacing.sm),
        Expanded(child: children[i]),
      ],
    ],
  );
}

/// Compact metric (earnings, trips, rating). Radius 10, padding 14.
class IyoStatTile extends StatelessWidget {
  const IyoStatTile({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.icon,
    this.accent = false,
  });

  final String label;
  final String value;

  /// Secondary line under the value, e.g. "7 trips · 2 h 18 min online".
  final String? detail;
  final IconData? icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: [label, value, if (detail != null) detail!].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent ? context.iyo.accentSoft : IyoPalette.surface,
          borderRadius: BorderRadius.circular(IyoRadii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  IyoIcon(icon!, size: 16, color: IyoPalette.textSecondary),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: IyoText(
                    label,
                    variant: IyoTextVariant.caption,
                    color: IyoPalette.textSecondary,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: IyoSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: IyoText(value, variant: IyoTextVariant.cardTitle),
            ),
            if (detail != null) ...[
              const SizedBox(height: IyoSpacing.xs),
              IyoText(
                detail!,
                variant: IyoTextVariant.helper,
                color: IyoPalette.textSecondary,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Figma "Trip companion": 52 px portrait, 14 px SemiBold name, two 11 px lines, 40 px
/// pale-yellow contact buttons. DriverInfoCard in the rider app, RiderInfoCard in the driver app.
class IyoPersonInfoCard extends StatelessWidget {
  const IyoPersonInfoCard({
    super.key,
    required this.name,
    this.photoUrl,
    this.meta,
    this.detail,
    this.onCall,
    this.callLabel = 'Call',
    this.onMessage,
    this.messageLabel = 'Message',
  });

  final String name;
  final String? photoUrl;

  /// Secondary line, e.g. "★ 4.9 · 1 248 trips".
  final String? meta;

  /// Ink line, e.g. "Toyota Corolla · Blanc · LT 123 AB".
  final String? detail;
  final VoidCallback? onCall;
  final String callLabel;
  final VoidCallback? onMessage;
  final String messageLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IyoAvatar(name: name, photoUrl: photoUrl, size: IyoSizes.portrait),
        const SizedBox(width: IyoSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IyoText(name, variant: IyoTextVariant.subheading, maxLines: 1),
              if (meta != null) ...[
                const SizedBox(height: IyoSpacing.xxs),
                IyoText(
                  meta!,
                  variant: IyoTextVariant.caption,
                  color: IyoPalette.textSecondary,
                  maxLines: 1,
                ),
              ],
              if (detail != null) ...[
                const SizedBox(height: IyoSpacing.xxs),
                IyoText(detail!, variant: IyoTextVariant.caption, maxLines: 1),
              ],
            ],
          ),
        ),
        if (onMessage != null)
          IyoIconButton(
            icon: LucideIcons.messageCircle,
            semanticLabel: messageLabel,
            onPressed: onMessage,
            iconSize: 19,
          ),
        if (onCall != null)
          IyoIconButton(
            icon: LucideIcons.phone,
            semanticLabel: callLabel,
            onPressed: onCall,
            iconSize: 19,
          ),
      ],
    );
  }
}
