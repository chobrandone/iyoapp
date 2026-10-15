import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../sample/sample_data.dart';
import '../widgets/driver_widgets.dart';
import 'home_screens.dart';

enum _Tab { upcoming, history }

String fuelLabel(BuildContext context, FuelType f) => switch (f) {
  FuelType.petrol => context.t.fuelPetrol,
  FuelType.diesel => context.t.fuelDiesel,
  FuelType.hybrid => context.t.fuelHybrid,
  FuelType.electric => context.t.fuelElectric,
};

String gearboxLabel(BuildContext context, TransmissionType g) => switch (g) {
  TransmissionType.automatic => context.t.gearAutomatic,
  TransmissionType.manual => context.t.gearManual,
};

/// Car photo used on rental cards.
// TODO(design): use the vehicle's own photo from rental_vehicles.image_paths.
class CarThumb extends StatelessWidget {
  const CarThumb({super.key, this.width = 86, this.height = 48});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/rental_car.png', width: width, height: height, fit: BoxFit.cover);
}

/// Car summary row: photo, name, specs, daily-rate badge (rental cards).
class RentalCarRow extends StatelessWidget {
  const RentalCarRow({
    super.key,
    required this.name,
    required this.specs,
    required this.badge,
    this.imageWidth = 86,
    this.imageHeight = 48,
    this.gap = 18,
  });

  final String name;
  final String specs;
  final String badge;
  final double imageWidth;
  final double imageHeight;
  final double gap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CarThumb(width: imageWidth, height: imageHeight),
      SizedBox(width: gap),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            IyoText(name, variant: IyoTextVariant.cardTitle),
            Footnote(specs),
            IyoBadge(badge),
          ],
        ),
      ),
    ],
  );
}

/// DRIVER — Bookings and trip history (Figma 2025:793).
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  var _tab = _Tab.upcoming;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final rentals = preview ? null : ref.watch(assignedRentalsProvider).value;
    final trips =
        preview ? DriverSample.todaysRides() : ref.watch(recentTripsProvider).value ?? const [];
    final now = DateTime.now();
    final todays =
        preview
            ? trips
            : trips
                .where(
                  (x) =>
                      x.completedAt.year == now.year &&
                      x.completedAt.month == now.month &&
                      x.completedAt.day == now.day,
                )
                .toList();

    bool upcoming(RentalBooking b) =>
        b.status != RentalBookingStatus.completed && b.status != RentalBookingStatus.cancelled;

    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(title: t.bookingsHeading, subtitle: t.bookingsSub, compact: true),
      children: [
        IyoSegmentedTabs<_Tab>(
          value: _tab,
          onChanged: (v) => setState(() => _tab = v),
          options: [
            IyoSegment(value: _Tab.upcoming, label: t.segUpcoming),
            IyoSegment(value: _Tab.history, label: t.segHistory),
          ],
        ),
        if (_tab == _Tab.upcoming) ...[
          if (preview)
            const _SampleRentalCard()
          else if (rentals == null)
            const IyoSkeletonRow()
          else if (!rentals.any(upcoming) && todays.isEmpty)
            IyoEmptyState(
              icon: LucideIcons.calendarDays,
              title: t.noUpcomingTitle,
              message: t.noUpcomingBody,
            )
          else
            for (final b in rentals.where(upcoming)) _RentalBookingCard(booking: b),
          if (todays.isNotEmpty) ...[
            SectionTitle(t.todaysCompletedRides),
            for (final (i, x) in todays.indexed) _RideCard(trip: x, completedBadge: i == 0),
            Footnote(t.bookingsFootnote),
          ],
        ] else ...[
          if (!preview && rentals != null && rentals.any((b) => !upcoming(b))) ...[
            SectionTitle(t.pastRentals),
            for (final b in rentals.where((b) => !upcoming(b))) _RentalBookingCard(booking: b),
          ],
          if (trips.isEmpty)
            IyoEmptyState(
              title: t.noTripsTitle,
              message: t.noTripsBody,
              icon: LucideIcons.listChecks,
            )
          else ...[
            SectionTitle(t.pastRides),
            for (final x in trips) _RideCard(trip: x),
          ],
        ],
      ],
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.trip, this.completedBadge = false});

  final CompletedTrip trip;
  final bool completedBadge;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final x = trip;
    final from = x.pickupName;
    final when =
        x.startedAt == null
            ? formatTime(x.completedAt)
            : '${formatTime(x.startedAt!)}–${formatTime(x.completedAt)}';
    final today = DateTime.now();
    final sameDay =
        x.completedAt.year == today.year &&
        x.completedAt.month == today.month &&
        x.completedAt.day == today.day;
    return IyoCard(
      children: [
        RichRow(
          title: from == null ? x.dropoffName : '$from → ${x.dropoffName}',
          aside: formatFcfa(x.earnings),
          chevron: true,
          subtitle: [
            if (!sameDay) formatDayMonth(context, x.completedAt),
            when,
            if (x.riderFirstName != null) x.riderFirstName!,
            rideRef(x.rideId),
          ].join(' · '),
        ),
        if (completedBadge)
          Align(
            alignment: Alignment.centerLeft,
            child: IyoBadge(t.statusCompletedShort, tone: IyoBadgeTone.success),
          ),
      ],
    );
  }
}

String _statusShort(BuildContext context, RentalBooking b) {
  final t = context.t;
  return switch (b.status) {
    RentalBookingStatus.driverAssigned when b.handover != null => t.rentalStatusAwaitingRider,
    RentalBookingStatus.active => t.rentalStatusWithRider,
    RentalBookingStatus.returnPending => t.rentalStatusReturnCheck,
    RentalBookingStatus.completed || RentalBookingStatus.cancelled => t.rentalStatusDone,
    _ => t.statusConfirmedShort,
  };
}

/// Rental handover card (Figma: "AIRPORT PICKUP · CONFIRMED").
class _RentalBookingCard extends StatelessWidget {
  const _RentalBookingCard({required this.booking});

  final RentalBooking booking;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final b = booking;
    final place = b.airportCode != null ? 'Douala (${b.airportCode})' : b.pickupAddress ?? '';
    final collecting =
        b.status == RentalBookingStatus.active || b.status == RentalBookingStatus.returnPending;
    return _RentalCardLayout(
      badge:
          b.airportCode != null
              ? t.airportPickupConfirmed(_statusShort(context, b))
              : t.addressPickupStatus(_statusShort(context, b)),
      name: b.vehicle.name,
      specs: t.carSpecs(
        fuelLabel(context, b.vehicle.fuelType),
        gearboxLabel(context, b.vehicle.transmission),
        '${b.vehicle.seats}',
      ),
      rate: t.perDayBadge(formatFcfa(b.dailyRate)),
      when: t.rentalWhenWhere(_whenShort(context, b.startsAt), place),
      who: [
        b.riderName ?? '–',
        if (b.flightNumber != null) b.flightNumber!,
        b.reference,
      ].join(' · '),
      returns: t.returnWhenWhere(formatRentalWhen(b.endsAt), place),
      action: collecting ? t.viewReturnSteps : t.viewHandoverRequirements,
      onAction: () => context.push('/rental/${b.id}'),
    );
  }
}

/// "17 Oct · 10:00"
String _whenShort(BuildContext context, DateTime d) =>
    '${formatDayMonth(context, d)} · ${formatTime(d)}';

class _SampleRentalCard extends StatelessWidget {
  const _SampleRentalCard();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _RentalCardLayout(
      badge: t.airportPickupConfirmed(t.statusConfirmedShort),
      name: DriverSample.rentalCar,
      specs: t.carSpecs(t.fuelPetrol, t.gearAutomatic, '5'),
      rate: t.perDayBadge(formatFcfa(DriverSample.rentalDailyRate)),
      when: t.rentalWhenWhere(_whenShort(context, DriverSample.rentalStart), 'Douala (DLA)'),
      who: '${DriverSample.riderName} · ${DriverSample.rentalFlight} · ${DriverSample.rentalRef}',
      returns: t.returnWhenWhere(formatRentalWhen(DriverSample.rentalEnd), 'Douala (DLA)'),
      action: t.viewHandoverRequirements,
      onAction: () => context.push('/design/rental-pickup'),
    );
  }
}

class _RentalCardLayout extends StatelessWidget {
  const _RentalCardLayout({
    required this.badge,
    required this.name,
    required this.specs,
    required this.rate,
    required this.when,
    required this.who,
    required this.returns,
    required this.action,
    required this.onAction,
  });

  final String badge, name, specs, rate, when, who, returns, action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => IyoCard(
    children: [
      Align(alignment: Alignment.centerLeft, child: IyoBadge(badge)),
      RentalCarRow(name: name, specs: specs, badge: rate),
      RichRow(title: when, subtitle: who),
      Footnote(returns),
      IyoPressable(
        onPressed: onAction,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: IyoText(action, variant: IyoTextVariant.bodyStrong, align: TextAlign.center),
        ),
      ),
    ],
  );
}
