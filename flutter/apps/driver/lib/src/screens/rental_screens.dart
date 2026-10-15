import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/driver_widgets.dart';
import 'onboarding_screens.dart';

// D15–D16: rental deliveries assigned to this driver, with the handover / return checklist.

Future<void> _dial(String? phone) async {
  if (phone == null) return;
  await launchUrl(Uri(scheme: 'tel', path: phone));
}

Future<void> _navigateTo(String query) => launchUrl(
  Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(query)}'),
  mode: LaunchMode.externalApplication,
);

String _firstName(RentalBooking b) => (b.riderName ?? '').trim().split(RegExp(r'\s+')).first;

IyoBadge driverRentalBadge(BuildContext context, RentalBooking b) {
  final t = context.t;
  return switch (b.status) {
    RentalBookingStatus.driverAssigned when b.handover != null => IyoBadge(
      t.rentalStatusAwaitingRider,
    ),
    RentalBookingStatus.driverAssigned ||
    RentalBookingStatus.confirmed ||
    RentalBookingStatus
        .pendingPayment => IyoBadge(t.rentalStatusToDeliver, tone: IyoBadgeTone.dark),
    RentalBookingStatus.active => IyoBadge(t.rentalStatusWithRider, tone: IyoBadgeTone.success),
    RentalBookingStatus.returnPending => IyoBadge(t.rentalStatusReturnCheck),
    RentalBookingStatus.completed ||
    RentalBookingStatus.cancelled => IyoBadge(t.rentalStatusDone, tone: IyoBadgeTone.neutral),
  };
}

/// D15 — Assigned rentals (Bookings tab, "Rentals" segment).
class AssignedRentalsList extends ConsumerWidget {
  const AssignedRentalsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final rentals = ref.watch(assignedRentalsProvider);
    final list = rentals.value;
    if (list == null) return const IyoSkeletonRow();
    if (list.isEmpty) {
      return IyoEmptyState(
        title: t.noRentalsTitle,
        message: t.noRentalsBody,
        icon: LucideIcons.keyRound,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [for (final b in list) _RentalCard(booking: b)],
    );
  }
}

class _RentalCard extends StatelessWidget {
  const _RentalCard({required this.booking});

  final RentalBooking booking;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final b = booking;
    final collecting =
        b.status == RentalBookingStatus.active || b.status == RentalBookingStatus.returnPending;
    return IyoCard(
      onPressed: () => context.push('/rental/${b.id}'),
      children: [
        IyoListRow(
          title: '${b.vehicle.name} · ${b.vehicle.plate}',
          titleVariant: IyoTextVariant.listTitle,
          inlineChevron: true,
          subtitle: [
            t.rentalFor(b.riderName ?? '–'),
            collecting
                ? t.collectBy(formatDateTime(b.endsAt))
                : t.deliverAt(formatDateTime(b.startsAt)),
          ].join(' · '),
          verticalPadding: 0,
        ),
        IyoListRow(
          icon: b.airportCode != null ? LucideIcons.planeLanding : LucideIcons.mapPin,
          iconWellTone: IyoIconWellTone.none,
          title:
              b.airportCode != null
                  ? '${b.pickupAddress} (${b.airportCode})'
                  : b.pickupAddress ?? '',
          subtitle:
              b.flightNumber != null
                  ? t.flightArrives(
                    b.flightNumber!,
                    b.flightArrivalAt == null ? '–' : formatTime(b.flightArrivalAt!),
                  )
                  : null,
          showChevron: false,
          verticalPadding: 0,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            driverRentalBadge(context, b),
            IyoBadge(t.rentalRef(b.reference), tone: IyoBadgeTone.neutral),
          ],
        ),
      ],
    );
  }
}

/// D16 — One delivery: rider, place, airport requirements, then the checklist.
class RentalDeliveryScreen extends ConsumerWidget {
  const RentalDeliveryScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final async = ref.watch(rentalProvider(bookingId));
    final b = async.value;
    if (b == null) {
      return IyoScreen(
        header: DriverHeader(flowLabel: t.flowRental),
        children: [
          if (async.hasError)
            IyoErrorState(
              title: t.errorGeneric,
              retryLabel: t.backToHome,
              onRetry: () => context.go('/home'),
            )
          else
            const IyoSkeletonRow(),
        ],
      );
    }
    final name = _firstName(b);
    final collecting =
        b.status == RentalBookingStatus.active || b.status == RentalBookingStatus.returnPending;
    final waitingRider =
        (b.status == RentalBookingStatus.driverAssigned && b.handover != null) ||
        b.status == RentalBookingStatus.returnPending;
    final place =
        b.airportCode != null ? '${b.pickupAddress} (${b.airportCode})' : b.pickupAddress ?? '';

    final String status = switch (b.status) {
      _ when waitingRider => t.waitingRiderConfirm(name),
      RentalBookingStatus.active => t.rentalWithRider(formatDateTime(b.endsAt)),
      RentalBookingStatus.completed || RentalBookingStatus.cancelled => t.rentalCompleted,
      _ => t.deliverAt(formatDateTime(b.startsAt)),
    };

    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowRental),
      heading: IyoPageHeading(
        title: collecting ? t.collectTitle(b.vehicle.name) : t.deliveryTitle(b.vehicle.name),
        subtitle: collecting ? t.collectSubtitle(name) : t.deliverySubtitle(name),
        onBack: context.pop,
      ),
      footer: [
        if (b.status == RentalBookingStatus.driverAssigned && b.handover == null)
          IyoButton(
            label: t.startHandover,
            onPressed: () => context.push('/rental/${b.id}/inspect/handover'),
          ),
        if (b.status == RentalBookingStatus.active)
          IyoButton(
            label: t.startReturn,
            onPressed: () => context.push('/rental/${b.id}/inspect/return'),
          ),
        IyoButton(
          label: t.reportIncident,
          variant: IyoButtonVariant.ghost,
          onPressed:
              () => context.push(
                '/incident?rental=${b.id}&ref=${Uri.encodeQueryComponent(b.reference)}',
              ),
        ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            driverRentalBadge(context, b),
            IyoBadge(t.rentalRef(b.reference), tone: IyoBadgeTone.neutral),
          ],
        ),
        IyoCard(
          tone: waitingRider ? IyoCardTone.accent : IyoCardTone.surface,
          children: [IyoText(status, color: IyoPalette.charcoal)],
        ),
        IyoPersonInfoCard(
          name: b.riderName ?? '–',
          meta: formatPhone(b.riderPhone ?? ''),
          detail: '${b.vehicle.name} · ${b.vehicle.plate}',
          onCall: b.riderPhone == null ? null : () => _dial(b.riderPhone),
          callLabel: t.callRider(name),
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: b.airportCode != null ? LucideIcons.planeLanding : LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.none,
              title: place,
              titleVariant: IyoTextVariant.listTitle,
              subtitle:
                  b.flightNumber != null
                      ? [
                        t.flightArrives(
                          b.flightNumber!,
                          b.flightArrivalAt == null ? '–' : formatDateTime(b.flightArrivalAt!),
                        ),
                        if (b.terminal != null) b.terminal!,
                      ].join(' · ')
                      : t.deliverAt(formatDateTime(b.startsAt)),
              showChevron: false,
              verticalPadding: 0,
            ),
            IyoButton(
              label: t.navigateTo,
              icon: LucideIcons.navigation,
              variant: IyoButtonVariant.secondary,
              size: IyoButtonSize.sm,
              onPressed: () => _navigateTo(place),
            ),
          ],
        ),
        if (b.airportCode != null)
          IyoCard(
            tone: IyoCardTone.accent,
            children: [IyoText(t.airportRequirements, color: IyoPalette.charcoal)],
          ),
        IyoText(t.depositToHold(formatFcfa(b.depositAmount)), variant: IyoTextVariant.caption),
      ],
    );
  }
}

String _sideLabel(BuildContext context, String side) {
  final t = context.t;
  return switch (side) {
    'front' => t.photoFront,
    'back' => t.photoBack,
    'left' => t.photoLeft,
    'right' => t.photoRight,
    _ => t.photoInterior,
  };
}

/// Handover / return checklist: five photos, fuel, odometer, damage, checks, deposit (return).
class InspectionScreen extends ConsumerStatefulWidget {
  const InspectionScreen({super.key, required this.bookingId, required this.type});

  final String bookingId;
  final InspectionType type;

  @override
  ConsumerState<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends ConsumerState<InspectionScreen> {
  final _photos = <String, String>{};
  int _fuel = 8;
  String _odometer = '';
  String _damage = '';
  String _hold = '0';
  final _checks = {'documents': true, 'spare': true, 'clean': true};
  bool _showErrors = false;
  double? _progress;
  String? _error;

  bool get _isReturn => widget.type == InspectionType.return_;

  Future<void> _takePhoto(String side) async {
    final path = await ref.read(documentPickerProvider)(ImageSource.camera);
    if (path != null && mounted) setState(() => _photos[side] = path);
  }

  Future<void> _submit(RentalBooking b) async {
    final t = context.t;
    final odometer = int.tryParse(_odometer.replaceAll(RegExp(r'\D'), ''));
    final hold = _isReturn ? int.tryParse(_hold.replaceAll(RegExp(r'\D'), '')) : 0;
    final valid =
        inspectionSides.every(_photos.containsKey) &&
        odometer != null &&
        hold != null &&
        hold >= 0 &&
        hold <= b.depositAmount;
    if (!valid) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await ref
          .read(backendProvider)
          .submitInspection(
            b.id,
            widget.type,
            InspectionDraft(
              fuelLevel: _fuel,
              odometerKm: odometer,
              localPhotos: Map.of(_photos),
              damageNotes: _damage.trim().isEmpty ? null : _damage.trim(),
              checklist: Map.of(_checks),
              depositHoldAmount: hold,
            ),
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      if (mounted) context.pop();
    } on BackendException {
      if (mounted) setState(() => _error = t.inspectionFailed);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final b = ref.watch(rentalProvider(widget.bookingId)).value;
    if (b == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final missingPhotos = !inspectionSides.every(_photos.containsKey);
    final holdValue = int.tryParse(_hold.replaceAll(RegExp(r'\D'), ''));
    final busy = _progress != null;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowRental),
      heading: IyoPageHeading(
        title: _isReturn ? t.returnTitle : t.handoverTitle,
        subtitle: t.checklistSubtitle,
        onBack: context.pop,
      ),
      footer: [
        if (_error != null) IyoText(_error!, color: IyoPalette.danger, align: TextAlign.center),
        if (busy)
          IyoText(
            t.uploadingPhotos('${(_progress! * 100).round()}'),
            variant: IyoTextVariant.caption,
            align: TextAlign.center,
          ),
        IyoButton(
          label: t.submitHandover,
          loading: busy,
          onPressed: busy ? null : () => _submit(b),
        ),
      ],
      children: [
        IyoText('${b.vehicle.name} · ${b.vehicle.plate}', variant: IyoTextVariant.listTitle),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final side in inspectionSides)
              _PhotoTile(
                label: _sideLabel(context, side),
                path: _photos[side],
                missing: _showErrors && !_photos.containsKey(side),
                onPressed: busy ? null : () => _takePhoto(side),
              ),
          ],
        ),
        if (_showErrors && missingPhotos) IyoText(t.photosRequired, color: IyoPalette.danger),
        IyoFormField(
          label: t.fuelLabel,
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _fuel.toDouble(),
                  max: 8,
                  divisions: 8,
                  label: t.fuelValue('$_fuel'),
                  onChanged: busy ? null : (v) => setState(() => _fuel = v.round()),
                ),
              ),
              IyoText(t.fuelValue('$_fuel'), variant: IyoTextVariant.bodyStrong),
            ],
          ),
        ),
        IyoTextField(
          label: t.odometerLabel,
          keyboardType: TextInputType.number,
          onChanged: (v) => _odometer = v,
          error: _showErrors && int.tryParse(_odometer) == null ? t.odometerInvalid : null,
        ),
        IyoTextField(
          label: t.damageLabel,
          placeholder: t.damageHint,
          multiline: true,
          onChanged: (v) => _damage = v,
        ),
        IyoCheckbox(
          value: _checks['documents']!,
          onChanged: (v) => setState(() => _checks['documents'] = v),
          label: t.checkDocuments,
        ),
        IyoCheckbox(
          value: _checks['spare']!,
          onChanged: (v) => setState(() => _checks['spare'] = v),
          label: t.checkSpare,
        ),
        IyoCheckbox(
          value: _checks['clean']!,
          onChanged: (v) => setState(() => _checks['clean'] = v),
          label: t.checkClean,
        ),
        if (_isReturn)
          IyoTextField(
            label: t.depositHoldLabel,
            initialValue: _hold,
            keyboardType: TextInputType.number,
            helper: t.depositHoldHelper(formatFcfa(b.depositAmount)),
            error:
                _showErrors && (holdValue == null || holdValue > b.depositAmount)
                    ? t.depositHoldInvalid(formatFcfa(b.depositAmount))
                    : null,
            onChanged: (v) => setState(() => _hold = v),
          ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.label, this.path, this.missing = false, this.onPressed});

  final String label;
  final String? path;
  final bool missing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = path;
    final hasFile = p != null && !kIsWeb && File(p).existsSync();
    return Semantics(
      button: true,
      label: '$label · ${p == null ? t.takePhoto : t.retakePhoto}',
      excludeSemantics: true,
      child: IyoPressable(
        onPressed:
            onPressed == null
                ? null
                : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
        child: Container(
          decoration: BoxDecoration(
            color: IyoPalette.surface,
            borderRadius: BorderRadius.circular(IyoRadii.md),
            border: Border.all(
              color: missing ? IyoPalette.danger : IyoPalette.border,
              width: missing ? 1.5 : 1,
            ),
            image: hasFile ? DecorationImage(image: FileImage(File(p)), fit: BoxFit.cover) : null,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hasFile)
                Expanded(
                  child: Center(
                    child: IyoIcon(
                      p == null ? LucideIcons.camera : LucideIcons.check,
                      color: p == null ? IyoPalette.muted : IyoPalette.success,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: IyoPalette.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IyoText(label, variant: IyoTextVariant.captionMedium, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
