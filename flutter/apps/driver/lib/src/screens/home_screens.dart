import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../locale_controller.dart';
import '../state/driver_location.dart';
import '../state/online.dart';
import '../widgets/driver_widgets.dart';
import 'rental_screens.dart';

final _todayProvider = FutureProvider.autoDispose<DriverDaySummary>((ref) {
  ref.watch(driverOnlineProvider);
  ref.watch(activeRideProvider);
  return ref.watch(backendProvider).today();
});

final _tripsProvider = FutureProvider.autoDispose<List<CompletedTrip>>((ref) {
  ref.watch(activeRideProvider);
  return ref.watch(backendProvider).recentTrips();
});

/// D8 / D9 — Driver home, offline and online (Figma 2005:51218 / 2005:51280; frames not attached).
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

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
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      // The full request (rider, pickup, trip, actions) needs more than the default 9/16 height.
      isScrollControlled: true,
      backgroundColor: IyoPalette.white,
      barrierColor: IyoPalette.overlay,
      builder: (_) => RideRequestSheet(offer: offer),
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
    final online = ref.watch(driverOnlineProvider).value ?? false;
    final busy = ref.watch(onlineControllerProvider);
    final pos = ref.watch(lastPositionProvider);
    final today = ref.watch(_todayProvider).value;
    final profile = ref.watch(profileProvider).value;

    ref.listen(rideOfferProvider, (_, next) {
      final offer = next.value;
      if (offer != null && ref.read(activeRideProvider) == null) _showOffer(offer);
    });

    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flow(online ? '09' : '08')),
      heading: IyoPageHeading(
        title: online ? t.onlineTitle : t.offlineTitle,
        subtitle: online ? t.onlineSubtitle : t.offlineSubtitle,
      ),
      footer: [
        if (_error != null) Footnote(_error!, color: IyoPalette.danger),
        OnlineToggle(online: online, busy: busy, onChanged: _toggle),
      ],
      children: [
        if (online)
          Align(
            alignment: Alignment.centerLeft,
            child: IyoBadge(t.acceptingRequests, tone: IyoBadgeTone.success, dot: true),
          ),
        DriverMap(me: pos.point, heading: pos.heading, height: online ? 220 : 256),
        if (online)
          IyoCard(tone: IyoCardTone.accent, title: t.busyAreaTitle, description: t.busyAreaBody),
        if (_error == t.locationNeeded)
          IyoCard(
            tone: IyoCardTone.danger,
            title: t.locationNeeded,
            description: t.locationNeededBody,
          ),
        Row(
          children: [
            Expanded(
              child: IyoStatTile(
                label: t.today,
                value: formatFcfa(today?.earnings ?? 0),
                detail: t.tripsCount(today?.trips ?? 0),
                icon: LucideIcons.wallet,
              ),
            ),
            const SizedBox(width: IyoSpacing.sm),
            Expanded(
              child: IyoStatTile(
                label: t.rating,
                value: profile?.rating?.toStringAsFixed(1) ?? '–',
                detail: t.lastTrips,
                accent: true,
              ),
            ),
          ],
        ),
        if (today != null && today.onlineSeconds > 0)
          Footnote(t.onlineFor(hoursMinutes(today.onlineSeconds))),
      ],
    );
  }
}

/// D10 — Incoming ride request with a 15 s countdown ring (RideRequestSheet).
class RideRequestSheet extends StatefulWidget {
  const RideRequestSheet({super.key, required this.offer});

  final RideOffer offer;

  @override
  State<RideRequestSheet> createState() => _RideRequestSheetState();
}

class _RideRequestSheetState extends State<RideRequestSheet> with SingleTickerProviderStateMixin {
  late final Duration _window = widget.offer.expiresAt.difference(DateTime.now());
  late final AnimationController _countdown = AnimationController(
    vsync: this,
    duration: _window.isNegative ? Duration.zero : _window,
    value: 1,
  )..reverse();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final o = widget.offer;
    final ride = o.ride;
    final pickupMin = '${((o.pickupEtaSeconds ?? 0) / 60).ceil()}';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IyoBadge(t.newRequest),
                      const SizedBox(height: 10),
                      IyoText(
                        t.youEarn(formatFcfa(ride.driverEarnings)),
                        variant: IyoTextVariant.title,
                      ),
                      Footnote(
                        '${formatFcfa(ride.fareAmount)} · ${paymentLabel(context, ride.paymentMethod)}',
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _countdown,
                  builder: (_, _) {
                    final seconds = (_countdown.value * _window.inSeconds).ceil();
                    return Semantics(
                      label: t.secondsLeft('$seconds'),
                      child: CountdownRing(progress: _countdown.value, label: '$seconds'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            IyoPersonInfoCard(
              name: o.rider.firstName,
              meta: t.riderRating(o.rider.rating?.toStringAsFixed(1) ?? '–'),
            ),
            const SizedBox(height: 12),
            IyoCard(
              children: [
                IyoListRow(
                  icon: LucideIcons.circleDot,
                  iconWellTone: IyoIconWellTone.none,
                  title: ride.pickup.name,
                  subtitle: t.pickupIn(pickupMin, formatDistance(o.pickupDistanceMeters ?? 0)),
                ),
                IyoListRow(
                  icon: LucideIcons.mapPin,
                  iconWellTone: IyoIconWellTone.none,
                  title: ride.dropoff.name,
                  subtitle: t.tripLength(
                    formatDistance(ride.distanceMeters),
                    '${(ride.durationSeconds / 60).round()}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IyoButton(label: t.accept, onPressed: () => Navigator.of(context).pop(true)),
            const SizedBox(height: 10),
            IyoButton(
              label: t.decline,
              variant: IyoButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

/// D20 — Earnings (Figma 2025:698; frame not attached). Payout history comes in Phase 11.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final today = ref.watch(_todayProvider).value;
    final trips = ref.watch(_tripsProvider).value ?? const <CompletedTrip>[];
    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(title: t.earningsTitle, subtitle: t.earningsSubtitle, compact: true),
      children: [
        IyoCard(
          children: [
            Footnote(t.today),
            IyoText(formatFcfa(today?.earnings ?? 0), variant: IyoTextVariant.amount),
            Footnote(t.tripsCount(today?.trips ?? 0)),
          ],
        ),
        SectionTitle(t.recentTrips),
        if (trips.isEmpty)
          IyoEmptyState(title: t.noTripsTitle, message: t.noTripsBody, icon: LucideIcons.wallet)
        else
          IyoCard(
            children: [
              for (final trip in trips)
                IyoListRow(
                  title: trip.dropoffName,
                  titleVariant: IyoTextVariant.listTitle,
                  titleAside: formatFcfa(trip.earnings),
                  subtitle: '${formatDateTime(trip.completedAt)} · ${formatFcfa(trip.fareAmount)}',
                  verticalPadding: 4,
                ),
            ],
          ),
      ],
    );
  }
}

/// D22 — Bookings and trip history (Figma 2025:793; frame not attached).
enum _BookingsTab { rentals, trips }

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  var _tab = _BookingsTab.rentals;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final trips = ref.watch(_tripsProvider).value ?? const <CompletedTrip>[];
    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(title: t.bookingsTitle, subtitle: t.bookingsSubtitle, compact: true),
      children: [
        IyoSegmentedTabs<_BookingsTab>(
          value: _tab,
          onChanged: (v) => setState(() => _tab = v),
          options: [
            IyoSegment(value: _BookingsTab.rentals, label: t.segmentRentals),
            IyoSegment(value: _BookingsTab.trips, label: t.segmentTrips),
          ],
        ),
        if (_tab == _BookingsTab.rentals)
          const AssignedRentalsList()
        else if (trips.isEmpty)
          IyoEmptyState(title: t.noTripsTitle, message: t.noTripsBody, icon: LucideIcons.listChecks)
        else
          for (final trip in trips)
            IyoCard(
              children: [
                IyoListRow(
                  title: trip.dropoffName,
                  titleVariant: IyoTextVariant.listTitle,
                  titleAside: formatFcfa(trip.fareAmount),
                  subtitle: formatDateTime(trip.completedAt),
                  verticalPadding: 0,
                ),
              ],
            ),
      ],
    );
  }
}

/// D19 — Account (Figma 2025:643; frame not attached): profile, vehicle, language, sign out.
class DriverAccountScreen extends ConsumerWidget {
  const DriverAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final profile = ref.watch(profileProvider).value;
    final account = ref.watch(driverAccountProvider).value;
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final common = CommonLocalizations.of(context);
    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(title: t.accountTitle, subtitle: t.accountSubtitle, compact: true),
      children: [
        IyoCard(
          children: [
            IyoListRow(
              leading: IyoAvatar(name: profile?.fullName ?? '', size: 44),
              title: profile?.fullName ?? '',
              titleVariant: IyoTextVariant.listTitle,
              subtitle: formatPhone(profile?.phone ?? ''),
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.carFront,
              iconWellTone: IyoIconWellTone.white,
              title: t.vehicle,
              subtitle:
                  account?.vehicle == null
                      ? '–'
                      : '${account!.vehicle!.label} · ${account.vehicle!.plate}',
            ),
            IyoListRow(
              icon: LucideIcons.languages,
              iconWellTone: IyoIconWellTone.white,
              title: t.language,
              subtitle: isFrench ? common.languageFr : common.languageEn,
              onPressed:
                  () => ref
                      .read(localeControllerProvider.notifier)
                      .set(Locale(isFrench ? 'en' : 'fr')),
            ),
            IyoListRow(
              icon: LucideIcons.triangleAlert,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuReportIncident,
              onPressed: () => context.push('/incident'),
            ),
            IyoListRow(
              icon: LucideIcons.logOut,
              iconWellTone: IyoIconWellTone.white,
              title: t.signOut,
              destructive: true,
              onPressed: () async {
                await ref.read(onlineControllerProvider.notifier).goOffline();
                await ref.read(backendProvider).signOut();
              },
            ),
          ],
        ),
      ],
    );
  }
}
