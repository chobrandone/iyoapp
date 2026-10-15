import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../state/driver_location.dart';
import '../state/online.dart';
import '../widgets/driver_widgets.dart';
import '../sample/sample_data.dart';

final _todayProvider = FutureProvider.autoDispose<DriverDaySummary>((ref) {
  ref.watch(driverOnlineProvider);
  ref.watch(activeRideProvider);
  return ref.watch(backendProvider).today();
});

final recentTripsProvider = FutureProvider.autoDispose<List<CompletedTrip>>((ref) {
  ref.watch(activeRideProvider);
  return ref.watch(backendProvider).recentTrips();
});

enum HomePreview { offline, online }

String _greeting(BuildContext context, String name) {
  final t = context.t;
  final hour = DateTime.now().toUtc().add(const Duration(hours: 1)).hour; // Africa/Douala
  if (hour < 12) return t.greetingMorning(name);
  if (hour < 18) return t.greetingAfternoon(name);
  return t.greetingEvening(name);
}

String daysLabel(BuildContext context, int n) =>
    n == 1 ? context.t.oneDay : context.t.daysCount('$n');

String tripsLabel(BuildContext context, int n) =>
    n == 1 ? context.t.oneTrip : context.t.tripsN('$n');

/// "Standard" (the onboarding labels carry the seat count after " · ").
String categoryLabel(BuildContext context, String code) =>
    switch (code) {
      'comfort' => context.t.categoryComfort,
      'xl' => context.t.categoryXl,
      _ => context.t.categoryStandard,
    }.split(' · ').first;

/// Short place for a rental pickup: "Douala International Airport (DLA)" or the address.
String rentalPlace(RentalBooking b) =>
    b.airportCode != null ? '${b.pickupAddress} (${b.airportCode})' : b.pickupAddress ?? '';

/// "17 Oct, 10:00" in Douala time.
String formatRentalWhen(DateTime d) {
  final local = d.toUtc().add(const Duration(hours: 1));
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
  ];
  return '${local.day} ${months[local.month - 1]}, ${formatTime(d)}';
}

/// DRIVER · 01 / 02 — Home offline and online (Figma 2005:51218 / 2005:51280).
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key, this.preview});

  /// Figma sample content (design index, snapshots).
  final HomePreview? preview;

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  String? _error;
  bool _showingOffer = false;

  Future<void> _toggle(bool online) async {
    final t = context.t;
    setState(() => _error = null);
    final controller = ref.read(onlineControllerProvider.notifier);
    if (!online) {
      await controller.goOffline();
      return;
    }
    final result = await controller.goOnline(
      notificationTitle: t.onlineNotificationTitle,
      notificationBody: t.onlineNotificationBody,
    );
    if (!mounted) return;
    setState(() {
      _error = switch (result) {
        GoOnlineResult.ok => null,
        GoOnlineResult.locationDenied => t.locationNeeded,
        GoOnlineResult.notApproved => t.reviewSubtitle,
        GoOnlineResult.failed => t.errorGeneric,
      };
    });
  }

  Future<void> _showOffer(RideOffer offer) async {
    if (_showingOffer) return;
    _showingOffer = true;
    // Distinct haptics for a new request (spec §7). TODO(Phase 8): loud channel sound + push.
    unawaited(HapticFeedback.heavyImpact());
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => RideRequestScreen(offer: offer)),
    );
    _showingOffer = false;
    if (!mounted || accepted == null) return;
    try {
      final ride = await ref.read(backendProvider).respond(offer, accept: accepted);
      if (ride != null && mounted) {
        ref.read(activeRideProvider.notifier).set(ride.id);
        ref
            .read(onlineControllerProvider.notifier)
            .setOnTrip(
              true,
              notificationTitle: context.t.onlineNotificationTitle,
              notificationBody: context.t.onlineNotificationBody,
            );
        unawaited(context.push('/trip/${ride.id}'));
      }
    } on BackendException {
      if (mounted) setState(() => _error = context.t.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final live = preview == null;
    final online =
        live ? (ref.watch(driverOnlineProvider).value ?? false) : preview == HomePreview.online;
    final busy = live && ref.watch(onlineControllerProvider);
    final pos = ref.watch(lastPositionProvider);
    final today = live ? ref.watch(_todayProvider).value : null;
    final profile = live ? ref.watch(profileProvider).value : null;
    final rentals = live ? ref.watch(assignedRentalsProvider).value : null;

    if (live) {
      ref.listen(rideOfferProvider, (_, next) {
        final offer = next.value;
        if (offer != null && ref.read(activeRideProvider) == null) _showOffer(offer);
      });
    }

    final earnings = live ? (today?.earnings ?? 0) : DriverSample.todayEarnings;
    final trips = live ? (today?.trips ?? 0) : DriverSample.todayTrips;
    final onlineSeconds = live ? (today?.onlineSeconds ?? 0) : DriverSample.todayOnline;
    final name = live ? (profile?.firstName ?? '') : DriverSample.driverFirstName;

    // Next rental delivery (offline home).
    String? nextTitle, nextDetail;
    if (live) {
      final next =
          rentals
              ?.where(
                (b) =>
                    b.status == RentalBookingStatus.driverAssigned ||
                    b.status == RentalBookingStatus.confirmed,
              )
              .toList();
      if (next != null && next.isNotEmpty) {
        final b = next.first;
        nextTitle = t.nextRental(formatRentalWhen(b.startsAt));
        nextDetail = t.nextRentalDetail(rentalPlace(b), b.vehicle.name, daysLabel(context, b.days));
      }
    } else {
      nextTitle = t.nextRental(formatRentalWhen(DriverSample.rentalStart));
      nextDetail = t.nextRentalDetail(
        'Douala (DLA)',
        DriverSample.rentalCar,
        daysLabel(context, DriverSample.rentalDays),
      );
    }

    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flow(online ? '02' : '01')),
      heading: IyoPageHeading(
        title: online ? t.homeOnlineTitle : _greeting(context, name),
        subtitle: online ? t.homeOnlineSubtitle : t.homeOfflineSubtitle,
      ),
      footer: [
        if (_error != null) Footnote(_error!, color: IyoPalette.danger),
        IyoButton(
          label: online ? t.goOffline : t.goOnline,
          variant: online ? IyoButtonVariant.secondary : IyoButtonVariant.primary,
          loading: busy,
          onPressed: live ? () => _toggle(!online) : () {},
        ),
      ],
      children: [
        if (online) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: IyoBadge(t.acceptingRequests, tone: IyoBadgeTone.success, dot: true),
          ),
          DriverMap(me: pos.point, heading: pos.heading, height: 275, showHalo: true),
          IyoCard(
            tone: IyoCardTone.accent,
            title: t.busyAreaHeading,
            description: t.busyAreaText(live ? 'Douala' : DriverSample.busyArea),
          ),
          IyoListRow(
            icon: LucideIcons.wallet,
            title: t.todayAmount(formatFcfa(earnings)),
            subtitle: t.tripsOnline(tripsLabel(context, trips), hoursMinutes(onlineSeconds)),
            showChevron: false,
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: MetricCard(label: t.todaysEarnings, value: formatFcfa(earnings))),
              const SizedBox(width: 12),
              Expanded(child: MetricCard(label: t.completedTrips, value: '$trips')),
            ],
          ),
          DriverMap(me: pos.point, heading: pos.heading, height: 240, showHalo: true),
          Align(alignment: Alignment.centerLeft, child: IyoBadge(t.offlineBadge)),
          if (nextTitle != null)
            IyoListRow(
              icon: LucideIcons.calendarDays,
              title: nextTitle,
              subtitle: nextDetail,
              showChevron: false,
              onPressed: live ? () => context.go('/bookings') : null,
            ),
          if (_error == t.locationNeeded)
            IyoCard(
              tone: IyoCardTone.danger,
              title: t.locationNeeded,
              description: t.locationNeededBody,
            ),
        ],
      ],
    );
  }
}

/// DRIVER · 03 — Incoming ride request (Figma 2005:51338), full screen with the accept countdown.
class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key, this.offer});

  /// Null: Figma sample content.
  final RideOffer? offer;

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> with SingleTickerProviderStateMixin {
  late final Duration _window =
      widget.offer == null
          ? const Duration(seconds: 18)
          : widget.offer!.expiresAt.difference(DateTime.now());
  late final AnimationController _countdown = AnimationController(
    vsync: this,
    duration: _window.isNegative ? Duration.zero : _window,
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.offer == null) return;
    _countdown.reverse();
    _countdown.addStatusListener((s) {
      // Window over: close; the server marks the offer expired and offers the next driver.
      if (s == AnimationStatus.dismissed && mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  void _answer(bool accept) {
    if (widget.offer != null) Navigator.of(context).pop(accept);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final o = widget.offer;
    final ride = o?.ride;
    final pickupMin = o == null ? '3' : '${((o.pickupEtaSeconds ?? 0) / 60).ceil()}';
    final tripMin = ride == null ? '12' : '${(ride.durationSeconds / 60).round()}';
    final distance = ride == null ? '3.2 km' : formatDistance(ride.distanceMeters);
    final category = categoryLabel(context, ride?.categoryCode ?? 'standard');
    final pickupArea = ride == null ? DriverSample.pickupArea : placeArea(ride.pickup);
    final dropoffArea = ride == null ? DriverSample.dropoffArea : placeArea(ride.dropoff);
    return AnimatedBuilder(
      animation: _countdown,
      builder: (context, _) {
        final seconds = (_countdown.value * _window.inSeconds).ceil();
        return IyoScreen(
          header: DriverHeader(flowLabel: t.flow('03')),
          heading: IyoPageHeading(
            title: t.requestTitle,
            subtitle: t.requestSubtitle(category, '$seconds'),
          ),
          footer: [
            IyoButton(label: t.acceptRideSeconds('$seconds'), onPressed: () => _answer(true)),
            IyoButton(
              label: t.declineRequest,
              variant: IyoButtonVariant.secondary,
              onPressed: () => _answer(false),
            ),
          ],
          children: [
            DriverMap(
              me: ride?.pickup.location ?? doualaDefault,
              pickup: ride?.pickup.location ?? doualaDefault,
              destination: ride?.dropoff.location ?? doualaDefault,
              height: 213,
            ),
            Row(
              children: [
                Expanded(
                  child: IyoText(
                    formatFcfa(ride?.driverEarnings ?? DriverSample.estEarnings),
                    variant: IyoTextVariant.fare,
                  ),
                ),
                IyoBadge(t.estEarningsBadge),
              ],
            ),
            Footnote(t.requestMeta(pickupMin, tripMin, distance)),
            Column(
              children: [
                IyoListRow(
                  icon: LucideIcons.circleDot,
                  title: ride?.pickup.name ?? DriverSample.pickupName,
                  subtitle: t.pickupSuffix(pickupArea),
                  showChevron: false,
                ),
                const IyoDivider(),
                IyoListRow(
                  icon: LucideIcons.mapPin,
                  title: ride?.dropoff.name ?? DriverSample.dropoffName,
                  subtitle: t.dropoffSuffix(dropoffArea),
                  showChevron: false,
                ),
              ],
            ),
            IyoPersonInfoCard(
              name: o?.rider.firstName ?? DriverSample.riderName,
              photo: o == null ? DriverSample.riderPhoto : null,
              meta: t.verifiedRider(
                o?.rider.rating?.toStringAsFixed(1) ?? DriverSample.riderRating,
              ),
              detail: t.askForPin,
              // The rider's number is shared once the ride is accepted.
              onCall: o == null ? () {} : null,
              callLabel: t.callRider(o?.rider.firstName ?? DriverSample.riderFirstName),
            ),
          ],
        );
      },
    );
  }
}

/// "Akwa, Douala" from a place's address (the part after the street).
String placeArea(Place p) {
  final parts = p.address.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (parts.length >= 2) return parts.skip(parts.length - 2).join(', ');
  return parts.isEmpty ? p.name : parts.first;
}
