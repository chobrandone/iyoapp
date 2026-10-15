import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../../l10n/gen/app_localizations.dart';

extension DriverL10n on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

LatLng ll(GeoPoint p) => LatLng(p.lat, p.lng);

/// Driver header: wordmark + flow label (the Figma driver frames carry no extra badge).
class DriverHeader extends StatelessWidget {
  const DriverHeader({super.key, this.flowLabel});

  final String? flowLabel;

  @override
  Widget build(BuildContext context) => IyoAppHeader(flowLabel: flowLabel);
}

class Footnote extends StatelessWidget {
  const Footnote(this.text, {super.key, this.align, this.color = IyoPalette.textSecondary});

  final String text;
  final TextAlign? align;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      IyoText(text, variant: IyoTextVariant.caption, color: color, align: align);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      IyoText(text, variant: IyoTextVariant.subheading, header: true);
}

/// Map around the driver, optionally with a pickup / destination and the route between them.
class DriverMap extends StatelessWidget {
  const DriverMap({
    super.key,
    required this.me,
    this.heading = 0,
    this.pickup,
    this.destination,
    this.height = 256,
    this.showHalo = false,
  });

  final GeoPoint me;
  final double heading;
  final GeoPoint? pickup;
  final GeoPoint? destination;
  final double height;

  /// "You are here" halo under the car (home screens).
  final bool showHalo;

  @override
  Widget build(BuildContext context) {
    final target = destination ?? pickup;
    return IyoMapCard(
      center: ll(me),
      height: height,
      fitToContent: target != null,
      onRecenter: () {},
      route: target == null ? const [] : [ll(me), ll(target)],
      markers: [
        if (showHalo && pickup == null)
          IyoMapMarker(id: 'here', kind: IyoMarkerKind.pickup, position: ll(me)),
        if (pickup != null)
          IyoMapMarker(id: 'pickup', kind: IyoMarkerKind.pickup, position: ll(pickup!)),
        if (destination != null)
          IyoMapMarker(
            id: 'destination',
            kind: IyoMarkerKind.destination,
            position: ll(destination!),
          ),
        IyoMapMarker(id: 'me', kind: IyoMarkerKind.car, position: ll(me), heading: heading),
      ],
    );
  }
}

/// RideRequestSheet countdown ring (driver-only component, spec §5).
class CountdownRing extends StatelessWidget {
  const CountdownRing({super.key, required this.progress, required this.label, this.size = 72});

  /// 1 → 0 as the accept window runs out.
  final double progress;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = context.iyo.accent;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress.clamp(0, 1), color: accent),
        child: Center(child: IyoText(label, variant: IyoTextVariant.cardTitle)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(4);
    final track =
        Paint()
          ..color = IyoPalette.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
    final arc =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}

enum UploadState { missing, uploading, pending, approved, rejected }

/// DocumentUploadRow (driver-only component): one required document with its upload state.
class DocumentUploadRow extends StatelessWidget {
  const DocumentUploadRow({
    super.key,
    required this.title,
    required this.state,
    this.progress = 0,
    this.rejectionReason,
    this.onTap,
  });

  final String title;
  final UploadState state;
  final double progress;
  final String? rejectionReason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final (icon, color, subtitle) = switch (state) {
      UploadState.missing => (LucideIcons.upload, IyoPalette.ink, t.docMissing),
      UploadState.uploading => (
        LucideIcons.loader,
        IyoPalette.ink,
        t.docUploading('${(progress * 100).round()}'),
      ),
      UploadState.pending => (LucideIcons.clock3, IyoPalette.textSecondary, t.docPending),
      UploadState.approved => (LucideIcons.circleCheck, IyoPalette.success, t.docApproved),
      UploadState.rejected => (
        LucideIcons.circleAlert,
        IyoPalette.danger,
        t.docRejected(rejectionReason ?? ''),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IyoListRow(
          icon: icon,
          iconWellTone:
              state == UploadState.missing ? IyoIconWellTone.accent : IyoIconWellTone.white,
          title: title,
          subtitle: subtitle,
          destructive: state == UploadState.rejected,
          onPressed: state == UploadState.uploading || state == UploadState.approved ? null : onTap,
          showChevron: state == UploadState.missing || state == UploadState.rejected,
        ),
        if (state == UploadState.uploading)
          LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            color: context.iyo.accent,
            backgroundColor: IyoPalette.border,
          ),
      ],
    );
  }
}

/// OnlineToggle (driver-only component): the big go online / go offline control.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({super.key, required this.online, required this.onChanged, this.busy = false});

  final bool online;
  final ValueChanged<bool> onChanged;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoButton(
      label: online ? t.goOffline : t.goOnline,
      icon: LucideIcons.power,
      variant: online ? IyoButtonVariant.secondary : IyoButtonVariant.primary,
      loading: busy,
      onPressed: () => onChanged(!online),
    );
  }
}

String paymentLabel(BuildContext context, PaymentMethodType m) {
  final t = context.t;
  return switch (m) {
    PaymentMethodType.mtnMomo => t.paymentMtn,
    PaymentMethodType.orangeMoney => t.paymentOrange,
    PaymentMethodType.cash => t.paymentCash,
    PaymentMethodType.card => t.paymentCard,
  };
}

/// `2 h 18 min` style duration for "online today".
String hoursMinutes(int seconds) {
  final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60;
  return h > 0 ? '$h h ${m.toString().padLeft(2, '0')} min' : '$m min';
}

/// Figma "Information card" used as a metric: 11 px label, 26 px SemiBold value.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => IyoCard(
    children: [
      IyoText(label, variant: IyoTextVariant.caption, color: IyoPalette.textSecondary),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: IyoText(value, variant: IyoTextVariant.metric, maxLines: 1),
      ),
    ],
  );
}

/// Next manoeuvre above the map (accent card with one detail row).
class InstructionCard extends StatelessWidget {
  const InstructionCard({super.key, required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => IyoCard(
    tone: IyoCardTone.accent,
    children: [IyoListRow(icon: icon, title: title, subtitle: subtitle, showChevron: false)],
  );
}

/// Message · Share trip · Safety (Figma "Trip tools").
class TripTools extends StatelessWidget {
  const TripTools({super.key, this.onMessage, this.onShare, this.onSafety});

  final VoidCallback? onMessage;
  final VoidCallback? onShare;
  final VoidCallback? onSafety;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoActionTileRow(
      children: [
        IyoActionTile(
          icon: LucideIcons.messageCircle,
          label: t.tileMessage,
          onPressed: onMessage ?? () {},
        ),
        IyoActionTile(
          icon: LucideIcons.share2,
          label: t.tileShareTrip,
          onPressed: onShare ?? () {},
        ),
        IyoActionTile(
          icon: LucideIcons.shieldCheck,
          label: t.tileSafety,
          accent: true,
          onPressed: onSafety ?? () {},
        ),
      ],
    );
  }
}

/// Short, stable ride reference for drivers and support: RD-#### from the ride id.
String rideRef(String rideId) {
  if (RegExp(r'^RD-\d+$').hasMatch(rideId)) return rideId;
  var h = 0;
  for (final c in rideId.codeUnits) {
    h = (h * 31 + c) % 10000;
  }
  return 'RD-${h.toString().padLeft(4, '0')}';
}

/// Same rule as the rider app's trip reference (IYO-####).
String tripRef(String rideId) {
  var h = 0;
  for (final c in rideId.codeUnits) {
    h = (h * 31 + c) % 10000;
  }
  return 'IYO-${h.toString().padLeft(4, '0')}';
}

/// Earnings bars (Figma "Weekly earnings chart"): 24 px ink bars, today in yellow, a short dash
/// for days with nothing yet; labels underneath.
class EarningsChart extends StatelessWidget {
  const EarningsChart({
    super.key,
    required this.values,
    required this.labels,
    required this.current,
  });

  final List<int> values;
  final List<String> labels;
  final int current;

  @override
  Widget build(BuildContext context) {
    final accent = context.iyo.accent;
    return Semantics(
      label: labels.indexed.map((e) => '${e.$2} ${formatFcfa(values[e.$1])}').join(', '),
      excludeSemantics: true,
      child: SizedBox(
        height: 105,
        child: LayoutBuilder(
          builder: (context, c) {
            final n = values.length;
            final barW = n > 7 ? (c.maxWidth - 16) / (n * 1.6) : 24.0;
            final gap = n > 1 ? (c.maxWidth - 16 - n * barW) / (n - 1) : 0.0;
            final max = values.fold(1, (a, b) => a > b ? a : b);
            return Stack(
              children: [
                for (var i = 0; i < n; i++) ...[
                  Positioned(
                    left: 8 + i * (barW + gap),
                    width: barW,
                    bottom: 27,
                    height: values[i] == 0 ? 3 : (78 * values[i] / max).clamp(3, 78).toDouble(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: i == current ? accent : IyoPalette.ink,
                        borderRadius: BorderRadius.circular(values[i] == 0 ? 1.5 : 4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8 + i * (barW + gap) - 8,
                    width: barW + 16,
                    top: 89,
                    child: IyoText(
                      labels[i],
                      variant: IyoTextVariant.micro,
                      color: IyoPalette.textSecondary,
                      align: TextAlign.center,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

const _monthsEn = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _monthsFr = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.', //
];
const _daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _daysFr = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];

bool _fr(BuildContext context) => Localizations.localeOf(context).languageCode == 'fr';

/// Calendar dates are shown in Douala time (UTC+1) whatever the device zone; plain local dates
/// (no time zone, e.g. payout periods) are shown as they are.
DateTime _douala(DateTime d) => d.isUtc ? d.add(const Duration(hours: 1)) : d;

String _month(BuildContext context, int m) => (_fr(context) ? _monthsFr : _monthsEn)[m - 1];

/// "12 Oct"
String formatDayMonth(BuildContext context, DateTime d) {
  final x = _douala(d);
  return '${x.day} ${_month(context, x.month)}';
}

/// "12 Oct 2026"
String formatLongDate(BuildContext context, DateTime d) {
  final x = _douala(d);
  return '${x.day} ${_month(context, x.month)} ${x.year}';
}

/// "Monday, 19 Oct"
String formatLongDay(BuildContext context, DateTime d) {
  final x = _douala(d);
  final day = (_fr(context) ? _daysFr : _daysEn)[x.weekday - 1];
  return '${_fr(context) ? day[0].toUpperCase() + day.substring(1) : day}, ${formatDayMonth(context, x)}';
}

/// "12–18 Oct 2026", "28 Sep – 4 Oct 2026", "1 Jan – 31 Dec 2026"
String formatPeriodRange(BuildContext context, DateTime start, DateTime endInclusive) {
  final a = _douala(start), b = _douala(endInclusive);
  if (a.year == b.year && a.month == b.month) {
    return '${a.day}–${b.day} ${_month(context, b.month)} ${b.year}';
  }
  if (a.year == b.year) {
    return '${formatDayMonth(context, a)} – ${formatDayMonth(context, b)} ${b.year}';
  }
  return '${formatLongDate(context, a)} – ${formatLongDate(context, b)}';
}

/// Two 24 px lines from the 2025 frames: 13 Medium title (optional bold aside and " ›"), then an
/// 11 px grey subtitle. Used for documents, payout history, ride history and detail links.
class RichRow extends StatelessWidget {
  const RichRow({
    super.key,
    required this.title,
    this.subtitle,
    this.aside,
    this.chevron = false,
    this.onPressed,
  });

  final String title;
  final String? subtitle;
  final String? aside;
  final bool chevron;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final base = IyoTextVariant.rowTitle.style.copyWith(height: 24 / 13, color: IyoPalette.ink);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: base,
            children: [
              TextSpan(text: title),
              if (aside != null)
                TextSpan(
                  text: '    $aside',
                  style: IyoTextVariant.bodyStrong.style.copyWith(fontSize: 12, height: 2),
                ),
              if (chevron) const TextSpan(text: '   ›'),
            ],
          ),
          textScaler: scaler,
          strutStyle: StrutStyle.fromTextStyle(base, forceStrutHeight: true),
        ),
        if (subtitle != null)
          IyoText(
            subtitle!,
            variant: IyoTextVariant.caption,
            color: IyoPalette.textSecondary,
            style: const TextStyle(height: 24 / 11),
          ),
      ],
    );
    if (onPressed == null) return SizedBox(width: double.infinity, child: body);
    return IyoPressable(
      onPressed: onPressed,
      semanticLabel: [title, if (aside != null) aside!, if (subtitle != null) subtitle!].join(', '),
      child: SizedBox(width: double.infinity, child: body),
    );
  }
}
