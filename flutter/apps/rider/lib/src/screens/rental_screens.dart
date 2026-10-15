import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../sample/sample_data.dart';
import '../state/rental.dart';
import '../widgets/rider_widgets.dart';
import 'trip_view.dart';

// Rentals: Figma "Rentals · Browse cars" (RENTAL · 01) to "Active rental" (RENTAL · 07), plus
// "Manage booking" and "Return inspection and deposit". Cameroon content in place of the London
// samples; every amount comes from the server (create_rental_booking) once booked.

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

/// 41 200 (grouped like amounts, without the currency).
String _group(int n) => formatFcfa(n).replaceAll(RegExp(r'\s*FCFA$'), '');

DateTime _douala(DateTime d) => d.isUtc ? d.add(const Duration(hours: 1)) : d;

bool _fr(BuildContext c) => Localizations.localeOf(c).languageCode == 'fr';

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

String _monthShort(BuildContext c, int m) => (_fr(c) ? _monthsFr : _monthsEn)[m - 1];

/// "17 Oct"
String _dayMonth(BuildContext c, DateTime d) {
  final x = _douala(d);
  return '${x.day} ${_monthShort(c, x.month)}';
}

/// "Sat, 17 Oct"
String _weekdayDay(BuildContext c, DateTime d) {
  final x = _douala(d);
  final names =
      _fr(c)
          ? const ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.']
          : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${names[x.weekday - 1]}, ${_dayMonth(c, d)}';
}

/// "17–20 Oct" (+ " 2026" with [year]).
String _range(BuildContext c, DateTime a, DateTime b, {bool year = false}) {
  final x = _douala(a), y = _douala(b);
  final r =
      x.month == y.month && x.year == y.year
          ? '${x.day}–${y.day} ${_monthShort(c, y.month)}'
          : '${_dayMonth(c, a)} – ${_dayMonth(c, b)}';
  return year ? '$r ${y.year}' : r;
}

String _days(BuildContext c, int n) => n == 1 ? c.t.oneDay : c.t.daysCount('$n');

String _fuel(BuildContext c, FuelType v) => switch (v) {
  FuelType.petrol => c.t.fuelPetrol,
  FuelType.diesel => c.t.fuelDiesel,
  FuelType.hybrid => c.t.fuelHybrid,
  FuelType.electric => c.t.fuelElectric,
};

String _gearbox(BuildContext c, TransmissionType v) => switch (v) {
  TransmissionType.automatic => c.t.transmissionAutomatic,
  TransmissionType.manual => c.t.transmissionManual,
};

/// "Petrol · Automatic · 5 seats" (SUVs show their body type first, like the frame).
String _specs(BuildContext c, RentalVehicle v) => [
  if (v.category == 'suv') 'SUV' else _fuel(c, v.fuelType),
  _gearbox(c, v.transmission),
  c.t.seatsCount('${v.seats}'),
].join(' · ');

String _airportName(BuildContext c, String? code) => switch (code) {
  'DLA' => 'Douala (DLA)',
  'NSI' => 'Yaoundé Nsimalen (NSI)',
  _ => code ?? '',
};

/// Airline from the flight number prefix (IATA), for the "✓ Air France · flight AF900" check.
String? airlineFor(String flight) {
  final f = flight.toUpperCase().replaceAll(' ', '');
  if (f.length < 2) return null;
  return const {
    'AF': 'Air France',
    'SN': 'Brussels Airlines',
    'ET': 'Ethiopian Airlines',
    'KQ': 'Kenya Airways',
    'QC': 'Camair-Co',
    'TK': 'Turkish Airlines',
    'AT': 'Royal Air Maroc',
    'WB': 'RwandAir',
    'HF': 'Air Côte d’Ivoire',
    'KP': 'ASKY Airlines',
    'MS': 'EgyptAir',
    'LH': 'Lufthansa',
    'EK': 'Emirates',
    'QR': 'Qatar Airways',
  }[f.substring(0, 2)];
}

// ---------------------------------------------------------------------------
// Car photos (until rental_vehicles.image_paths are uploaded)
// ---------------------------------------------------------------------------

String _carAsset(RentalVehicle v, {bool large = false}) =>
    v.category == 'suv' || v.category == 'pickup'
        ? 'assets/images/car_suv.png'
        : (large ? 'assets/images/car_large.png' : 'assets/images/car_sedan.png');

// TODO(design): use the vehicle's own photo from rental_vehicles.image_paths.
class _CarPhoto extends StatelessWidget {
  const _CarPhoto(this.vehicle, {this.width = 92, this.height = 62, this.large = false});

  final RentalVehicle vehicle;
  final double width;
  final double height;
  final bool large;

  @override
  Widget build(BuildContext context) => Image.asset(
    _carAsset(vehicle, large: large),
    width: width,
    height: height,
    fit: BoxFit.cover,
  );
}

// ---------------------------------------------------------------------------
// Figma sample content (design previews)
// ---------------------------------------------------------------------------

abstract final class RentalSample {
  static final car = demoRentalFleet.first; // Toyota Corolla
  static final suv = demoRentalFleet[1]; // Toyota RAV4
  static final start = DateTime.utc(2026, 10, 17, 9);
  static final end = DateTime.utc(2026, 10, 20, 9);
  static final landing = DateTime.utc(2026, 10, 17, 8, 15);
  static const protectionDaily = 3000;

  static RentalDraft draft({bool airport = true}) => RentalDraft(
    vehicle: car,
    startsAt: start,
    endsAt: end,
    pickupType: airport ? RentalPickupType.airport : RentalPickupType.address,
    airport: demoAirports.first,
    terminal: 'Arrivals',
    flightNumber: 'AF900',
    flightArrivalAt: landing,
    protection: true,
    protectionDaily: protectionDaily,
  );

  static RentalBooking booking(RentalBookingStatus status) {
    final r = RentalRequest(
      vehicle: car,
      startsAt: start,
      endsAt: end,
      pickupType: RentalPickupType.airport,
      paymentMethod: PaymentMethodType.mtnMomo,
      airport: demoAirports.first,
      protection: true,
      protectionDaily: protectionDaily,
    );
    return RentalBooking(
      id: 'sample-rental',
      reference: 'RN-2048',
      vehicle: car,
      status: status,
      startsAt: start,
      endsAt: end,
      pickupType: RentalPickupType.airport,
      days: r.days,
      dailyRate: car.dailyRate,
      rentalAmount: r.rentalAmount,
      airportFee: r.airportFee,
      protectionAmount: r.protectionAmount,
      depositAmount: car.depositAmount,
      totalAmount: r.total,
      kmAllowance: r.kmAllowance,
      paymentMethod: PaymentMethodType.mtnMomo,
      pickupAddress: 'Douala International Airport',
      airportCode: 'DLA',
      terminal: 'Arrivals',
      flightNumber: 'AF900',
      flightArrivalAt: landing,
      depositStatus:
          status == RentalBookingStatus.active || status == RentalBookingStatus.returnPending
              ? DepositStatus.held
              : DepositStatus.notCollected,
      handoverPin: '6318',
      driver: const Counterpart(
        id: 'demo-driver',
        firstName: Sample.driverFirstName,
        fullName: Sample.driverFullName,
        phone: '+237677889900',
        rating: 4.9,
        ratingCount: 1248,
      ),
      handover: RentalInspection(
        type: InspectionType.handover,
        fuelLevel: 8,
        odometerKm: 41200,
        photoPaths: {for (final s in inspectionSides) s: s},
        inspectorConfirmedAt: start,
        riderConfirmedAt: start.add(const Duration(minutes: 8)),
      ),
      returnInspection:
          status == RentalBookingStatus.returnPending
              ? RentalInspection(
                type: InspectionType.return_,
                fuelLevel: 8,
                odometerKm: 41512,
                photoPaths: {for (final s in inspectionSides) s: s},
                inspectorConfirmedAt: end.subtract(const Duration(minutes: 5)),
              )
              : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

/// Rental frames space blocks 14 apart.
class _RentalScreen extends StatelessWidget {
  const _RentalScreen({
    required this.flow,
    required this.title,
    this.subtitle,
    this.onBack,
    this.footer = const [],
    required this.children,
  });

  final String flow;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IyoScreenDefaults(
    blockGap: 14,
    child: IyoScreen(
      header: IyoAppHeader(flowLabel: flow),
      heading: IyoPageHeading(title: title, subtitle: subtitle, onBack: onBack),
      footer: footer,
      children: children,
    ),
  );
}

/// Photo, name, specs and daily-rate badge (Figma "Rental vehicle").
class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary(this.vehicle);

  final RentalVehicle vehicle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _CarPhoto(vehicle),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            IyoText(vehicle.name, variant: IyoTextVariant.cardTitle),
            IyoText(
              _specs(context, vehicle),
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
            IyoBadge(context.t.perDay(formatFcfa(vehicle.dailyRate))),
          ],
        ),
      ),
    ],
  );
}

/// Car + period + pickup / return rows (review, booked).
class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.vehicle,
    required this.start,
    required this.end,
    required this.days,
    required this.place,
  });

  final RentalVehicle vehicle;
  final DateTime start, end;
  final int days;
  final String place;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoCard(
      children: [
        IyoText(
          '${vehicle.name} · ${_fuel(context, vehicle.fuelType)}',
          variant: IyoTextVariant.subheading,
        ),
        IyoText(
          '${_range(context, start, end, year: true)} · ${_days(context, days)}',
          variant: IyoTextVariant.caption,
          color: IyoPalette.textSecondary,
        ),
        IyoListRow(
          icon: LucideIcons.calendarDays,
          iconWellTone: IyoIconWellTone.none,
          title: t.pickupDay(_weekdayDay(context, start)),
          subtitle: t.timePlace(formatTime(start), place),
          showChevron: false,
        ),
        IyoListRow(
          icon: LucideIcons.calendarCheck,
          iconWellTone: IyoIconWellTone.none,
          title: t.returnDay(_weekdayDay(context, end)),
          subtitle: t.timePlace(formatTime(end), place),
          showChevron: false,
        ),
      ],
    );
  }
}

/// Label left, amount right (price breakdowns).
class _AmountLine extends StatelessWidget {
  const _AmountLine(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      children: [
        Expanded(
          child: IyoText(
            label,
            variant: strong ? IyoTextVariant.bodyStrong : IyoTextVariant.body,
            color: strong ? IyoPalette.ink : IyoPalette.textSecondary,
            style: strong ? const TextStyle(fontSize: 12) : null,
          ),
        ),
        IyoText(value, variant: IyoTextVariant.bodyStrong, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

/// Two 24 px lines from the 2025 frames (13 Medium title with optional " ›", 11 px subtitle).
class _RichRow extends StatelessWidget {
  const _RichRow({required this.title, this.subtitle, this.chevron = false, this.onPressed});

  final String title;
  final String? subtitle;
  final bool chevron;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final body = SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IyoText(
            chevron ? '$title   ›' : title,
            variant: IyoTextVariant.rowTitle,
            style: const TextStyle(height: 24 / 13),
          ),
          if (subtitle != null)
            IyoText(
              subtitle!,
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
              style: const TextStyle(height: 24 / 11),
            ),
        ],
      ),
    );
    return onPressed == null ? body : IyoPressable(onPressed: onPressed, child: body);
  }
}

IyoBadge rentalStatusBadge(BuildContext context, RentalBookingStatus s) {
  final t = context.t;
  return switch (s) {
    RentalBookingStatus.pendingPayment => IyoBadge(t.statusPendingPayment),
    RentalBookingStatus.confirmed => IyoBadge(t.statusConfirmed, tone: IyoBadgeTone.success),
    RentalBookingStatus.driverAssigned => IyoBadge(
      t.confirmedHandoverPending,
      tone: IyoBadgeTone.success,
    ),
    RentalBookingStatus.active => IyoBadge(t.statusActive, tone: IyoBadgeTone.success),
    RentalBookingStatus.returnPending => IyoBadge(t.statusReturnPending),
    RentalBookingStatus.completed => IyoBadge(t.statusCompleted, tone: IyoBadgeTone.neutral),
    RentalBookingStatus.cancelled => IyoBadge(t.statusCancelled, tone: IyoBadgeTone.neutral),
  };
}

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

Widget _lostDraft(BuildContext context) {
  final t = context.t;
  return _RentalScreen(
    flow: t.flowRentalPlain,
    title: t.rentTitle,
    children: [
      IyoEmptyState(
        icon: LucideIcons.carFront,
        title: t.rentTitle,
        message: t.rentSubtitle,
        actionLabel: t.browseCars,
        onAction: () => context.go('/home?service=rent'),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// RENTAL · 01 — Browse (inside Home, "Rent a car")
// ---------------------------------------------------------------------------

/// Date row and the city's cars (Figma 2005:50641). Shown under the Ride / Rent a car switch.
class RentBrowseContent extends ConsumerWidget {
  const RentBrowseContent({super.key, this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final d = preview ? RentalSample.draft() : ref.watch(rentalDraftProvider);
    final cars =
        preview
            ? AsyncValue.data([RentalSample.car, RentalSample.suv])
            : ref.watch(rentalVehiclesProvider(d.cityCode));
    final days = d.days ?? 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        IyoListRow(
          icon: LucideIcons.calendarDays,
          title: t.datesRowTitle(_range(context, d.startsAt!, d.endsAt!), _days(context, days)),
          subtitle: t.datesRowSub(formatTime(d.startsAt!)),
          showChevron: false,
          onPressed: preview ? null : () => context.push('/rent/dates'),
        ),
        ...cars.when(
          loading: () => const [IyoSkeletonRow(), IyoSkeletonRow()],
          error:
              (_, _) => [
                IyoErrorState(
                  title: t.errorTitle,
                  message: CommonLocalizations.of(context).errorGeneric,
                  retryLabel: CommonLocalizations.of(context).actionRetry,
                  onRetry: () => ref.invalidate(rentalVehiclesProvider(d.cityCode)),
                ),
              ],
          data:
              (list) => [
                if (list.isEmpty)
                  IyoEmptyState(
                    icon: LucideIcons.carFront,
                    title: t.noCarsTitle,
                    message: t.noCarsBody,
                  ),
                for (final v in list)
                  IyoCard(
                    children: [
                      _VehicleSummary(v),
                      IyoText(
                        v.airportPickupAvailable
                            ? t.airportAvailableLine(_group(v.kmPerDay))
                            : t.kmPerDayLine(_group(v.kmPerDay)),
                        variant: IyoTextVariant.caption,
                        color: IyoPalette.textSecondary,
                      ),
                      IyoButton(
                        label: t.viewCarFor(
                          v.model,
                          formatFcfa(v.dailyRate * days),
                          _days(context, days),
                        ),
                        variant: IyoButtonVariant.secondary,
                        onPressed:
                            preview
                                ? () {}
                                : () {
                                  ref.read(rentalDraftProvider.notifier).chooseVehicle(v);
                                  context.push('/rent/car');
                                },
                      ),
                    ],
                  ),
                if (!preview)
                  InlineLink(
                    lead: '',
                    link: t.myRentalsLink,
                    onPressed: () => context.push('/rentals'),
                  ),
              ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// RENTAL · 02 — Vehicle details
// ---------------------------------------------------------------------------

final _protectionDailyProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(backendProvider).rentalProtectionDaily(),
);

class RentalCarScreen extends ConsumerWidget {
  const RentalCarScreen({super.key, this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final d = preview ? RentalSample.draft() : ref.watch(rentalDraftProvider);
    final v = d.vehicle;
    if (v == null) return _lostDraft(context);
    final protectionDaily =
        preview ? RentalSample.protectionDaily : ref.watch(_protectionDailyProvider).value ?? 0;
    final airport = demoAirports.firstWhere(
      (a) => a.cityCode == v.cityCode,
      orElse: () => demoAirports.first,
    );
    final tagline = switch (v.category) {
      'suv' => t.taglineSuv,
      'economy' => t.taglineEconomy,
      'pickup' => t.taglinePickup,
      _ => t.taglineSedan,
    };
    Widget feature(IconData icon, String title, String subtitle, {Widget? trailing}) => IyoListRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      showChevron: false,
    );
    return _RentalScreen(
      flow: t.flowRental('02'),
      title: v.name,
      subtitle: tagline,
      onBack: preview ? null : context.pop,
      footer: [
        IyoButton(
          label: t.chooseDatesPrice(formatFcfa(v.dailyRate)),
          onPressed: preview ? () {} : () => context.push('/rent/dates'),
        ),
      ],
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: IyoPalette.surface,
            borderRadius: BorderRadius.circular(IyoRadii.lg),
          ),
          alignment: Alignment.center,
          child: _CarPhoto(v, width: 300, height: 170, large: true),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IyoBadge(_gearbox(context, v.transmission)),
            IyoBadge(t.seatsBadge('${v.seats}')),
            IyoBadge(_fuel(context, v.fuelType)),
          ],
        ),
        IyoText(t.perDayPrice(formatFcfa(v.dailyRate)), variant: IyoTextVariant.title),
        feature(
          LucideIcons.gauge,
          t.kmIncludedTitle(_group(v.kmPerDay)),
          t.kmIncludedSub(formatFcfa(v.extraKmRate)),
        ),
        feature(
          LucideIcons.shieldCheck,
          t.coverTitle,
          d.protection && !preview
              ? t.coverAdded(formatFcfa(protectionDaily))
              : t.coverSub(formatFcfa(protectionDaily)),
          trailing:
              preview || protectionDaily == 0
                  ? null
                  : IyoToggle(
                    value: d.protection,
                    semanticLabel: t.coverSub(formatFcfa(protectionDaily)),
                    onChanged:
                        (on) => ref
                            .read(rentalDraftProvider.notifier)
                            .update(
                              (x) => x.copyWith(protection: on, protectionDaily: protectionDaily),
                            ),
                  ),
        ),
        if (v.airportPickupAvailable)
          feature(
            LucideIcons.plane,
            t.airportAvailableTitle,
            t.airportAvailableSub(
              _airportName(context, airport.code),
              formatFcfa(airport.pickupFee),
            ),
          )
        else
          feature(LucideIcons.mapPin, t.addressOnlyTitle, t.addressOnlySub),
        Footnote(t.detailsFootnote(formatFcfa(v.depositAmount))),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// RENTAL · 03 — Date and time selection
// ---------------------------------------------------------------------------

DateTime _dateOnly(DateTime d) {
  final x = _douala(d);
  return DateTime(x.year, x.month, x.day);
}

class RentalDatesScreen extends ConsumerStatefulWidget {
  const RentalDatesScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<RentalDatesScreen> createState() => _RentalDatesScreenState();
}

class _RentalDatesScreenState extends ConsumerState<RentalDatesScreen> {
  late DateTime _month;
  bool _pickingEnd = false;

  @override
  void initState() {
    super.initState();
    final d = widget.preview ? RentalSample.draft() : ref.read(rentalDraftProvider);
    final s = _dateOnly(d.startsAt ?? DateTime.now());
    _month = DateTime(s.year, s.month);
  }

  RentalDraftController get _ctrl => ref.read(rentalDraftProvider.notifier);

  /// [day] at the time of [time] (Douala), as a device-local DateTime.
  DateTime _at(DateTime day, DateTime? time) {
    final t = time == null ? null : _douala(time);
    return DateTime(day.year, day.month, day.day, t?.hour ?? 10, t?.minute ?? 0);
  }

  void _tapDay(DateTime day, RentalDraft d) {
    if (!_pickingEnd || d.startsAt == null || day.isBefore(_dateOnly(d.startsAt!))) {
      final start = _at(day, d.startsAt);
      _ctrl.update((x) => x.copyWith(startsAt: start, endsAt: start.add(const Duration(days: 1))));
      setState(() => _pickingEnd = true);
    } else {
      final end = _at(day, d.endsAt ?? d.startsAt);
      _ctrl.update((x) => x.copyWith(endsAt: end));
      setState(() => _pickingEnd = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final d = preview ? RentalSample.draft() : ref.watch(rentalDraftProvider);
    final v = d.vehicle;
    if (v == null) return _lostDraft(context);
    final start = d.startsAt!, end = d.endsAt!;
    final days = d.days ?? 1;
    final today = preview ? DateTime(2026, 10, 13) : _dateOnly(DateTime.now());
    final valid = preview || d.periodValid;

    final times = [
      for (var h = 6; h <= 21; h++) ...[
        '${h.toString().padLeft(2, '0')}:00',
        '${h.toString().padLeft(2, '0')}:30',
      ],
    ];
    DateTime withTime(DateTime day, String hhmm) {
      final p = hhmm.split(':');
      final x = _dateOnly(day);
      return DateTime(x.year, x.month, x.day, int.parse(p[0]), int.parse(p[1]));
    }

    String hm(DateTime x) {
      final s = formatTime(x);
      return times.contains(s) ? s : times.first;
    }

    return _RentalScreen(
      flow: t.flowRental('03'),
      title: t.makeTime,
      subtitle: t.makeTimeSub,
      onBack: preview ? null : context.pop,
      footer: [
        IyoButton(
          label: t.continueDays(_days(context, days)),
          disabled: !valid,
          onPressed: preview ? () {} : (valid ? () => context.push('/rent/pickup') : null),
        ),
      ],
      children: [
        _Calendar(
          month: _month,
          today: today,
          start: _dateOnly(start),
          end: _dateOnly(end),
          onMonth: (m) => setState(() => _month = m),
          onDay: preview ? null : (day) => _tapDay(day, d),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: IyoSelectField<String>(
                label: t.pickupFieldLabel(_dayMonth(context, start)),
                value: hm(start),
                sheetTitle: t.pickupFieldLabel(_dayMonth(context, start)),
                options: [for (final x in times) IyoSelectOption(value: x, label: x)],
                onChanged: (x) => _ctrl.update((r) => r.copyWith(startsAt: withTime(start, x))),
              ),
            ),
            Expanded(
              child: IyoSelectField<String>(
                label: t.returnFieldLabel(_dayMonth(context, end)),
                value: hm(end),
                sheetTitle: t.returnFieldLabel(_dayMonth(context, end)),
                options: [for (final x in times) IyoSelectOption(value: x, label: x)],
                onChanged: (x) => _ctrl.update((r) => r.copyWith(endsAt: withTime(end, x))),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child:
              valid
                  ? IyoBadge(t.daysBasePrice(_days(context, days), formatFcfa(v.dailyRate * days)))
                  : IyoBadge(t.periodInvalid, tone: IyoBadgeTone.danger),
        ),
        Footnote(_pickingEnd && !preview ? t.pickReturnDay : t.datesFootnote),
      ],
    );
  }
}

/// Month grid (Figma "Information card" calendar): past days grey, the pickup and return days
/// yellow, the days between pale yellow.
class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.month,
    required this.today,
    required this.start,
    required this.end,
    required this.onMonth,
    this.onDay,
  });

  final DateTime month, today, start, end;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<DateTime>? onDay;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final accent = context.iyo.accent;
    final names = t.monthNames.split(',');
    final first = DateTime(month.year, month.month);
    final lead = first.weekday - 1;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final cells = <DateTime?>[
      for (var i = 0; i < lead; i++) null,
      for (var dd = 1; dd <= count; dd++) DateTime(month.year, month.month, dd),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final canGoBack = month.isAfter(DateTime(today.year, today.month));
    final title = names[month.month - 1];

    Widget day(DateTime? x) {
      if (x == null) return const Expanded(child: SizedBox(height: 36));
      final past = x.isBefore(today);
      final isEnd = x == start || x == end;
      final between = x.isAfter(start) && x.isBefore(end);
      return Expanded(
        child: Semantics(
          button: !past,
          selected: isEnd,
          label: '${x.day} ${names[x.month - 1]}',
          excludeSemantics: true,
          child: IyoPressable(
            minHitSize: 0,
            onPressed: past || onDay == null ? null : () => onDay!(x),
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isEnd ? accent : (between ? context.iyo.accentSoft : null),
                borderRadius: isEnd ? BorderRadius.circular(8) : null,
              ),
              child: IyoText(
                '${x.day}',
                color: past ? const Color(0xFFAFAFAF) : IyoPalette.ink,
                style: TextStyle(fontWeight: isEnd || between ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
          ),
        ),
      );
    }

    return IyoCard(
      children: [
        Row(
          children: [
            IyoPressable(
              minHitSize: 0,
              onPressed: canGoBack ? () => onMonth(DateTime(month.year, month.month - 1)) : null,
              semanticLabel: '‹',
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: IyoText('‹', variant: IyoTextVariant.cardTitle),
              ),
            ),
            Expanded(
              child: IyoText(
                '${title[0].toUpperCase()}${title.substring(1)} ${month.year}',
                variant: IyoTextVariant.cardTitle,
                align: TextAlign.center,
              ),
            ),
            IyoPressable(
              minHitSize: 0,
              onPressed: () => onMonth(DateTime(month.year, month.month + 1)),
              semanticLabel: '›',
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: IyoText('›', variant: IyoTextVariant.cardTitle),
              ),
            ),
          ],
        ),
        Row(
          children: [
            for (final w in t.weekdayInitials.split(','))
              Expanded(
                child: IyoText(
                  w,
                  variant: IyoTextVariant.helper,
                  color: IyoPalette.textSecondary,
                  align: TextAlign.center,
                ),
              ),
          ],
        ),
        for (var r = 0; r < cells.length; r += 7)
          Row(children: [for (final c in cells.sublist(r, r + 7)) day(c)]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// RENTAL · 04 — Airport pickup details / delivery address
// ---------------------------------------------------------------------------

class RentalPickupScreen extends ConsumerStatefulWidget {
  const RentalPickupScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<RentalPickupScreen> createState() => _RentalPickupScreenState();
}

class _RentalPickupScreenState extends ConsumerState<RentalPickupScreen> {
  bool _showErrors = false;

  RentalDraftController get _ctrl => ref.read(rentalDraftProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final d = preview ? RentalSample.draft() : ref.watch(rentalDraftProvider);
    final v = d.vehicle;
    if (v == null) return _lostDraft(context);
    final airports =
        preview
            ? demoAirports
            : (ref.watch(airportsProvider).value ?? const <Airport>[])
                .where((a) => a.cityCode == v.cityCode)
                .toList();
    final airline = airlineFor(d.flightNumber);
    final flightOk = isValidFlightNumber(d.flightNumber);
    final start = d.startsAt!;
    final arrival = d.flightArrivalAt ?? start;

    return _RentalScreen(
      flow: t.flowRental('04'),
      title: t.whereMeet,
      subtitle: t.whereMeetSub(
        '${_dayMonth(context, start)} ${_douala(start).year}, ${formatTime(start)}',
      ),
      onBack: preview ? null : context.pop,
      footer: [
        IyoButton(
          label: t.savePickupReview,
          onPressed:
              preview
                  ? () {}
                  : () {
                    if (d.request == null) {
                      setState(() => _showErrors = true);
                      return;
                    }
                    context.push('/rent/review');
                  },
        ),
      ],
      children: [
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            IyoToggle(
              value: d.isAirport,
              label: t.airportPickupToggle,
              labelVariant: IyoTextVariant.subheading,
              enabled: preview || v.airportPickupAvailable,
              onChanged:
                  (on) =>
                      preview
                          ? null
                          : _ctrl.update(
                            (x) => x.copyWith(
                              pickupType: on ? RentalPickupType.airport : RentalPickupType.address,
                              airport: x.airport ?? (airports.isEmpty ? null : airports.first),
                              terminal: x.terminal ?? 'Arrivals',
                              flightArrivalAt:
                                  x.flightArrivalAt ??
                                  x.startsAt?.subtract(const Duration(minutes: 45)),
                            ),
                          ),
            ),
          ],
        ),
        if (!d.isAirport) ...[
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
          ),
          Footnote(t.addressPickupNote),
        ] else ...[
          IyoSelectField<String>(
            label: t.airportLabel,
            value: d.airport?.code,
            sheetTitle: t.airportLabel,
            options: [
              for (final a in airports)
                IyoSelectOption(value: a.code, label: _airportName(context, a.code)),
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
          ),
          IyoSelectField<String>(
            label: t.terminalLabel,
            value: d.terminal,
            options: [
              for (final term in d.airport?.terminals ?? const ['Arrivals'])
                IyoSelectOption(value: term, label: term),
            ],
            onChanged: (term) => _ctrl.update((x) => x.copyWith(terminal: term)),
          ),
          IyoTextField(
            label: t.flightNumber,
            placeholder: t.flightNumberHint,
            initialValue: d.flightNumber,
            highlighted: preview,
            error:
                (_showErrors || d.flightNumber.length >= 3) && !flightOk ? t.flightInvalid : null,
            helper:
                flightOk && airline != null
                    ? t.flightKnown(airline, d.flightNumber.toUpperCase().replaceAll(' ', ''))
                    : null,
            onChanged: (s) => _ctrl.update((x) => x.copyWith(flightNumber: s)),
          ),
          IyoSelectField<String>(
            label: t.flightArrivalLabel(_dayMonth(context, arrival)),
            value: formatTime(arrival).substring(0, 3) + _quarter(formatTime(arrival)),
            options: [
              for (var h = 0; h < 24; h++)
                for (final m in const ['00', '15', '30', '45'])
                  IyoSelectOption(
                    value: '${h.toString().padLeft(2, '0')}:$m',
                    label: t.localTime('${h.toString().padLeft(2, '0')}:$m'),
                  ),
            ],
            onChanged: (hhmm) {
              final p = hhmm.split(':');
              final base = _dateOnly(arrival);
              final local = DateTime(
                base.year,
                base.month,
                base.day,
                int.parse(p[0]),
                int.parse(p[1]),
              );
              _ctrl.update((x) => x.copyWith(flightArrivalAt: local));
            },
          ),
          IyoListRow(
            icon: LucideIcons.planeLanding,
            title: t.meetAtArrivals(d.terminal ?? 'Arrivals'),
            subtitle: t.meetAllow('45'),
            showChevron: false,
          ),
          if (d.airport != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IyoBadge(t.airportFeeBadge(formatFcfa(d.airport!.pickupFee))),
            ),
        ],
      ],
    );
  }

  /// Minutes rounded down to the quarter, matching the select options.
  static String _quarter(String hhmm) {
    final m = int.parse(hhmm.substring(3));
    return ((m ~/ 15) * 15).toString().padLeft(2, '0');
  }
}

// ---------------------------------------------------------------------------
// RENTAL · 05 — Review and payment
// ---------------------------------------------------------------------------

class RentalReviewScreen extends ConsumerStatefulWidget {
  const RentalReviewScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<RentalReviewScreen> createState() => _RentalReviewScreenState();
}

class _RentalReviewScreenState extends ConsumerState<RentalReviewScreen> {
  late bool _accepted = widget.preview;
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
      context.go('/rentals/${booking.id}/booked');
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

  Future<void> _pickMethod(RentalDraft d) async {
    final t = context.t;
    final m = await showModalBottomSheet<PaymentMethodType>(
      context: context,
      showDragHandle: true,
      backgroundColor: IyoPalette.white,
      builder:
          (sheet) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IyoText(t.paymentMethod, variant: IyoTextVariant.cardTitle),
                for (final x in PaymentMethodType.values)
                  IyoListRow(
                    title: paymentMethodLabel(context, x),
                    trailing:
                        x == d.paymentMethod ? const IyoIcon(LucideIcons.check, size: 16) : null,
                    showChevron: false,
                    onPressed: () => Navigator.pop(sheet, x),
                  ),
              ],
            ),
          ),
    );
    if (m != null) {
      ref.read(rentalDraftProvider.notifier).update((x) => x.copyWith(paymentMethod: m));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final d = preview ? RentalSample.draft() : ref.watch(rentalDraftProvider);
    final req = d.request;
    if (req == null) return _lostDraft(context);
    final cash = d.paymentMethod == PaymentMethodType.cash;
    final place =
        d.isAirport
            ? [req.airport!.name, if (req.terminal != null) req.terminal!].join(', ')
            : req.pickupAddress!;
    return _RentalScreen(
      flow: t.flowRental('05'),
      title: t.getaway,
      subtitle: t.getawaySub,
      onBack: preview ? null : context.pop,
      footer: [
        if (_error != null) IyoText(_error!, color: IyoPalette.danger, align: TextAlign.center),
        IyoButton(
          label: cash ? t.confirmCash : t.confirmPay(formatFcfa(req.total)),
          loading: _booking,
          disabled: !_accepted,
          onPressed: preview ? () {} : (_accepted && !_booking ? () => _book(req) : null),
        ),
      ],
      children: [
        _BookingCard(
          vehicle: req.vehicle,
          start: req.startsAt,
          end: req.endsAt,
          days: req.days,
          place: place,
        ),
        if (d.isAirport)
          Align(
            alignment: Alignment.centerLeft,
            child: IyoBadge(
              t.airportFlightBadge(
                req.terminal ?? '',
                req.flightNumber!.toUpperCase().replaceAll(' ', ''),
                formatTime(req.flightArrivalAt!),
              ),
            ),
          ),
        IyoCard(
          children: [
            _AmountLine(
              t.daysTimesRate(_days(context, req.days), formatFcfa(req.vehicle.dailyRate)),
              formatFcfa(req.rentalAmount),
            ),
            if (req.protectionAmount > 0)
              _AmountLine(
                t.protectionLine(_days(context, req.days), formatFcfa(req.protectionDaily)),
                formatFcfa(req.protectionAmount),
              ),
            if (req.airportFee > 0) _AmountLine(t.airportPickupLine, formatFcfa(req.airportFee)),
            _AmountLine(t.totalLine, formatFcfa(req.total)),
          ],
        ),
        IyoListRow(
          icon: cash ? LucideIcons.banknote : LucideIcons.smartphone,
          title: preview ? Sample.paymentMethod : paymentMethodLabel(context, d.paymentMethod),
          subtitle:
              cash ? t.cashAtPickup : t.depositHeldAtPickup(formatFcfa(req.vehicle.depositAmount)),
          showChevron: !preview,
          onPressed: preview ? null : () => _pickMethod(d),
        ),
        IyoCheckbox(
          value: _accepted,
          onChanged: (v) => setState(() => _accepted = v),
          label: t.acceptTermsLong(
            '${_dayMonth(context, req.startsAt)} ${formatTime(req.startsAt)}',
          ),
          labelVariant: IyoTextVariant.caption,
        ),
        if (req.vehicle.isPlaceholderPricing && !preview) Footnote(t.placeholderPricing),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// RENTAL · 06 — Booking confirmed
// ---------------------------------------------------------------------------

class RentalBookedScreen extends ConsumerWidget {
  const RentalBookedScreen({super.key, this.bookingId});

  /// Null: Figma sample content.
  final String? bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final preview = bookingId == null;
    final b =
        preview
            ? RentalSample.booking(RentalBookingStatus.confirmed)
            : ref.watch(rentalProvider(bookingId!)).value;
    if (b == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final place =
        b.airportCode != null
            ? [b.pickupAddress ?? '', if (b.terminal != null) b.terminal!].join(', ')
            : b.pickupAddress ?? '';
    final paid = b.status != RentalBookingStatus.pendingPayment;
    final cash = b.paymentMethod == PaymentMethodType.cash;
    return _RentalScreen(
      flow: t.flowRental('06'),
      title: t.carBooked,
      subtitle: t.carBookedSub(b.reference),
      footer: [
        IyoButton(
          label: t.viewMyRental,
          onPressed: preview ? () {} : () => context.go('/rentals/${b.id}'),
        ),
        IyoButton(
          label: t.addToCalendar,
          variant: IyoButtonVariant.secondary,
          onPressed: preview ? () {} : () => _addToCalendar(context, b, place),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: IyoPalette.success, width: 2),
              ),
              child: const IyoIcon(LucideIcons.check, color: IyoPalette.success, size: 24),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child:
              cash
                  ? IyoBadge(t.cashBadge(formatFcfa(b.totalAmount)))
                  : paid
                  ? IyoBadge(t.paidBadge(formatFcfa(b.totalAmount)), tone: IyoBadgeTone.success)
                  : IyoBadge(t.paymentPendingBadge(formatFcfa(b.totalAmount))),
        ),
        _BookingCard(
          vehicle: b.vehicle,
          start: b.startsAt,
          end: b.endsAt,
          days: b.days,
          place: place,
        ),
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            IyoText(
              b.airportCode != null ? t.allSetAirport : t.allSetAddress,
              variant: IyoTextVariant.subheading,
            ),
            IyoText(
              [
                if (b.flightNumber != null)
                  t.flightSummary(
                    b.flightNumber!,
                    _dayMonth(context, b.startsAt),
                    formatTime(b.flightArrivalAt ?? b.startsAt),
                  ),
                b.airportCode != null
                    ? t.driverMeetsYou(formatTime(b.startsAt))
                    : t.driverBringsCar(b.pickupAddress ?? '', formatTime(b.startsAt)),
              ].join('\n'),
              color: IyoPalette.charcoal,
            ),
            IyoText(
              t.bringDocuments,
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
            if (b.handoverPin != null && !preview)
              IyoBadge(t.handoverPinBadge(b.handoverPin!), tone: IyoBadgeTone.dark),
          ],
        ),
      ],
    );
  }

  Future<void> _addToCalendar(BuildContext context, RentalBooking b, String place) {
    String stamp(DateTime d) {
      final u = d.toUtc();
      String p(int n) => n.toString().padLeft(2, '0');
      return '${u.year}${p(u.month)}${p(u.day)}T${p(u.hour)}${p(u.minute)}00Z';
    }

    final url = Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': context.t.calendarTitle(b.vehicle.name),
      'dates': '${stamp(b.startsAt)}/${stamp(b.endsAt)}',
      'location': place,
      'details': '${b.reference} · ${b.vehicle.name} ${b.vehicle.plate}',
    });
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

// ---------------------------------------------------------------------------
// My rentals, Activity cards
// ---------------------------------------------------------------------------

class MyRentalsScreen extends ConsumerWidget {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final rentals = ref.watch(myRentalsProvider);
    return _RentalScreen(
      flow: t.flowRentalPlain,
      title: t.myRentals,
      onBack: context.pop,
      footer: [
        IyoButton(
          label: t.browseCars,
          variant: IyoButtonVariant.secondary,
          onPressed: () => context.go('/home?service=rent'),
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
        _VehicleSummary(b.vehicle),
        _RichRow(
          title: '${_range(context, b.startsAt, b.endsAt)} · ${formatTime(b.startsAt)}',
          chevron: true,
          subtitle: [
            b.airportCode != null ? _airportName(context, b.airportCode) : b.pickupAddress ?? '',
            t.bookingRef(b.reference),
          ].join(' · '),
        ),
        Align(alignment: Alignment.centerLeft, child: rentalStatusBadge(context, b.status)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// One booking: Manage (before pickup), Active (RENTAL · 07), Return inspection
// ---------------------------------------------------------------------------

enum RentalPreview { manage, active, returnCheck }

class RentalBookingScreen extends ConsumerStatefulWidget {
  const RentalBookingScreen({super.key, this.bookingId, this.preview});

  final String? bookingId;
  final RentalPreview? preview;

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

  /// Return steps (where, by when) and "I'm returning the car".
  Future<void> _returnSheet(RentalBooking b) {
    final t = context.t;
    final place =
        b.airportCode != null ? _airportName(context, b.airportCode) : b.pickupAddress ?? '';
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: IyoPalette.white,
      builder:
          (sheet) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  IyoText(t.returnStepsTitle, variant: IyoTextVariant.cardTitle),
                  IyoText(
                    t.returnStepsBody(
                      place,
                      '${_weekdayDay(context, b.endsAt)} · ${formatTime(b.endsAt)}',
                    ),
                    color: IyoPalette.charcoal,
                  ),
                  if (b.status == RentalBookingStatus.active && !_returnRequested)
                    IyoButton(
                      label: t.startReturnNow,
                      onPressed: () {
                        Navigator.pop(sheet);
                        _run(() async {
                          await ref.read(backendProvider).requestReturn(b.id);
                          if (mounted) setState(() => _returnRequested = true);
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
    );
  }

  void _back() => context.canPop() ? context.pop() : context.go('/rentals');

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = widget.preview;
    final async = p == null ? ref.watch(rentalProvider(widget.bookingId!)) : null;
    final RentalBooking? b = switch (p) {
      RentalPreview.manage => RentalSample.booking(RentalBookingStatus.driverAssigned),
      RentalPreview.active => RentalSample.booking(RentalBookingStatus.active),
      RentalPreview.returnCheck => RentalSample.booking(RentalBookingStatus.returnPending),
      null => async!.value,
    };
    if (b == null) {
      return _RentalScreen(
        flow: t.flowRentalPlain,
        title: t.myRentals,
        children: [
          if (async?.hasError ?? false)
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
    return switch (b.status) {
      RentalBookingStatus.active => _active(context, b, preview: p != null),
      RentalBookingStatus.returnPending ||
      RentalBookingStatus.completed => _returnCheck(context, b, preview: p != null),
      _ => _manage(context, b, preview: p != null),
    };
  }

  // Manage booking (Figma 2025:567)
  Widget _manage(BuildContext context, RentalBooking b, {required bool preview}) {
    final t = context.t;
    final profile = preview ? null : ref.watch(profileProvider).value;
    final place =
        b.airportCode != null ? _airportName(context, b.airportCode) : b.pickupAddress ?? '';
    final driver = b.driver;
    final cancelled = b.status == RentalBookingStatus.cancelled;
    return _RentalScreen(
      flow: t.flowRentalPlain,
      title: t.manageRental,
      subtitle: t.manageSub(b.reference, preview ? Sample.riderFullName : profile?.fullName ?? ''),
      onBack: preview ? () {} : _back,
      footer: [
        if (!cancelled)
          IyoButton(
            label: t.viewPickupInstructions,
            onPressed: preview ? () {} : () => context.push('/rentals/${b.id}/booked'),
          ),
      ],
      children: [
        IyoCard(
          children: [
            _VehicleSummary(b.vehicle),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                rentalStatusBadge(context, b.status),
                if (b.handoverPin != null && !cancelled && !preview)
                  IyoBadge(t.handoverPinBadge(b.handoverPin!), tone: IyoBadgeTone.dark),
              ],
            ),
            _RichRow(
              title: _range(context, b.startsAt, b.endsAt, year: true),
              subtitle: t.pickupReturnTimes(
                formatTime(b.startsAt),
                formatTime(b.endsAt),
                _days(context, b.days),
              ),
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoText(t.pickupAndReturn, variant: IyoTextVariant.cardTitle),
            _RichRow(
              title: place,
              subtitle:
                  b.flightNumber != null
                      ? t.arrivalsMeetingPoint(b.flightNumber!)
                      : t.deliveryAddressLine,
            ),
            _RichRow(
              title: driver?.fullName ?? t.handoverContactPending,
              chevron: driver != null,
              subtitle: driver != null ? t.handoverContact : t.driverAssignedSoon,
              onPressed:
                  driver?.phone == null || preview
                      ? null
                      : () => launchUrl(Uri(scheme: 'tel', path: driver!.phone)),
            ),
          ],
        ),
        if (!cancelled)
          IyoCard(
            children: [
              _RichRow(
                title: t.extendRental,
                chevron: true,
                subtitle: t.extendRentalSub(formatFcfa(b.dailyRate)),
                onPressed: preview ? null : () => context.push('/support'),
              ),
              const IyoDivider(),
              _RichRow(
                title: t.changeBooking,
                chevron: true,
                subtitle: t.changeBookingSub,
                onPressed: preview ? null : () => context.push('/support'),
              ),
              const IyoDivider(),
              _RichRow(
                title: t.returnVehicle,
                chevron: true,
                subtitle: t.returnVehicleSub,
                onPressed: preview ? null : () => _returnSheet(b),
              ),
              if (b.isCancellable && !preview) ...[
                const IyoDivider(),
                _RichRow(
                  title: t.cancelBooking,
                  chevron: true,
                  subtitle: t.cancelBookingSub,
                  onPressed: _busy ? null : () => _cancel(b),
                ),
              ],
            ],
          ),
        Row(
          children: [
            Expanded(
              child: IyoText(
                b.status == RentalBookingStatus.pendingPayment ? t.bookingDue : t.bookingPaid,
                variant: IyoTextVariant.subheading,
              ),
            ),
            IyoText(formatFcfa(b.totalAmount), variant: IyoTextVariant.heading),
          ],
        ),
        Footnote(t.depositSeparate(formatFcfa(b.depositAmount))),
      ],
    );
  }

  // RENTAL · 07 — Active rental (Figma 2005:51022)
  Widget _active(BuildContext context, RentalBooking b, {required bool preview}) {
    final t = context.t;
    final now = preview ? DateTime.utc(2026, 10, 17, 9, 8) : DateTime.now();
    final left = b.endsAt.difference(now);
    final leftText =
        left.inDays >= 1
            ? t.daysHours('${left.inDays}', '${left.inHours % 24}')
            : t.hoursOnly('${left.inHours.clamp(0, 24)}');
    final driver = b.driver;
    final place =
        b.airportCode != null
            ? '${_airportName(context, b.airportCode)} · ${b.terminal ?? ''}'
            : b.pickupAddress ?? '';
    final activeSince = b.handover?.riderConfirmedAt ?? b.startsAt;
    return _RentalScreen(
      flow: t.flowRental('07'),
      title: t.keysAreYours,
      subtitle: t.activeSince('${_dayMonth(context, activeSince)}, ${formatTime(activeSince)}'),
      onBack: preview ? null : _back,
      footer: [
        IyoButton(
          label: t.viewReturnInstructions,
          loading: _busy,
          onPressed: preview ? () {} : () => _returnSheet(b),
        ),
      ],
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.activeBadge(b.reference), tone: IyoBadgeTone.success),
        ),
        if (b.vehicle.category == 'suv' || b.vehicle.category == 'pickup')
          Center(child: _CarPhoto(b.vehicle, width: 300, height: 128, large: true))
        else
          Center(
            child: Image.asset(
              'assets/images/car_wide.png',
              width: 216,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        IyoText(
          t.carPlate(b.vehicle.name, b.vehicle.plate),
          variant: IyoTextVariant.heading,
          style: const TextStyle(fontSize: 18),
        ),
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            IyoListRow(
              icon: LucideIcons.calendarCheck,
              iconWellTone: IyoIconWellTone.white,
              title: t.returnBy(_weekdayDay(context, b.endsAt), formatTime(b.endsAt)),
              subtitle: place,
              showChevron: false,
            ),
            IyoPressable(
              minHitSize: 0,
              onPressed: preview ? null : () => context.push('/support'),
              child: SizedBox(
                width: double.infinity,
                child: IyoText(
                  _returnRequested ? t.returnRequested : t.remainingExtend(leftText),
                  variant: IyoTextVariant.caption,
                  color: IyoPalette.charcoal,
                ),
              ),
            ),
          ],
        ),
        if (driver != null)
          IyoPersonInfoCard(
            name: driver.fullName ?? driver.firstName,
            photo: preview ? const AssetImage('assets/images/sample_driver.jpg') : null,
            meta: t.driverTrips(
              driver.rating?.toStringAsFixed(1) ?? '–',
              _group(driver.ratingCount),
            ),
            detail: '${b.vehicle.name} · ${b.vehicle.color ?? ''} · ${b.vehicle.plate}',
            onCall:
                preview
                    ? () {}
                    : driver.phone == null
                    ? null
                    : () => launchUrl(Uri(scheme: 'tel', path: driver.phone)),
            callLabel: t.callPerson(driver.firstName),
          ),
        IyoActionTileRow(
          children: [
            IyoActionTile(
              icon: LucideIcons.messageCircle,
              label: t.tileMessage,
              onPressed:
                  preview || driver?.phone == null
                      ? () {}
                      : () => launchUrl(Uri(scheme: 'sms', path: driver!.phone)),
            ),
            IyoActionTile(
              icon: LucideIcons.share2,
              label: t.tileShareTrip,
              onPressed:
                  preview
                      ? () {}
                      : () => SharePlus.instance.share(
                        ShareParams(
                          text:
                              '${t.calendarTitle(b.vehicle.name)} · ${b.vehicle.plate}\n'
                              '${t.returnBy(_weekdayDay(context, b.endsAt), formatTime(b.endsAt))}'
                              ' · $place',
                        ),
                      ),
            ),
            IyoActionTile(
              icon: LucideIcons.shieldCheck,
              label: t.tileSafety,
              accent: true,
              onPressed: preview ? () {} : () => context.push('/safety-alert'),
            ),
          ],
        ),
        Footnote(t.activeFootnote(_group(b.kmAllowance))),
      ],
    );
  }

  // Return inspection and deposit (Figma 2025:609)
  Widget _returnCheck(BuildContext context, RentalBooking b, {required bool preview}) {
    final t = context.t;
    final r = b.returnInspection;
    final h = b.handover;
    final ready = b.status == RentalBookingStatus.returnPending && r != null;
    final done = b.status == RentalBookingStatus.completed;
    final place =
        b.airportCode != null ? _airportName(context, b.airportCode) : b.pickupAddress ?? '';
    final used = r != null && h != null ? (r.odometerKm - h.odometerKm).clamp(0, 1 << 30) : 0;
    final hold = done ? b.depositHeldAmount : r?.depositHoldAmount ?? 0;
    final fuel = r == null ? '' : (r.fuelLevel == 8 ? t.fullTank : t.fuelEighths('${r.fuelLevel}'));
    final returnedAt = r?.inspectorConfirmedAt;
    return _RentalScreen(
      flow: t.flowRentalPlain,
      title: t.returnInspection,
      subtitle: t.returnInspectionSub(b.reference, b.vehicle.name, b.vehicle.plate),
      onBack: preview ? () {} : _back,
      footer: [
        if (!done)
          IyoButton(
            label: t.confirmReturnSummary,
            loading: _busy,
            disabled: !ready,
            onPressed:
                preview
                    ? () {}
                    : (ready
                        ? () => _run(
                          () => ref
                              .read(backendProvider)
                              .confirmInspection(b.id, InspectionType.return_),
                        )
                        : null),
          ),
      ],
      children: [
        IyoCard(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child:
                  r != null
                      ? IyoBadge(t.inspectionComplete, tone: IyoBadgeTone.success)
                      : IyoBadge(t.inspectionWaiting),
            ),
            _RichRow(
              title: place,
              subtitle:
                  returnedAt == null
                      ? null
                      : t.returnedAt(
                        '${_dayMonth(context, returnedAt)} ${_douala(returnedAt).year}',
                        formatTime(returnedAt),
                      ),
            ),
            if (b.driver != null)
              IyoText(
                t.checkedWith(b.driver!.firstName),
                variant: IyoTextVariant.caption,
                color: IyoPalette.textSecondary,
              ),
          ],
        ),
        if (r != null)
          IyoCard(
            children: [
              IyoText(t.vehicleCondition, variant: IyoTextVariant.cardTitle),
              _RichRow(
                title: t.exteriorInterior,
                subtitle: t.photosAttached(
                  (r.damageNotes ?? '').trim().isEmpty ? t.noDamage : r.damageNotes!,
                  '${r.photoPaths.length}',
                ),
              ),
              _RichRow(
                title: t.fuelMileage,
                subtitle: t.fuelMileageLine(fuel, _group(used), _group(b.kmAllowance)),
              ),
              _RichRow(title: t.keysAccessories, subtitle: t.allItemsReturned),
            ],
          ),
        IyoCard(
          children: [
            IyoText(t.depositSummary, variant: IyoTextVariant.cardTitle),
            _AmountLine(t.depositHeldLine, formatFcfa(b.depositAmount)),
            _AmountLine(t.feesLine, formatFcfa(hold)),
            _AmountLine(t.depositReleaseLine, formatFcfa(b.depositAmount - hold), strong: true),
            IyoText(
              done
                  ? (b.depositStatus == DepositStatus.partiallyHeld
                      ? t.depositPartiallyHeld(formatFcfa(b.depositHeldAmount))
                      : t.depositReleased)
                  : t.releaseNote,
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
          ],
        ),
        if (!done)
          IyoPressable(
            minHitSize: 0,
            onPressed: preview ? null : () => context.push('/support'),
            child: SizedBox(width: double.infinity, child: Footnote(t.reportBeforeConfirm)),
          ),
      ],
    );
  }
}
