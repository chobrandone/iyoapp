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

import '../sample/sample_data.dart';
import '../widgets/driver_widgets.dart';
import 'bookings_screens.dart';
import 'home_screens.dart';
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

//// "Sat, 17 Oct" (Douala time).
String _weekdayDay(BuildContext context, DateTime d) {
  final x = d.toUtc().add(const Duration(hours: 1));
  final fr = Localizations.localeOf(context).languageCode == 'fr';
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const frDays = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
  return '${(fr ? frDays : en)[x.weekday - 1]}, ${formatDayMonth(context, d)}';
}

/// What DR01 / DR02 print, from a live booking or the Figma sample.
class _RentalView {
  const _RentalView({
    required this.ref,
    required this.car,
    required this.plate,
    required this.fuel,
    required this.start,
    required this.end,
    required this.days,
    required this.place,
    required this.shortPlace,
    required this.riderName,
    required this.riderFirst,
    required this.deposit,
    required this.paymentMethod,
    this.riderPhone,
    this.flight,
    this.flightRoute,
    this.landing,
    this.terminal,
    this.photo,
  });

  factory _RentalView.of(BuildContext context, RentalBooking b) => _RentalView(
    ref: b.reference,
    car: b.vehicle.name,
    plate: b.vehicle.plate,
    fuel: fuelLabel(context, b.vehicle.fuelType),
    start: b.startsAt,
    end: b.endsAt,
    days: b.days,
    place:
        b.airportCode != null
            ? [b.pickupAddress ?? '', if (b.terminal != null) b.terminal!].join(', ')
            : b.pickupAddress ?? '',
    shortPlace: b.airportCode != null ? 'Douala (${b.airportCode})' : b.pickupAddress ?? '',
    riderName: b.riderName ?? '–',
    riderFirst: _firstName(b),
    riderPhone: b.riderPhone,
    deposit: b.depositAmount,
    paymentMethod: b.paymentMethod,
    flight: b.flightNumber,
    landing: b.flightArrivalAt,
    terminal: b.terminal,
  );

  static final sample = _RentalView(
    ref: 'IYO-R1730',
    car: DriverSample.rentalCar,
    plate: DriverSample.rentalPlate,
    fuel: 'Petrol',
    start: DriverSample.rentalStart,
    end: DriverSample.rentalEnd,
    days: DriverSample.rentalDays,
    place: 'Douala International Airport, Arrivals',
    shortPlace: 'Douala (DLA)',
    riderName: DriverSample.riderName,
    riderFirst: DriverSample.riderFirstName,
    deposit: DriverSample.rentalDeposit,
    paymentMethod: PaymentMethodType.mtnMomo,
    flight: DriverSample.rentalFlight,
    flightRoute: DriverSample.rentalFlightRoute,
    landing: DriverSample.flightLanding,
    terminal: 'Arrivals',
    photo: DriverSample.riderPhoto,
  );

  final String ref, car, plate, fuel, place, shortPlace, riderName, riderFirst;
  final DateTime start, end;
  final int days, deposit;
  final PaymentMethodType paymentMethod;
  final String? riderPhone, flight, flightRoute, terminal;
  final DateTime? landing;
  final ImageProvider? photo;

  bool get airport => flight != null;
}

/// DRIVER RENTAL · 01 — Rental booking and airport requirements (Figma 2005:51637). Also the
/// collection screen once the rider has the car (return inspection).
class RentalDeliveryScreen extends ConsumerWidget {
  const RentalDeliveryScreen({super.key, this.bookingId});

  /// Null: Figma sample content.
  final String? bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final preview = bookingId == null;
    final async = preview ? null : ref.watch(rentalProvider(bookingId!));
    final b = async?.value;
    if (!preview && b == null) {
      return IyoScreen(
        header: DriverHeader(flowLabel: t.flowDriverRental('01')),
        children: [
          if (async!.hasError)
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
    final v = preview ? _RentalView.sample : _RentalView.of(context, b!);
    final status = b?.status ?? RentalBookingStatus.driverAssigned;
    final collecting =
        status == RentalBookingStatus.active || status == RentalBookingStatus.returnPending;
    final waitingReturn = status == RentalBookingStatus.returnPending;
    final done = status == RentalBookingStatus.completed || status == RentalBookingStatus.cancelled;

    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowDriverRental('01')),
      heading: IyoPageHeading(
        title:
            collecting
                ? t.rentalReturnTitle
                : v.airport
                ? t.airportRentalPickup
                : t.addressRentalPickup,
        subtitle: t.confirmedBooking(v.ref),
        onBack: preview ? null : context.pop,
      ),
      footer: [
        if (!done)
          IyoButton(
            label: t.navigateToPlace(v.shortPlace),
            onPressed: preview ? () {} : () => _navigateTo(v.place),
          ),
        if (!preview && !collecting && !done)
          IyoButton(
            label: t.openHandover,
            variant: IyoButtonVariant.secondary,
            onPressed: () => context.push('/rental/${b!.id}/handover'),
          ),
        if (!preview && status == RentalBookingStatus.active)
          IyoButton(
            label: t.startReturn,
            variant: IyoButtonVariant.secondary,
            onPressed: () => context.push('/rental/${b!.id}/inspect/return'),
          ),
        if (!preview)
          IyoButton(
            label: t.reportIncident,
            variant: IyoButtonVariant.ghost,
            onPressed:
                () => context.push(
                  '/incident?rental=${b!.id}&ref=${Uri.encodeQueryComponent(b.reference)}',
                ),
          ),
      ],
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child:
              done
                  ? driverRentalBadge(context, b!)
                  : collecting
                  ? IyoBadge(t.withRiderUntil(formatRentalWhen(v.end)), tone: IyoBadgeTone.success)
                  : IyoBadge(t.upcomingWhen(formatRentalWhen(v.start))),
        ),
        IyoCard(
          children: [
            IyoText(t.carWithFuel(v.car, v.fuel), variant: IyoTextVariant.subheading),
            IyoText(
              t.rentalPeriodDays(
                formatPeriodRange(context, v.start, v.end),
                daysLabel(context, v.days),
              ),
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
            IyoListRow(
              icon: LucideIcons.calendarDays,
              iconWellTone: IyoIconWellTone.none,
              title: t.pickupOn(_weekdayDay(context, v.start)),
              subtitle: t.timeAtPlace(formatTime(v.start), v.place),
              showChevron: false,
            ),
            IyoListRow(
              icon: LucideIcons.calendarCheck,
              iconWellTone: IyoIconWellTone.none,
              title: t.returnOn(_weekdayDay(context, v.end)),
              subtitle: t.timeAtPlace(formatTime(v.end), v.place),
              showChevron: false,
            ),
          ],
        ),
        IyoPersonInfoCard(
          name: v.riderName,
          photo: v.photo,
          meta: t.verifiedRider(DriverSample.riderRating),
          detail: t.askHandoverPin,
          onCall: preview ? () {} : (v.riderPhone == null ? null : () => _dial(v.riderPhone)),
          callLabel: t.callRider(v.riderFirst),
        ),
        if (waitingReturn)
          IyoCard(
            tone: IyoCardTone.accent,
            children: [IyoText(t.waitingRiderConfirm(v.riderFirst), color: IyoPalette.charcoal)],
          )
        else if (v.airport && !collecting)
          IyoCard(
            tone: IyoCardTone.accent,
            children: [
              IyoText(t.airportRequirementsTitle, variant: IyoTextVariant.subheading),
              IyoText(
                [
                  t.flightLine(v.flight!, v.flightRoute ?? v.shortPlace),
                  if (v.landing != null)
                    t.landingLine(formatRentalWhen(v.landing!), v.terminal ?? ''),
                  t.meetLine(formatTime(v.start), v.riderFirst),
                ].join('\n'),
                color: IyoPalette.charcoal,
              ),
            ],
          ),
        Footnote(
          v.airport ? t.prepareCarNote('45', v.riderFirst) : t.prepareCarNoteAddress(v.riderFirst),
        ),
      ],
    );
  }
}

/// DRIVER RENTAL · 02 — Handover checklist (Figma 2005:51686): identity check, deposit, the
/// photo inspection, then the rider's handover PIN starts the rental.
class RentalHandoverScreen extends ConsumerStatefulWidget {
  const RentalHandoverScreen({super.key, this.bookingId});

  /// Null: Figma sample content.
  final String? bookingId;

  @override
  ConsumerState<RentalHandoverScreen> createState() => _RentalHandoverScreenState();
}

class _RentalHandoverScreenState extends ConsumerState<RentalHandoverScreen> {
  late bool _identityChecked = widget.bookingId == null;
  late String _pin = widget.bookingId == null ? '6318' : '';
  String? _error;
  bool _busy = false;
  bool _locked = false;

  Future<void> _confirm(RentalBooking b) async {
    final t = context.t;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(backendProvider).confirmHandoverPin(b.id, _pin);
      if (!mounted) return;
      if (r.ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.handoverDone)));
        context.go('/rental/${b.id}');
      } else if (r.locked) {
        setState(() {
          _locked = true;
          _error = t.handoverPinLocked;
        });
      } else {
        setState(() {
          _pin = '';
          _error = t.handoverPinWrong('${r.attemptsLeft}');
        });
      }
    } on BackendException {
      if (mounted) setState(() => _error = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.bookingId == null;
    final b = preview ? null : ref.watch(rentalProvider(widget.bookingId!)).value;
    if (!preview && b == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final v = preview ? _RentalView.sample : _RentalView.of(context, b!);
    final inspection = b?.handover;
    final photosDone = preview || inspection != null;
    final allChecked = _identityChecked && photosDone;

    Widget check({
      required IconData icon,
      required String title,
      required String subtitle,
      required bool done,
      VoidCallback? onPressed,
    }) => IyoListRow(
      icon: icon,
      iconWellTone: IyoIconWellTone.none,
      title: title,
      subtitle: subtitle,
      trailing:
          done
              ? const IyoText('✓', variant: IyoTextVariant.bodyStrong)
              : const IyoIcon(LucideIcons.chevronRight, size: 16),
      showChevron: false,
      onPressed: onPressed,
    );

    final fuel =
        preview
            ? t.fullTank
            : inspection == null
            ? ''
            : inspection.fuelLevel == 8
            ? t.fullTank
            : t.tankEighths('${inspection.fuelLevel}');
    final km =
        preview
            ? '41 200'
            : inspection == null
            ? ''
            : formatFcfa(inspection.odometerKm).replaceAll(RegExp(r'\s*FCFA$'), '');

    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowDriverRental('02')),
      heading: IyoPageHeading(
        title: t.smoothHandover,
        subtitle: t.handoverSubtitle(v.riderName, v.shortPlace, formatDayMonth(context, v.start)),
        onBack: preview ? null : context.pop,
      ),
      footer: [
        IyoButton(
          label: t.confirmHandoverStart,
          loading: _busy,
          disabled: !preview && (!allChecked || _pin.length != 4 || _locked),
          onPressed: preview ? () {} : () => _confirm(b!),
        ),
      ],
      children: [
        Align(alignment: Alignment.centerLeft, child: IyoBadge(t.carPlateBadge(v.car, v.plate))),
        IyoCard(
          children: [
            check(
              icon: LucideIcons.circleCheck,
              title: t.checkIdentity,
              subtitle: _identityChecked ? t.checkIdentityBody : t.checkIdentityTap,
              done: _identityChecked,
              onPressed:
                  preview ? null : () => setState(() => _identityChecked = !_identityChecked),
            ),
            check(
              icon: LucideIcons.circleCheck,
              title: t.checkDeposit,
              subtitle: t.checkDepositBody(
                formatFcfa(v.deposit),
                paymentLabel(context, v.paymentMethod),
              ),
              done: true,
            ),
            check(
              icon: LucideIcons.camera,
              title: t.checkPhotos,
              subtitle:
                  photosDone
                      ? t.checkPhotosDone(
                        preview ? '5' : '${inspection!.photoPaths.length}',
                        (inspection?.damageNotes ?? '').trim().isEmpty
                            ? t.noNewDamage
                            : t.damageNoted,
                      )
                      : t.checkPhotosTodo,
              done: photosDone,
              onPressed:
                  preview || photosDone
                      ? null
                      : () => context.push('/rental/${b!.id}/inspect/handover'),
            ),
            check(
              icon: LucideIcons.fuel,
              title: t.checkFuel,
              subtitle: photosDone ? t.checkFuelDone(fuel, km) : t.checkFuelTodo,
              done: photosDone,
            ),
          ],
        ),
        IyoPinInput(
          label: t.customerHandoverPin,
          value: _pin,
          highlighted: preview,
          onChanged:
              (v) => setState(() {
                _pin = v;
                _error = null;
              }),
          error: _error,
          helper:
              preview
                  ? t.handoverPinVerified
                  : (ref.watch(backendProvider).isDemo ? t.pinDemoHint(demoHandoverPin) : null),
        ),
        Footnote(
          t.handoverReturnNote(
            '${_weekdayDay(context, v.end)} · ${formatTime(v.end)}',
            v.shortPlace,
            v.riderFirst,
          ),
        ),
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
