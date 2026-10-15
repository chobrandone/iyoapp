import 'package:flutter/material.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../../l10n/gen/app_localizations.dart';

extension RiderL10n on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

/// Douala sample coordinates; the UI-only map draws the Figma illustration in their place.
const _pickup = LatLng(4.0469, 9.6953);
const _car = LatLng(4.0452, 9.7005);
const _destination = LatLng(4.0560, 9.7280);

/// Map with pickup + nearby car (home, no drivers, saved places).
class PickupMap extends StatelessWidget {
  const PickupMap({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) => IyoMapCard(
    center: _pickup,
    height: height,
    onRecenter: () {},
    recenterLabel: context.t.recenterMap,
    markers: const [
      IyoMapMarker(id: 'pickup', kind: IyoMarkerKind.pickup, position: _pickup),
      IyoMapMarker(id: 'car', kind: IyoMarkerKind.car, position: _car),
    ],
  );
}

/// Map with the route from pickup to destination and the car on it (trip screens).
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, this.height = 256});

  final double height;

  @override
  Widget build(BuildContext context) => IyoMapCard(
    center: _pickup,
    height: height,
    fitToContent: true,
    onRecenter: () {},
    recenterLabel: context.t.recenterMap,
    route: const [_pickup, _car, _destination],
    markers: const [
      IyoMapMarker(id: 'pickup', kind: IyoMarkerKind.pickup, position: _pickup),
      IyoMapMarker(id: 'destination', kind: IyoMarkerKind.destination, position: _destination),
      IyoMapMarker(id: 'car', kind: IyoMarkerKind.car, position: _car),
    ],
  );
}

/// 14 px SemiBold section heading ("Today", "Payment methods").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      IyoText(text, variant: IyoTextVariant.subheading, header: true);
}

/// Grey footnote under a block (11 px, secondary).
class Footnote extends StatelessWidget {
  const Footnote(this.text, {super.key, this.align});

  final String text;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) =>
      IyoText(text, variant: IyoTextVariant.caption, color: IyoPalette.textSecondary, align: align);
}

/// Card content row: plain 20 px icon, then a title and an optional subtitle (Figma
/// "Let's try again shortly", "Emergency help", "Sophie notified").
class IconTitleRow extends StatelessWidget {
  const IconTitleRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleVariant = IyoTextVariant.listTitle,
    this.iconColor = IyoPalette.ink,
    this.iconGap = 16,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final IyoTextVariant titleVariant;
  final Color iconColor;
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 32, child: IyoIcon(icon, size: 20, color: iconColor)),
        SizedBox(width: iconGap - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IyoText(title, variant: titleVariant),
              if (subtitle != null)
                IyoText(
                  subtitle!,
                  variant: IyoTextVariant.caption,
                  color: IyoPalette.textSecondary,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Five 32 px stars; tapping sets the rating.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = context.iyo.accent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IyoPressable(
            onPressed: () => onChanged(i),
            semanticLabel: context.t.starsLabel('$i'),
            selected: i == value,
            minHitSize: 36,
            child: Icon(
              Icons.star_rounded,
              size: 36,
              color: i <= value ? accent : IyoPalette.border,
            ),
          ),
      ],
    );
  }
}

/// Tip chips: 40 px, radius 10, 1 px border; the selected one is pale yellow with an accent border.
class TipSelector extends StatelessWidget {
  const TipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final iyo = context.iyo;
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: IyoSpacing.sm),
          Expanded(
            child: IyoPressable(
              onPressed: () => onChanged(i),
              semanticLabel: options[i],
              selected: i == selected,
              child: Container(
                height: IyoSizes.buttonSmallHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected ? iyo.accentSoft : IyoPalette.surface,
                  borderRadius: BorderRadius.circular(IyoRadii.md),
                  border: Border.all(color: i == selected ? iyo.accent : IyoPalette.border),
                ),
                child: IyoText(options[i], variant: IyoTextVariant.body, maxLines: 1),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Centered "Already registered? Log in" line.
class InlineLink extends StatelessWidget {
  const InlineLink({
    super.key,
    required this.lead,
    required this.link,
    required this.onPressed,
    this.dark = false,
  });

  /// Welcome: 13 px ink. Elsewhere: 12 px grey.
  final bool dark;
  final String lead;
  final String link;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IyoPressable(
      onPressed: onPressed,
      semanticLabel: '$lead $link',
      minHitSize: 24,
      child: Text.rich(
        TextSpan(children: [TextSpan(text: '$lead '), TextSpan(text: link)]),
        style:
            dark
                ? IyoTextVariant.input.style.copyWith(color: IyoPalette.ink)
                : IyoTextVariant.body.style.copyWith(color: IyoPalette.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Card listing rows separated by a hairline, as in the wallet and trusted contacts frames.
List<Widget> divided(List<Widget> rows) => [
  for (var i = 0; i < rows.length; i++) ...[if (i > 0) const IyoDivider(), rows[i]],
];
