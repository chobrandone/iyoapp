import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/driver_location.dart';
import '../widgets/driver_widgets.dart';

Future<void> _dial(String number) => launchUrl(Uri(scheme: 'tel', path: number));

String _police(List<EmergencyNumber> numbers) =>
    numbers.firstWhere((n) => n.service == 'police', orElse: () => numbers.first).number;

/// Live trip "Safety": share the trip, report an incident, call the police.
/// Creates a share token for the ride and opens the system share sheet.
Future<void> shareRide(BuildContext context, WidgetRef ref, String rideId) async {
  final t = context.t;
  try {
    final share = await ref.read(backendProvider).shareTrip(rideId);
    await SharePlus.instance.share(
      ShareParams(
        text: t.shareTripText(formatTime(share.expiresAt), share.url),
        subject: t.shareTripSubject,
      ),
    );
  } on BackendException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.shareFailed)));
    }
  }
}

Future<void> showDriverSafetySheet(
  BuildContext context,
  WidgetRef ref,
  String rideId, {
  VoidCallback? onCancel,
}) {
  final t = context.t;
  final numbers = ref.read(emergencyNumbersProvider).value ?? defaultEmergencyNumbers;
  final police = _police(numbers);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: IyoPalette.white,
    barrierColor: IyoPalette.overlay,
    builder:
        (sheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                IyoText(t.safetySheetTitle, variant: IyoTextVariant.cardTitle),
                IyoListRow(
                  icon: LucideIcons.share2,
                  title: t.shareTrip,
                  subtitle: t.shareTripBody,
                  onPressed: () {
                    Navigator.pop(sheet);
                    shareRide(context, ref, rideId);
                  },
                ),
                IyoListRow(
                  icon: LucideIcons.triangleAlert,
                  title: t.reportIncident,
                  subtitle: t.reportIncidentBody,
                  onPressed: () {
                    Navigator.pop(sheet);
                    context.push('/incident?ride=$rideId');
                  },
                ),
                if (onCancel != null)
                  IyoListRow(
                    icon: LucideIcons.circleX,
                    title: t.cancelThisRide,
                    destructive: true,
                    onPressed: () {
                      Navigator.pop(sheet);
                      onCancel();
                    },
                  ),
                IyoButton(
                  label: t.callPolice(police),
                  icon: LucideIcons.phoneCall,
                  variant: IyoButtonVariant.danger,
                  onPressed: () => _dial(police),
                ),
              ],
            ),
          ),
        ),
  );
}

const incidentCategories = [
  'accident',
  'rider_behaviour',
  'vehicle_damage',
  'theft_or_aggression',
  'lost_item',
  'payment',
  'other',
];

String incidentCategoryLabel(BuildContext context, String code) {
  final t = context.t;
  return switch (code) {
    'accident' => t.incidentAccident,
    'rider_behaviour' => t.incidentRiderBehaviour,
    'vehicle_damage' => t.incidentVehicleDamage,
    'theft_or_aggression' => t.incidentTheft,
    'lost_item' => t.incidentLostItem,
    'payment' => t.incidentPayment,
    _ => t.incidentOther,
  };
}

/// D17 — Incident report (Figma 2005:51696; frame not attached). The server attaches a snapshot
/// of the ride or rental (report_incident), we add the driver's position.
class IncidentReportScreen extends ConsumerStatefulWidget {
  const IncidentReportScreen({super.key, this.rideId, this.rentalBookingId, this.rentalRef});

  final String? rideId;
  final String? rentalBookingId;
  final String? rentalRef;

  @override
  ConsumerState<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends ConsumerState<IncidentReportScreen> {
  String? _category;
  String _description = '';
  bool _urgent = false;
  bool _sending = false;
  String? _error;

  Future<void> _send(GeoPoint? at) async {
    final t = context.t;
    if (_category == null) {
      setState(() => _error = t.pickCategory);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final report = await ref
          .read(backendProvider)
          .reportIncident(
            category: _category!,
            description: _description.trim().isEmpty ? null : _description.trim(),
            rideId: widget.rideId,
            rentalBookingId: widget.rentalBookingId,
            at: at,
            urgent: _urgent,
          );
      if (!mounted) return;
      context.pushReplacement(
        '/incident/sent',
        extra: ReportSentArgs(report: report, urgent: _urgent, rideId: widget.rideId),
      );
    } on BackendException {
      if (mounted) setState(() => _error = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final position = ref.watch(lastPositionProvider);
    // The default point is a placeholder until the first GPS fix; never send it as a location.
    final at = position.point == doualaDefault ? null : position.point;
    final numbers = ref.watch(emergencyNumbersProvider).value ?? defaultEmergencyNumbers;
    final police = _police(numbers);
    final about =
        widget.rideId != null
            ? t.incidentAboutTrip
            : widget.rentalRef != null
            ? t.incidentAboutRental(widget.rentalRef!)
            : null;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowIncident),
      heading: IyoPageHeading(
        title: t.incidentTitle,
        subtitle: t.incidentSubtitle,
        onBack: context.pop,
      ),
      footer: [
        if (_error != null) IyoText(_error!, color: IyoPalette.danger, align: TextAlign.center),
        IyoButton(
          label: t.sendReport,
          loading: _sending,
          onPressed: _sending ? null : () => _send(at),
        ),
      ],
      children: [
        IyoCard(
          tone: IyoCardTone.danger,
          onPressed: () => _dial(police),
          children: [
            IyoListRow(
              icon: LucideIcons.phoneCall,
              iconWellTone: IyoIconWellTone.none,
              title: t.incidentEmergency(police),
              titleVariant: IyoTextVariant.listTitle,
              showChevron: false,
              verticalPadding: 0,
            ),
          ],
        ),
        if (about != null) IyoBadge(t.incidentAbout(about), tone: IyoBadgeTone.neutral),
        IyoSelectField<String>(
          label: t.incidentCategory,
          sheetTitle: t.incidentCategory,
          value: _category,
          options: [
            for (final c in incidentCategories)
              IyoSelectOption(value: c, label: incidentCategoryLabel(context, c)),
          ],
          onChanged: (c) => setState(() => _category = c),
        ),
        IyoTextField(
          label: t.incidentDescription,
          placeholder: t.incidentDescriptionHint,
          multiline: true,
          onChanged: (v) => _description = v,
        ),
        IyoToggle(
          value: _urgent,
          onChanged: (v) => setState(() => _urgent = v),
          label: t.incidentUrgent,
          description: t.incidentUrgentBody,
        ),
        IyoText(
          at == null
              ? t.incidentNoLocation
              : t.incidentLocation('${at.lat.toStringAsFixed(5)}, ${at.lng.toStringAsFixed(5)}'),
          variant: IyoTextVariant.caption,
          color: IyoPalette.textSecondary,
        ),
      ],
    );
  }
}

class ReportSentArgs {
  const ReportSentArgs({required this.report, required this.urgent, this.rideId});

  final IncidentReport report;
  final bool urgent;
  final String? rideId;
}

/// D18 — Report sent (Figma 2005:51744; frame not attached).
class ReportSentScreen extends ConsumerWidget {
  const ReportSentScreen({super.key, required this.args});

  final ReportSentArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final a = args;
    final numbers = ref.watch(emergencyNumbersProvider).value ?? defaultEmergencyNumbers;
    final police = _police(numbers);
    final ref6 = a == null ? '—' : a.report.id.replaceAll('-', '').substring(0, 6).toUpperCase();
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowReportSent),
      heading: IyoPageHeading(title: t.reportSentTitle, subtitle: t.reportSentSubtitle),
      footer: [
        IyoButton(
          label: a?.rideId != null ? t.backToTrip : t.backToHome,
          onPressed: () => a?.rideId != null ? context.pop() : context.go('/home'),
        ),
        IyoButton(
          label: t.callPolice(police),
          variant: IyoButtonVariant.ghost,
          onPressed: () => _dial(police),
        ),
      ],
      children: [
        IyoCard(
          tone: IyoCardTone.success,
          children: [
            IyoListRow(
              icon: LucideIcons.checkCheck,
              iconWellTone: IyoIconWellTone.none,
              title:
                  a == null ? t.reportSentTitle : incidentCategoryLabel(context, a.report.category),
              titleVariant: IyoTextVariant.listTitle,
              subtitle: t.reportReference(ref6, a == null ? '' : formatTime(a.report.createdAt)),
              showChevron: false,
              verticalPadding: 0,
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoText(
              a?.urgent == true ? t.reportUrgentNote : t.reportNextNote,
              color: IyoPalette.charcoal,
            ),
          ],
        ),
      ],
    );
  }
}
