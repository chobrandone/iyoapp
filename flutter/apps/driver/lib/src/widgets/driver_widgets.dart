import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../../l10n/gen/app_localizations.dart';

extension DriverL10n on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

LatLng ll(GeoPoint p) => LatLng(p.lat, p.lng);

/// Driver header: wordmark + DRIVER badge (spec §5).
class DriverHeader extends StatelessWidget {
  const DriverHeader({super.key, this.flowLabel});

  final String? flowLabel;

  @override
  Widget build(BuildContext context) => IyoAppHeader(badge: context.t.badge, flowLabel: flowLabel);
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
  });

  final GeoPoint me;
  final double heading;
  final GeoPoint? pickup;
  final GeoPoint? destination;
  final double height;

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
