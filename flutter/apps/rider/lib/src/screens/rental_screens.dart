import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../state/rental.dart';
import '../widgets/rider_widgets.dart';
import 'trip_view.dart';

// Rentals R27–R35. No Figma frames were attached for these, so they are composed from the
// design-system pieces used by the ride screens (cards, list rows, badges, footer actions).

/// 41 200 (grouped like amounts, without the currency).
String _group(int n) => formatFcfa(n).replaceAll(RegExp(r'\s*FCFA$'), '');

String _transmission(BuildContext context, TransmissionType v) => switch (v) {
  TransmissionType.automatic => context.t.transmissionAutomatic,
  TransmissionType.manual => context.t.transmissionManual,
};

String _fuel(BuildContext context, FuelType v) => switch (v) {
  FuelType.petrol => context.t.fuelPetrol,
  FuelType.diesel => context.t.fuelDiesel,
  FuelType.hybrid => context.t.fuelHybrid,
  FuelType.electric => context.t.fuelElectric,
};

String _specLine(BuildContext context, RentalVehicle v) =>
    '${_fuel(context, v.fuelType)} · ${_transmission(context, v.transmission)} · '
    '${context.t.seatsCount('${v.seats}')}';

String _days(BuildContext context, int days) =>
    days == 1 ? context.t.oneDay : context.t.daysCount('$days');

String _period(BuildContext context, DateTime start, DateTime end) =>
    context.t.rentalDates(formatDateTime(start), formatDateTime(end));

IyoBadge rentalStatusBadge(BuildContext context, RentalBookingStatus s) {
  final t = context.t;
  return switch (s) {
    RentalBookingStatus.pendingPayment => IyoBadge(t.statusPendingPayment),
    RentalBookingStatus.confirmed => IyoBadge(t.statusConfirmed, tone: IyoBadgeTone.success),
    RentalBookingStatus.driverAssigned => IyoBadge(
      t.statusDriverAssigned,
      tone: IyoBadgeTone.success,
    ),
    RentalBookingStatus.active => IyoBadge(t.statusActive, tone: IyoBadgeTone.dark),
    RentalBookingStatus.returnPending => IyoBadge(t.statusReturnPending),
    RentalBookingStatus.completed => IyoBadge(t.statusCompleted, tone: IyoBadgeTone.neutral),
    RentalBookingStatus.cancelled => IyoBadge(t.statusCancelled, tone: IyoBadgeTone.neutral),
  };
}

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

/// Label on the left, amount or value on the right (receipts, specs, inspections).
class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value, {this.icon, this.strong = false});

  final String label;
  final String value;
  final IconData? icon;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        if (icon != null) ...[
          IyoIcon(icon!, size: IyoSizes.iconSmall, color: IyoPalette.textSecondary),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: IyoText(
            label,
            variant: strong ? IyoTextVariant.listTitle : IyoTextVariant.body,
            color: strong ? IyoPalette.ink : IyoPalette.charcoal,
          ),
        ),
        const SizedBox(width: 12),
        IyoText(value, variant: IyoTextVariant.bodyStrong),
      ],
    ),
  );
}

/// Home "Rent" segment (R27 entry).
class RentHomePanel extends StatelessWidget {
  const RentHomePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      IyoText(t.rentHomeTitle, variant: IyoTextVariant.cardTitle),
                      IyoText(t.rentHomeBody, color: IyoPalette.charcoal),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset('assets/images/rental_car.png', width: 96, fit: BoxFit.contain),
              ],
            ),
          ],
        ),
        IyoButton(
          label: t.browseCars,
          icon: LucideIcons.carFront,
          onPressed: () => context.push('/rent'),
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.calendarDays,
              iconWellTone: IyoIconWellTone.none,
              title: t.myRentals,
              onPressed: () => context.push('/rentals'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CarImage extends StatelessWidget {
  const _CarImage({this.width = 96, this.height = 56});

  final double width;
  final double height;

  // TODO(design): use the vehicle's own photo from rental_vehicles.image_paths.
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/rental_car.png',
    width: width,
    height: height,
    fit: BoxFit.contain,
  );
}

class _CarCard extends StatelessWidget {
  const _CarCard({required this.vehicle, this.onPressed});

  final RentalVehicle vehicle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoCard(
      onPressed: onPressed,
      children: [
        Row(
          children: [
            const _CarImage(width: 86, height: 48),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IyoText(vehicle.name, variant: IyoTextVariant.cardTitle),
                  Footnote(_specLine(context, vehicle)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      IyoBadge(t.perDay(formatFcfa(vehicle.dailyRate))),
                      if (vehicle.airportPickupAvailable)
                        IyoBadge(t.airportPickupBadge, tone: IyoBadgeTone.neutral),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// R27 — Browse the rental fleet of a city.
class RentBrowseScreen extends ConsumerWidget {
  const RentBrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final draft = ref.watch(rentalDraftProvider);
    final cars = ref.watch(rentalVehiclesProvider(draft.cityCode));
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      heading: IyoPageHeading(title: t.rentTitle, subtitle: t.rentSubtitle, onBack: context.pop),
      children: [
        IyoSegmentedTabs<String>(
          value: draft.cityCode,
          onChanged:
              (v) => ref.read(rentalDraftProvider.notifier).update((d) => RentalDraft(cityCode: v)),
          options: [
            IyoSegment(value: 'douala', label: t.cityDouala),
            IyoSegment(value: 'yaounde', label: t.cityYaounde),
          ],
        ),
        ...cars.when(
          loading: () => const [IyoSkeletonRow(), IyoSkeletonRow()],
          error:
              (_, _) => [
                IyoErrorState(
                  title: t.errorTitle,
                  message: CommonLocalizations.of(context).errorGeneric,
                  retryLabel: CommonLocalizations.of(context).actionRetry,
                  onRetry: () => ref.invalidate(rentalVehiclesProvider(draft.cityCode)),
                ),
              ],
          data:
              (list) =>
                  list.isEmpty
                      ? [
                        IyoEmptyState(
                          icon: LucideIcons.carFront,
                          title: t.noCarsTitle,
                          message: t.noCarsBody,
                        ),
                      ]
                      : [
                        for (final v in list)
                          _CarCard(
                            vehicle: v,
                            onPressed: () {
                              ref.read(rentalDraftProvider.notifier).chooseVehicle(v);
                              context.push('/rent/car');
                            },
                          ),
                        if (list.any((v) => v.isPlaceholderPricing)) Footnote(t.placeholderPricing),
                      ],
        ),
      ],
    );
  }
}

/// R28 — Car details.
class RentalCarScreen extends ConsumerWidget {
  const RentalCarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final v = ref.watch(rentalDraftProvider).vehicle;
    if (v == null) return const _LostDraft();
    Widget spec(String label, String value) => _ValueRow(label, value);
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      heading: IyoPageHeading(
        title: v.name,
        subtitle: [if (v.year != null) '${v.year}', if (v.color != null) v.color!].join(' · '),
        onBack: context.pop,
      ),
      footer: [IyoButton(label: t.chooseDates, onPressed: () => context.push('/rent/dates'))],
      children: [
        const Center(child: _CarImage(width: 240, height: 130)),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            IyoBadge(t.perDay(formatFcfa(v.dailyRate))),
            IyoBadge(_specLine(context, v), tone: IyoBadgeTone.neutral),
            if (v.airportPickupAvailable)
              IyoBadge(t.airportPickupBadge, tone: IyoBadgeTone.success),
          ],
        ),
        SectionTitle(t.carSpecs),
        IyoCard(
          children: [
            spec(t.specDailyRate, formatFcfa(v.dailyRate)),
            spec(t.specDeposit, formatFcfa(v.depositAmount)),
            spec(t.specKmPerDay, t.kmPerDayValue(_group(v.kmPerDay))),
            if (v.extraKmRate > 0) spec(t.specExtraKm, t.perKm(formatFcfa(v.extraKmRate))),
            spec(t.specPlate, v.plate),
          ],
        ),
        if (v.isPlaceholderPricing) Footnote(t.placeholderPricing),
      ],
    );
  }
}

/// Shown when a rental step is opened without a car chosen (e.g. after a restart).
class _LostDraft extends StatelessWidget {
  const _LostDraft();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      children: [
        IyoEmptyState(
          icon: LucideIcons.carFront,
          title: t.rentTitle,
          message: t.rentSubtitle,
          actionLabel: t.browseCars,
          onAction: () => context.go('/rent'),
        ),
      ],
    );
  }
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial.isBefore(now) ? now : initial,
    firstDate: DateTime(now.year, now.month, now.day),
    lastDate: now.add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Read-only field that opens the date + time pickers.
class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.label, required this.value, required this.onPick});

  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => IyoTextField(
    key: ValueKey('$label$value'),
    label: label,
    initialValue: value == null ? null : formatDateTime(value!),
    placeholder: context.t.pickDate,
    readOnly: true,
    onTap: onPick,
    trailing: const IyoIcon(LucideIcons.calendarDays, size: IyoSizes.iconSmall),
  );
}

/// R29 + R30 — Dates, then address delivery or airport pickup with flight details.
class RentalDatesScreen extends ConsumerStatefulWidget {
  const RentalDatesScreen({super.key});

  @override
  ConsumerState<RentalDatesScreen> createState() => _RentalDatesScreenState();
}

class _RentalDatesScreenState extends ConsumerState<RentalDatesScreen> {
  bool _showErrors = false;

  RentalDraftController get _ctrl => ref.read(rentalDraftProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final d = ref.watch(rentalDraftProvider);
    final v = d.vehicle;
    if (v == null) return const _LostDraft();
    final airports =
        (ref.watch(airportsProvider).value ?? const <Airport>[])
            .where((a) => a.cityCode == v.cityCode)
            .toList();
    final req = d.request;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final defaultStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10);

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      heading: IyoPageHeading(title: t.datesTitle, subtitle: t.datesSubtitle, onBack: context.pop),
      footer: [
        IyoButton(
          label: t.reviewAndPay,
          onPressed: () {
            if (req == null) {
              setState(() => _showErrors = true);
              return;
            }
            context.push('/rent/review');
          },
        ),
      ],
      children: [
        _CarCard(vehicle: v),
        _DateTimeField(
          label: t.startLabel,
          value: d.startsAt,
          onPick: () async {
            final s = await _pickDateTime(context, d.startsAt ?? defaultStart);
            if (s == null) return;
            _ctrl.update(
              (x) => x.copyWith(
                startsAt: s,
                endsAt:
                    x.endsAt == null || !x.endsAt!.isAfter(s)
                        ? s.add(const Duration(days: 1))
                        : null,
              ),
            );
          },
        ),
        _DateTimeField(
          label: t.endLabel,
          value: d.endsAt,
          onPick: () async {
            final start = d.startsAt ?? defaultStart;
            final e = await _pickDateTime(context, d.endsAt ?? start.add(const Duration(days: 1)));
            if (e != null) _ctrl.update((x) => x.copyWith(endsAt: e));
          },
        ),
        if (d.startsAt != null && d.endsAt != null)
          if (d.periodValid)
            IyoText(
              '${_days(context, rentalDays(d.startsAt!, d.endsAt!))} · '
              '${t.kmAllowance(_group(v.kmPerDay * rentalDays(d.startsAt!, d.endsAt!)))}',
              variant: IyoTextVariant.captionMedium,
            )
          else
            IyoText(t.periodInvalid, color: IyoPalette.danger),
        if (_showErrors && (d.startsAt == null || d.endsAt == null))
          IyoText(t.periodInvalid, color: IyoPalette.danger),
        IyoSegmentedTabs<RentalPickupType>(
          value: d.pickupType,
          onChanged: (p) => _ctrl.update((x) => x.copyWith(pickupType: p)),
          options: [
            IyoSegment(value: RentalPickupType.address, label: t.pickupAddress),
            IyoSegment(value: RentalPickupType.airport, label: t.pickupAirport),
          ],
        ),
        if (!d.isAirport)
          IyoTextField(
            label: t.deliveryAddress,
            placeholder: t.deliveryAddressHint,
            initialValue: d.address,
            error:
                _showErrors && !d.pickupValid
                    ? CommonLocalizations.of(context).validationRequired
                    : null,
            onChanged: (s) => _ctrl.update((x) => x.copyWith(address: s)),
            autofillHints: const [AutofillHints.fullStreetAddress],
          )
        else if (!v.airportPickupAvailable)
          IyoCard(tone: IyoCardTone.danger, children: [IyoText(t.airportUnavailable)])
        else ...[
          IyoSelectField<String>(
            label: t.airportLabel,
            value: d.airport?.code,
            sheetTitle: t.airportLabel,
            options: [
              for (final a in airports)
                IyoSelectOption(value: a.code, label: '${a.name} (${a.code})'),
            ],
            onChanged: (code) {
              final a = airports.firstWhere((x) => x.code == code);
              _ctrl.update(
                (x) => x.copyWith(
                  airport: a,
                  terminal: a.terminals.isEmpty ? null : a.terminals.first,
                ),
              );
            },
            error:
                _showErrors && d.airport == null
                    ? CommonLocalizations.of(context).validationRequired
                    : null,
          ),
          if ((d.airport?.terminals.length ?? 0) > 1)
            IyoSelectField<String>(
              label: t.terminalLabel,
              value: d.terminal,
              options: [
                for (final term in d.airport!.terminals) IyoSelectOption(value: term, label: term),
              ],
              onChanged: (term) => _ctrl.update((x) => x.copyWith(terminal: term)),
            ),
          IyoTextField(
            label: t.flightNumber,
            placeholder: t.flightNumberHint,
            initialValue: d.flightNumber,
            error:
                (_showErrors || d.flightNumber.length >= 3) && !isValidFlightNumber(d.flightNumber)
                    ? t.flightInvalid
                    : null,
            onChanged: (s) => _ctrl.update((x) => x.copyWith(flightNumber: s)),
          ),
          _DateTimeField(
            label: t.flightArrival,
            value: d.flightArrivalAt,
            onPick: () async {
              final a = await _pickDateTime(
                context,
                d.flightArrivalAt ?? d.startsAt ?? defaultStart,
              );
              if (a != null) _ctrl.update((x) => x.copyWith(flightArrivalAt: a));
            },
          ),
          if (d.airport != null) Footnote(t.airportFeeNote(formatFcfa(d.airport!.pickupFee))),
        ],
      ],
    );
  }
}

/// R31 — Review and pay. The server recomputes every amount (create_rental_booking).
class RentalReviewScreen extends ConsumerStatefulWidget {
  const RentalReviewScreen({super.key});

  @override
  ConsumerState<RentalReviewScreen> createState() => _RentalReviewScreenState();
}

class _RentalReviewScreenState extends ConsumerState<RentalReviewScreen> {
  bool _accepted = false;
  bool _booking = false;
  String? _error;

  Future<void> _book(RentalRequest req) async {
    final t = context.t;
    setState(() {
      _booking = true;
      _error = null;
    });
    try {
      final booking = await ref.read(backendProvider).bookRental(req);
      if (!mounted) return;
      ref.read(rentalDraftProvider.notifier).reset();
      context.go('/rentals/${booking.id}');
    } on BackendException catch (e) {
      setState(
        () =>
            _error = switch (e.code) {
              'vehicle_unavailable_for_dates' => t.carTaken,
              'invalid_rental_period' => t.periodInvalid,
              'airport_pickup_unavailable' => t.airportUnavailable,
              'invalid_payment_method' => t.paymentMethodMissing,
              _ => t.rentalFailed,
            },
      );
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final d = ref.watch(rentalDraftProvider);
    final req = d.request;
    if (req == null) return const _LostDraft();
    final cash = d.paymentMethod == PaymentMethodType.cash;
    Widget line(String label, String value, {bool strong = false}) =>
        _ValueRow(label, value, strong: strong);
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      heading: IyoPageHeading(
        title: t.reviewTitle,
        subtitle: t.reviewSubtitle,
        onBack: context.pop,
      ),
      footer: [
        if (_error != null) IyoText(_error!, color: IyoPalette.danger, align: TextAlign.center),
        IyoButton(
          label: cash ? t.bookCash : t.payAmount(formatFcfa(req.total)),
          loading: _booking,
          disabled: !_accepted,
          onPressed: _accepted && !_booking ? () => _book(req) : null,
        ),
      ],
      children: [
        _CarCard(vehicle: req.vehicle),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.calendarDays,
              iconWellTone: IyoIconWellTone.none,
              title: _period(context, req.startsAt, req.endsAt),
              titleVariant: IyoTextVariant.listTitle,
              subtitle: t.kmAllowance(_group(req.kmAllowance)),
              showChevron: false,
              verticalPadding: 0,
            ),
            IyoListRow(
              icon: d.isAirport ? LucideIcons.planeLanding : LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.none,
              title:
                  d.isAirport ? '${req.airport!.name} (${req.airport!.code})' : req.pickupAddress!,
              titleVariant: IyoTextVariant.listTitle,
              subtitle:
                  d.isAirport
                      ? [
                        req.flightNumber!.toUpperCase().replaceAll(' ', ''),
                        formatDateTime(req.flightArrivalAt!),
                        if (req.terminal != null) req.terminal!,
                      ].join(' · ')
                      : t.deliveryAddress,
              showChevron: false,
              verticalPadding: 0,
            ),
          ],
        ),
        IyoCard(
          children: [
            line(t.rentalAmountLine(_days(context, req.days)), formatFcfa(req.rentalAmount)),
            if (req.airportFee > 0) line(t.airportFeeLine, formatFcfa(req.airportFee)),
            const IyoDivider(),
            line(t.totalNow, formatFcfa(req.total), strong: true),
            line(t.depositLater, formatFcfa(req.vehicle.depositAmount)),
          ],
        ),
        IyoSelectField<PaymentMethodType>(
          label: t.paymentLabel,
          value: d.paymentMethod,
          sheetTitle: t.paymentMethod,
          options: [
            for (final m in PaymentMethodType.values)
              IyoSelectOption(value: m, label: paymentMethodLabel(context, m)),
          ],
          onChanged:
              (m) => ref
                  .read(rentalDraftProvider.notifier)
                  .update((x) => x.copyWith(paymentMethod: m)),
          helper: cash ? t.cashAtHandover : null,
        ),
        IyoCheckbox(
          value: _accepted,
          onChanged: (v) => setState(() => _accepted = v),
          label: t.rentalTerms,
        ),
        if (req.vehicle.isPlaceholderPricing) Footnote(t.placeholderPricing),
      ],
    );
  }
}

/// My rentals (also reached from the Activity tab).
class MyRentalsScreen extends ConsumerWidget {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final rentals = ref.watch(myRentalsProvider);
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      heading: IyoPageHeading(title: t.myRentals, onBack: context.pop),
      footer: [
        IyoButton(
          label: t.browseCars,
          variant: IyoButtonVariant.secondary,
          onPressed: () => context.push('/rent'),
        ),
      ],
      children: [
        ...rentals.when(
          loading: () => const [IyoSkeletonRow(), IyoSkeletonRow()],
          error:
              (_, _) => [
                IyoErrorState(
                  title: t.errorTitle,
                  message: CommonLocalizations.of(context).errorGeneric,
                  retryLabel: CommonLocalizations.of(context).actionRetry,
                  onRetry: () => ref.invalidate(myRentalsProvider),
                ),
              ],
          data:
              (list) =>
                  list.isEmpty
                      ? [
                        IyoEmptyState(
                          icon: LucideIcons.calendarDays,
                          title: t.rentalsEmptyTitle,
                          message: t.rentalsEmptyBody,
                        ),
                      ]
                      : [for (final b in list) RentalSummaryCard(booking: b)],
        ),
      ],
    );
  }
}

/// One booking in a list (My rentals, Activity).
class RentalSummaryCard extends StatelessWidget {
  const RentalSummaryCard({super.key, required this.booking});

  final RentalBooking booking;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final b = booking;
    return IyoCard(
      onPressed: () => context.push('/rentals/${b.id}'),
      children: [
        Row(
          children: [
            const _CarImage(width: 86, height: 48),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IyoText(b.vehicle.name, variant: IyoTextVariant.cardTitle),
                  Footnote(_specLine(context, b.vehicle)),
                ],
              ),
            ),
          ],
        ),
        IyoListRow(
          title: _period(context, b.startsAt, b.endsAt),
          titleVariant: IyoTextVariant.listTitle,
          inlineChevron: true,
          subtitle: [
            b.airportCode != null ? '${b.pickupAddress} (${b.airportCode})' : b.pickupAddress ?? '',
            t.bookingRef(b.reference),
          ].join(' · '),
          verticalPadding: 0,
        ),
        Align(alignment: Alignment.centerLeft, child: rentalStatusBadge(context, b.status)),
      ],
    );
  }
}

/// R32–R35 — One booking, following its status live: payment, confirmed, driver assigned,
/// handover check, active, return check, completed with the deposit outcome.
class RentalBookingScreen extends ConsumerStatefulWidget {
  const RentalBookingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<RentalBookingScreen> createState() => _RentalBookingScreenState();
}

class _RentalBookingScreenState extends ConsumerState<RentalBookingScreen> {
  bool _busy = false;
  bool _returnRequested = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on BackendException {
      if (mounted) _snack(context, CommonLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(RentalBooking b) async {
    final t = context.t;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (d) => AlertDialog(
            title: Text(t.cancelBookingTitle),
            content: Text(t.cancelBookingBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.keepBooking)),
              TextButton(
                onPressed: () => Navigator.pop(d, true),
                child: Text(t.cancelBooking, style: const TextStyle(color: IyoPalette.danger)),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _run(() => ref.read(backendProvider).cancelRental(b.id, reason: 'rider_cancelled'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final async = ref.watch(rentalProvider(widget.bookingId));
    final b = async.value;
    if (b == null) {
      return IyoScreen(
        header: IyoAppHeader(flowLabel: t.flowRent),
        children: [
          if (async.hasError)
            IyoErrorState(
              title: t.errorTitle,
              message: CommonLocalizations.of(context).errorGeneric,
              retryLabel: t.backHome,
              onRetry: () => context.go('/home'),
            )
          else
            const IyoSkeletonRow(),
        ],
      );
    }
    final backend = ref.read(backendProvider);
    final handoverReady = b.status == RentalBookingStatus.driverAssigned && b.handover != null;
    final returnReady = b.status == RentalBookingStatus.returnPending && b.returnInspection != null;

    final (String title, String body) = switch (b.status) {
      RentalBookingStatus.pendingPayment => (
        t.rentalPendingTitle,
        t.rentalPendingBody(formatFcfa(b.totalAmount)),
      ),
      RentalBookingStatus.confirmed => (t.rentalConfirmedTitle, t.rentalConfirmedBody),
      RentalBookingStatus.driverAssigned when handoverReady => (
        t.handoverReadyTitle,
        t.handoverReadyBody,
      ),
      RentalBookingStatus.driverAssigned => (
        t.rentalAssignedTitle,
        t.rentalAssignedBody(formatDateTime(b.startsAt)),
      ),
      RentalBookingStatus.active => (
        t.rentalActiveTitle,
        _returnRequested ? t.returnRequested : t.rentalActiveBody(formatDateTime(b.endsAt)),
      ),
      RentalBookingStatus.returnPending => (t.returnReadyTitle, t.returnReadyBody),
      RentalBookingStatus.completed => (
        t.rentalCompletedTitle,
        b.depositStatus == DepositStatus.partiallyHeld
            ? t.depositPartiallyHeld(formatFcfa(b.depositHeldAmount))
            : t.depositReleased,
      ),
      RentalBookingStatus.cancelled => (t.rentalCancelledTitle, t.bookingRef(b.reference)),
    };

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRent),
      heading: IyoPageHeading(title: title, subtitle: body, onBack: () => context.go('/rentals')),
      footer: [
        if (handoverReady)
          IyoButton(
            label: t.confirmHandover,
            loading: _busy,
            onPressed:
                _busy
                    ? null
                    : () => _run(() => backend.confirmInspection(b.id, InspectionType.handover)),
          ),
        if (returnReady)
          IyoButton(
            label: t.confirmReturn,
            loading: _busy,
            onPressed:
                _busy
                    ? null
                    : () => _run(() => backend.confirmInspection(b.id, InspectionType.return_)),
          ),
        if (b.status == RentalBookingStatus.active && !_returnRequested)
          IyoButton(
            label: t.returnCar,
            loading: _busy,
            onPressed:
                _busy
                    ? null
                    : () => _run(() async {
                      await backend.requestReturn(b.id);
                      if (mounted) setState(() => _returnRequested = true);
                    }),
          ),
        if (b.isCancellable && !handoverReady)
          IyoButton(
            label: t.cancelBooking,
            variant: IyoButtonVariant.secondary,
            onPressed: _busy ? null : () => _cancel(b),
          ),
        if (b.status == RentalBookingStatus.active)
          IyoButton(
            label: t.rentalReportProblem,
            variant: IyoButtonVariant.ghost,
            onPressed: () => context.push('/support'),
          ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            rentalStatusBadge(context, b.status),
            IyoBadge(t.bookingRef(b.reference), tone: IyoBadgeTone.neutral),
          ],
        ),
        if (b.status == RentalBookingStatus.pendingPayment ||
            (b.status == RentalBookingStatus.active && _returnRequested))
          LinearProgressIndicator(
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
            color: context.iyo.accent,
            backgroundColor: IyoPalette.surface,
          ),
        if (handoverReady) InspectionCard(inspection: b.handover!),
        if (returnReady) InspectionCard(inspection: b.returnInspection!, deposit: b.depositAmount),
        _CarCard(vehicle: b.vehicle),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.calendarDays,
              iconWellTone: IyoIconWellTone.none,
              title: _period(context, b.startsAt, b.endsAt),
              titleVariant: IyoTextVariant.listTitle,
              subtitle: '${_days(context, b.days)} · ${t.kmAllowance(_group(b.kmAllowance))}',
              showChevron: false,
              verticalPadding: 0,
            ),
            IyoListRow(
              icon: b.airportCode != null ? LucideIcons.planeLanding : LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.none,
              title:
                  b.airportCode != null
                      ? '${b.pickupAddress} (${b.airportCode})'
                      : b.pickupAddress ?? '',
              titleVariant: IyoTextVariant.listTitle,
              subtitle:
                  b.flightNumber != null
                      ? [
                        b.flightNumber!,
                        if (b.flightArrivalAt != null) formatDateTime(b.flightArrivalAt!),
                        if (b.terminal != null) b.terminal!,
                      ].join(' · ')
                      : null,
              showChevron: false,
              verticalPadding: 0,
            ),
          ],
        ),
        IyoCard(
          children: [
            _ValueRow(t.rentalAmountLine(_days(context, b.days)), formatFcfa(b.rentalAmount)),
            if (b.airportFee > 0) _ValueRow(t.airportFeeLine, formatFcfa(b.airportFee)),
            _ValueRow(paymentMethodLabel(context, b.paymentMethod), formatFcfa(b.totalAmount)),
            _ValueRow(t.specDeposit, formatFcfa(b.depositAmount)),
          ],
        ),
        if (b.status == RentalBookingStatus.active)
          IyoListRow(
            icon: LucideIcons.shieldCheck,
            title: t.tileSafety,
            onPressed: () => context.push('/safety-alert'),
          ),
      ],
    );
  }
}

/// Fuel, odometer, photos and damage recorded by the driver (handover or return).
class InspectionCard extends StatelessWidget {
  const InspectionCard({super.key, required this.inspection, this.deposit});

  final RentalInspection inspection;

  /// Return inspections: the deposit, to show what would be kept.
  final int? deposit;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final i = inspection;
    Widget row(IconData icon, String label, String value) => _ValueRow(label, value, icon: icon);
    return IyoCard(
      tone: IyoCardTone.accent,
      children: [
        IyoText(
          i.type == InspectionType.handover ? t.inspectionHandover : t.inspectionReturn,
          variant: IyoTextVariant.cardTitle,
        ),
        row(LucideIcons.fuel, t.fuelLevel, t.fuelEighths('${i.fuelLevel}')),
        row(LucideIcons.gauge, t.odometer, t.kmValue(_group(i.odometerKm))),
        row(LucideIcons.camera, t.photosTaken, t.photosCount('${i.photoPaths.length}')),
        IyoText(
          i.damageNotes == null || i.damageNotes!.trim().isEmpty ? t.noDamage : i.damageNotes!,
          color: IyoPalette.charcoal,
        ),
        if (deposit != null && i.type == InspectionType.return_)
          row(LucideIcons.wallet, t.depositHoldProposed, formatFcfa(i.depositHoldAmount)),
      ],
    );
  }
}
