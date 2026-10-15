import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'primitives.dart';

/// Shared screen layout from Figma: status bar → header row → page heading →
/// content column (gap 14) → pinned actions (padding 8 / 16, gap 10).
/// The bottom tab bar (root screens only) comes from the app shell.
class IyoScreen extends StatelessWidget {
  const IyoScreen({
    super.key,
    this.header,
    this.heading,
    this.footer = const [],
    this.scroll = true,
    this.padded = true,
    this.inTabs = false,
    required this.children,
  });

  /// Header row (AppHeader), above the scrollable content.
  final Widget? header;

  /// Page heading; scrolls with the content.
  final Widget? heading;

  /// Pinned bottom actions (e.g. the primary 52 px button).
  final List<Widget> footer;
  final bool scroll;

  /// Set false for edge-to-edge content such as full-bleed maps.
  final bool padded;

  /// Tab root screens: the tab bar already pads the bottom inset.
  final bool inTabs;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gutter = padded ? IyoSpacing.screenPadding : 0.0;
    final column = <Widget>[if (heading != null) heading!, ...children];
    final spaced = <Widget>[
      for (var i = 0; i < column.length; i++) ...[
        // Heading → first block is 13 in the frames; blocks are 16 apart.
        if (i > 0) SizedBox(height: i == 1 && heading != null ? 13 : IyoSpacing.stack),
        column[i],
      ],
    ];
    final content = Padding(
      padding: EdgeInsets.fromLTRB(gutter, 0, gutter, IyoSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: spaced),
    );

    return Scaffold(
      backgroundColor: IyoPalette.white,
      body: SafeArea(
        bottom: !inTabs && footer.isEmpty,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: IyoSpacing.screenPadding),
                child: header,
              ),
            Expanded(
              child:
                  scroll
                      ? SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: content,
                      )
                      : content,
            ),
            if (footer.isNotEmpty)
              SafeArea(
                top: false,
                bottom: !inTabs,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IyoSpacing.screenPadding,
                    IyoSpacing.sm,
                    IyoSpacing.screenPadding,
                    // Frames: the pinned button ends 5 above the home-indicator inset.
                    5,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < footer.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        footer[i],
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Figma "Flow identification" row: 17 px Bold wordmark left, 9 px flow label right.
class IyoAppHeader extends StatelessWidget {
  const IyoAppHeader({super.key, this.badge, this.flowLabel, this.leading, this.trailing});

  /// Small badge next to the wordmark, e.g. "DRIVER" in the driver app.
  final String? badge;

  /// Uppercase flow label on the right, e.g. "RIDER · 01".
  final String? flowLabel;

  /// Replaces the wordmark (e.g. a back button).
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: IyoSizes.headerHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            leading ??
                Row(
                  children: [
                    const IyoText('iyodriver', variant: IyoTextVariant.wordmark, header: true),
                    if (badge != null) ...[
                      const SizedBox(width: IyoSpacing.sm),
                      IyoBadge(badge!, tone: IyoBadgeTone.dark),
                    ],
                  ],
                ),
            const Spacer(),
            trailing ??
                (flowLabel == null
                    ? const SizedBox.shrink()
                    : IyoText(
                      flowLabel!,
                      variant: IyoTextVariant.label,
                      color: IyoPalette.textSecondary,
                    )),
          ],
        ),
      ),
    );
  }
}

/// Figma "Page heading": 24 px SemiBold title, 12 px secondary subtitle, padding 16 / 14.
class IyoPageHeading extends StatelessWidget {
  const IyoPageHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.hero = false,
    this.onBack,
    this.backLabel = 'Back',
    this.compact,
  });

  final String title;
  final String? subtitle;

  /// Larger hero size (welcome / onboarding screens).
  final bool hero;

  /// Shows a back chevron before the title (e.g. "‹ Chat with Jean-Paul").
  final VoidCallback? onBack;
  final String backLabel;

  /// 12 instead of 16 above the title. Defaults to true when [onBack] is set: the frames with
  /// a back chevron (and the Activity / Notifications tabs) sit 4 px higher.
  final bool? compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: (compact ?? onBack != null) ? 12 : IyoSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                // Figma: a small bold "‹" with the title starting 19 px in.
                IyoPressable(
                  onPressed: onBack,
                  semanticLabel: backLabel,
                  minHitSize: 0,
                  child: const SizedBox(
                    width: 19,
                    height: 36,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IyoIcon(LucideIcons.chevronLeft600, size: 16),
                    ),
                  ),
                ),
              Expanded(
                child: IyoText(
                  title,
                  variant: hero ? IyoTextVariant.hero : IyoTextVariant.title,
                  header: true,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            IyoText(subtitle!, color: IyoPalette.textSecondary),
          ],
        ],
      ),
    );
  }
}

class IyoTabItem {
  const IyoTabItem({
    required this.key,
    required this.label,
    required this.icon,
    this.badge = false,
  });

  final String key;
  final String label;
  final IconData icon;

  /// Small red dot (e.g. unread notifications).
  final bool badge;
}

/// Figma "Navigation": 64 px bar with a top border, 20 px icons, 9 px labels
/// (SemiBold ink when active, Regular grey otherwise) and a 16 × 3 accent indicator.
class IyoBottomTabBar extends StatelessWidget {
  const IyoBottomTabBar({
    super.key,
    required this.items,
    required this.activeKey,
    required this.onSelect,
  });

  final List<IyoTabItem> items;
  final String activeKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: IyoSizes.tabBarHeight + bottom,
      padding: EdgeInsets.only(bottom: bottom, left: IyoSpacing.md, right: IyoSpacing.md),
      decoration: const BoxDecoration(
        color: IyoPalette.white,
        border: Border(top: BorderSide(color: IyoPalette.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Expanded(
              child: _TabButton(item: item, active: item.key == activeKey, onSelect: onSelect),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.item, required this.active, required this.onSelect});

  final IyoTabItem item;
  final bool active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final color = active ? IyoPalette.ink : IyoPalette.textSecondary;
    return IyoPressable(
      onPressed: () => onSelect(item.key),
      semanticLabel: item.label,
      selected: active,
      pressedOpacity: 0.7,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IyoIcon(item.icon, size: IyoSizes.iconTab, color: color),
                if (item.badge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: IyoPalette.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: IyoPalette.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            IyoText(
              item.label,
              variant: active ? IyoTextVariant.tabActive : IyoTextVariant.tab,
              color: color,
              maxLines: 1,
            ),
            const SizedBox(height: 3),
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: active ? context.iyo.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
