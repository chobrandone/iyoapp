import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../sample/sample_data.dart';
import '../state/booking.dart';
import '../state/location.dart';
import '../widgets/rider_widgets.dart';
import 'trip_view.dart';

enum _Service { ride, rent }

Future<void> _dial(String? phone) async {
  if (phone == null || phone.isEmpty) return;
  // TODO(spec §9.8): masked calling is out of scope for v1; this dials the number directly.
  await launchUrl(Uri(scheme: 'tel', path: phone));
}

/// Pickup for "current location", named after the nearest known place in demo mode.
Place currentLocationPlace(BuildContext context, GeoPoint at) => Place(
  name: context.t.currentLocationLabel,
  address: '${at.lat.toStringAsFixed(5)}, ${at.lng.toStringAsFixed(5)}',
  location: at,
);

/// RIDER · 01 — Home tab (Figma 2005:50127).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.preview = false});

  /// Design preview: Figma sample content, no location request.
  final bool preview;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _service = _Service.ride;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final profile = widget.preview ? null : ref.watch(profileProvider).value;
    final location = widget.preview ? null : ref.watch(locationProvider).value;
    GeoPoint? here;
    String subtitle = t.homeYouAreAt(Sample.currentPlace);
    if (!widget.preview) {
      switch (location) {
        case LocationFound(:final point):
          here = point;
          subtitle = t.homeYouAreAt(
            '${point.lat.toStringAsFixed(4)}, ${point.lng.toStringAsFixed(4)}',
          );
          final booking = ref.read(bookingProvider);
          if (booking.pickup?.location != point) {
            // Providers can't change during build; set the pickup right after this frame.
            final place = currentLocationPlace(context, point);
            Future.microtask(() {
              if (mounted) ref.read(bookingProvider.notifier).setPickup(place);
            });
          }
        case LocationUnavailable():
          subtitle = t.locationDeniedBody;
        case LocationLoading() || null:
          subtitle = t.locatingYou;
      }
    }

    void goPlan([Place? to]) {
      if (to != null) ref.read(bookingProvider.notifier).setDropoff(to);
      context.push('/plan');
    }

    return IyoScreen(
      inTabs: true,
      header: IyoAppHeader(flowLabel: t.flowRider('01')),
      heading: IyoPageHeading(
        title: t.homeGreeting(profile?.firstName ?? Sample.riderFirstName),
        subtitle: subtitle,
      ),
      children: [
        IyoSegmentedTabs<_Service>(
          large: true,
          value: _service,
          onChanged: (v) => setState(() => _service = v),
          options: [
            IyoSegment(value: _Service.ride, label: t.serviceRide, icon: LucideIcons.carFront),
            IyoSegment(value: _Service.rent, label: t.serviceRent, icon: LucideIcons.calendarDays),
          ],
        ),
        PickupMap(
          height: 218,
          pickup: here,
          onRecenter: () => ref.read(locationProvider.notifier).retry(),
        ),
        if (location case LocationUnavailable(:final permanently))
          IyoCard(
            tone: IyoCardTone.accent,
            title: t.locationDeniedTitle,
            description: t.locationDeniedBody,
            children: [
              if (permanently)
                IyoButton(
                  label: t.openSettings,
                  variant: IyoButtonVariant.secondary,
                  size: IyoButtonSize.sm,
                  onPressed: () => ref.read(locationProvider.notifier).openSettings(),
                ),
            ],
          ),
        IyoButton(
          label: t.whereTo,
          icon: LucideIcons.search,
          iconSize: 11,
          mirrorIcon: true,
          onPressed: goPlan,
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.house,
              iconWellTone: IyoIconWellTone.none,
              title: t.savedHome,
              subtitle: Sample.homeAddress,
              showChevron: false,
              onPressed: () => goPlan(doualaPlaces[3]),
            ),
            IyoListRow(
              icon: LucideIcons.clock3,
              iconWellTone: IyoIconWellTone.none,
              title: Sample.recentPlace,
              subtitle: t.recentDestination(Sample.recentArea),
              showChevron: false,
              onPressed: () => goPlan(doualaPlaces[1]),
            ),
          ],
        ),
        Footnote(t.nearbyRides(Sample.nearbyFrom, '3')),
      ],
    );
  }
}

enum _Field { pickup, destination }

/// RIDER · 02 — Plan your ride (Figma 2005:50194): Places search with 300 ms debounce and a
/// session token per search, route + distance once both ends are known.
class PlanRideScreen extends ConsumerStatefulWidget {
  const PlanRideScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<PlanRideScreen> createState() => _PlanRideScreenState();
}

class _PlanRideScreenState extends ConsumerState<PlanRideScreen> {
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  _Field _editing = _Field.destination;
  List<Place> _suggestions = const [];
  bool _searching = false;
  String _session = newSessionToken();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.preview) {
      _pickupCtrl.text = Sample.currentPlace;
      _destCtrl.text = Sample.destination;
    } else {
      final b = ref.read(bookingProvider);
      _pickupCtrl.text = b.pickup?.name ?? '';
      _destCtrl.text = b.dropoff?.name ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  void _onChanged(_Field field, String text) {
    _editing = field;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _searching = true);
      final near = ref.read(bookingProvider).pickup?.location;
      try {
        final list = await ref
            .read(backendProvider)
            .autocomplete(text, sessionToken: _session, near: near);
        if (mounted) setState(() => _suggestions = list);
      } on BackendException {
        if (mounted) setState(() => _suggestions = const []);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  Future<void> _pick(Place suggestion) async {
    final place = await ref.read(backendProvider).details(suggestion, sessionToken: _session);
    _session = newSessionToken(); // details ends the billing session
    final booking = ref.read(bookingProvider.notifier);
    if (_editing == _Field.pickup) {
      booking.setPickup(place);
      _pickupCtrl.text = place.name;
    } else {
      booking.setDropoff(place);
      _destCtrl.text = place.name;
    }
    if (mounted) {
      FocusScope.of(context).unfocus();
      setState(() => _suggestions = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final booking = widget.preview ? null : ref.watch(bookingProvider);
    final dropoff = booking?.dropoff;
    final estimate = booking?.estimate;
    final ready = widget.preview || (estimate != null && !booking!.loading);
    final routeText =
        widget.preview
            ? t.routeSummary(Sample.tripDistance, Sample.tripMinutes)
            : estimate == null
            ? (booking!.loading ? t.locatingYou : '')
            : t.routeSummary(
              formatDistance(estimate.route.distanceMeters),
              '${(estimate.route.durationSeconds / 60).round()}',
            );

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('02')),
      heading: IyoPageHeading(title: t.planTitle, subtitle: t.planSubtitle),
      footer: [
        IyoButton(
          label: t.confirmRoute,
          disabled: !ready,
          loading: booking?.loading ?? false,
          onPressed: () => context.push(widget.preview ? '/trip/arriving' : '/choose'),
        ),
      ],
      children: [
        IyoTextField(
          label: t.fieldPickup,
          controller: _pickupCtrl,
          placeholder: t.searchPlaces,
          helper: '${t.currentLocation} · ${t.editPickup}',
          onChanged: (v) => _onChanged(_Field.pickup, v),
          onTap: () => setState(() => _editing = _Field.pickup),
        ),
        IyoTextField(
          label: t.fieldDestination,
          controller: _destCtrl,
          placeholder: t.searchPlaces,
          highlighted: _editing == _Field.destination,
          onChanged: (v) => _onChanged(_Field.destination, v),
          onTap: () => setState(() => _editing = _Field.destination),
        ),
        if (_suggestions.isNotEmpty || _searching)
          IyoCard(
            tone: IyoCardTone.white,
            children: [
              if (_searching && _suggestions.isEmpty) const IyoSkeletonRow(),
              for (final s in _suggestions)
                IyoListRow(
                  icon: LucideIcons.mapPin,
                  title: s.name,
                  subtitle: s.address,
                  showChevron: false,
                  onPressed: () => _pick(s),
                ),
            ],
          )
        else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: IyoBadge(t.whenWho, trailingIcon: LucideIcons.chevronDown),
          ),
          if (widget.preview || dropoff != null)
            IyoListRow(
              icon: LucideIcons.trainFront,
              title: dropoff?.name ?? Sample.destination,
              subtitle: dropoff?.address ?? Sample.destinationAddress,
              verticalPadding: 0,
              trailing: const IyoIcon(LucideIcons.check, size: IyoSizes.iconSmall),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              if (widget.preview)
                const RouteMap(height: 238)
              else if (booking!.pickup?.location != null && dropoff?.location != null)
                RouteMap(
                  height: 238,
                  pickup: booking.pickup!.location!,
                  destination: dropoff!.location!,
                  car: null,
                  points: estimate?.route.points ?? const [],
                )
              else
                PickupMap(height: 238, pickup: booking.pickup?.location, car: null),
              const SizedBox(height: 14),
              if (booking?.error != null)
                IyoText(
                  CommonLocalizations.of(context).errorGeneric,
                  variant: IyoTextVariant.caption,
                  color: IyoPalette.danger,
                )
              else
                Footnote(routeText),
            ],
          ),
        ],
      ],
    );
  }
}

/// Choose a ride (R8; frame not attached — built from the design system): upfront prices per
/// category, payment method, book.
class ChooseRideScreen extends ConsumerWidget {
  const ChooseRideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final booking = ref.watch(bookingProvider);
    final estimate = booking.estimate;
    final lang = Localizations.localeOf(context).languageCode;
    final selected = booking.selected;

    Future<void> book() async {
      final ride = await ref.read(bookingProvider.notifier).request();
      if (ride != null && context.mounted) context.go('/ride/${ride.id}');
    }

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('03')),
      heading: IyoPageHeading(
        title: t.chooseTitle,
        subtitle:
            estimate == null
                ? null
                : t.chooseSubtitle(
                  formatDistance(estimate.route.distanceMeters),
                  '${(estimate.route.durationSeconds / 60).round()}',
                  booking.dropoff?.name ?? '',
                ),
        onBack: context.pop,
      ),
      footer: [
        if (booking.error != null)
          IyoText(
            booking.error == 'quote_expired'
                ? t.quoteExpired
                : CommonLocalizations.of(context).errorGeneric,
            variant: IyoTextVariant.caption,
            color: IyoPalette.danger,
          ),
        IyoButton(
          label:
              selected == null
                  ? t.chooseTitle
                  : t.bookCategory(selected.name(lang), formatFcfa(selected.fareAmount)),
          disabled: selected == null,
          loading: booking.loading,
          onPressed: book,
        ),
      ],
      children: [
        if (estimate == null)
          const IyoSkeleton(height: 72, radius: IyoRadii.lg)
        else ...[
          for (final option in estimate.options)
            _RideOptionCard(
              option: option,
              selected: option.quoteId == selected?.quoteId,
              onTap: () => ref.read(bookingProvider.notifier).select(option),
            ),
          if (estimate.options.any((o) => o.isPlaceholder)) Footnote(t.upfrontPrice),
        ],
        IyoSelectField<PaymentMethodType>(
          label: t.paymentMethod,
          value: booking.paymentMethod,
          onChanged: (v) => ref.read(bookingProvider.notifier).setPayment(v),
          options: [
            for (final m in const [
              PaymentMethodType.mtnMomo,
              PaymentMethodType.orangeMoney,
              PaymentMethodType.cash,
            ])
              IyoSelectOption(value: m, label: paymentMethodLabel(context, m)),
          ],
        ),
      ],
    );
  }
}

/// RideOptionCard (rider-only component, spec §5).
class _RideOptionCard extends StatelessWidget {
  const _RideOptionCard({required this.option, required this.selected, required this.onTap});

  final FareOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final iyo = context.iyo;
    final lang = Localizations.localeOf(context).languageCode;
    return IyoPressable(
      onPressed: onTap,
      selected: selected,
      semanticLabel: '${option.name(lang)}, ${formatFcfa(option.fareAmount)}',
      child: Container(
        padding: const EdgeInsets.all(IyoSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? iyo.accentSoft : IyoPalette.surface,
          borderRadius: BorderRadius.circular(IyoRadii.lg),
          border: Border.all(color: selected ? iyo.accent : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            const IyoIcon(LucideIcons.carFront, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IyoText(option.name(lang), variant: IyoTextVariant.listTitle),
                  Footnote(
                    '${t.seats('${option.seats}')} · '
                    '${option.etaMinutes == null ? t.noEta : t.etaAway('${option.etaMinutes}')}',
                  ),
                ],
              ),
            ),
            IyoText(formatFcfa(option.fareAmount), variant: IyoTextVariant.subheading),
          ],
        ),
      ),
    );
  }
}

/// Driver card used on the trip screens (DriverInfoCard).
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.view});

  final TripView view;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoPersonInfoCard(
      name: view.driverFull,
      meta: view.driverMeta,
      detail: view.vehicle,
      onCall: () => _dial(view.driverPhone),
      callLabel: t.callPerson(view.driverFirst),
    );
  }
}

class _TripTiles extends StatelessWidget {
  const _TripTiles({this.rideId});

  final String? rideId;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoActionTileRow(
      children: [
        IyoActionTile(
          icon: LucideIcons.messageCircle,
          label: t.tileMessage,
          onPressed: () => context.push(rideId == null ? '/trip/chat' : '/ride/$rideId/chat'),
        ),
        IyoActionTile(icon: LucideIcons.share2, label: t.tileShareTrip, onPressed: () {}),
        IyoActionTile(
          icon: LucideIcons.shieldCheck,
          label: t.tileSafety,
          accent: true,
          onPressed: () => context.push('/safety-alert'),
        ),
      ],
    );
  }
}

/// Live ride: renders the screen for the current status and follows it in real time.
class RideFlowScreen extends ConsumerWidget {
  const RideFlowScreen({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final rideAsync = ref.watch(rideProvider(rideId));
    return rideAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => IyoScreen(
            header: IyoAppHeader(flowLabel: t.flowRiderPlain),
            children: [
              IyoErrorState(
                title: t.errorTitle,
                message: CommonLocalizations.of(context).errorGeneric,
                retryLabel: t.backHome,
                onRetry: () => context.go('/home'),
              ),
            ],
          ),
      data: (ride) {
        final driverAsync = ref.watch(_driverProvider((rideId, ride.status)));
        final view = TripView.live(context, ride, driverAsync.value);
        return switch (ride.status) {
          RideStatus.requested || RideStatus.searching => MatchingView(ride: ride),
          RideStatus.driverAssigned ||
          RideStatus.driverArriving => DriverArrivingView(view: view, rideId: rideId),
          RideStatus.driverArrived => DriverArrivingView(view: view, rideId: rideId, arrived: true),
          RideStatus.inProgress => OnYourWayView(view: view, rideId: rideId),
          RideStatus.completed => TripCompleteView(view: view, rideId: rideId),
          RideStatus.noDriversFound => NoDriversView(view: view, live: true),
          RideStatus.cancelledByRider || RideStatus.cancelledByDriver => _CancelledView(ride: ride),
        };
      },
    );
  }
}

/// Driver details for a ride; refetched when the status changes (assignment, trip start).
final _driverProvider = FutureProvider.family<Counterpart?, (String, RideStatus)>(
  (ref, key) => ref.watch(backendProvider).driverFor(key.$1),
);

/// Booking and matching (R9; frame not attached).
class MatchingView extends ConsumerWidget {
  const MatchingView({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('04')),
      heading: IyoPageHeading(
        title: t.matchingTitle,
        subtitle: t.matchingSubtitle(ride.pickup.name),
      ),
      footer: [
        IyoButton(
          label: t.cancelRequest,
          variant: IyoButtonVariant.secondary,
          onPressed:
              () => ref.read(backendProvider).cancel(ride.id, reason: 'rider_cancelled_search'),
        ),
      ],
      children: [
        PickupMap(height: 256, pickup: ride.pickup.location, car: null),
        LinearProgressIndicator(
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
          color: context.iyo.accent,
          backgroundColor: IyoPalette.surface,
        ),
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            IyoText(t.matchingBody(formatFcfa(ride.fareAmount)), color: IyoPalette.charcoal),
          ],
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.none,
              title: ride.dropoff.name,
              titleVariant: IyoTextVariant.listTitle,
              subtitle: ride.dropoff.address,
            ),
          ],
        ),
      ],
    );
  }
}

/// Pickup details + cancel (R16; frame not attached): a bottom sheet over the trip screen.
Future<void> showPickupSheet(BuildContext context, WidgetRef ref, TripView view, String rideId) {
  final t = context.t;
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
              children: [
                IyoText(view.pickupName, variant: IyoTextVariant.cardTitle),
                const SizedBox(height: 4),
                Footnote(t.pinCardBody(view.pickupName, view.driverFirst)),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: IyoBadge(t.pickupPin(view.pin))),
                const SizedBox(height: 20),
                IyoButton(
                  label: t.cancelRide,
                  variant: IyoButtonVariant.danger,
                  onPressed: () async {
                    Navigator.of(sheet).pop();
                    await showCancelSheet(context, ref, rideId);
                  },
                ),
              ],
            ),
          ),
        ),
  );
}

Future<void> showCancelSheet(BuildContext context, WidgetRef ref, String rideId) async {
  final t = context.t;
  final reasons = {
    'waiting_too_long': t.cancelReasonWait,
    'plans_changed': t.cancelReasonPlans,
    'wrong_pickup': t.cancelReasonPickup,
    'other': t.cancelReasonOther,
  };
  String? reason = reasons.keys.first;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: IyoPalette.white,
    barrierColor: IyoPalette.overlay,
    builder:
        (sheet) => StatefulBuilder(
          builder:
              (sheet, setState) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IyoText(t.cancelTitle, variant: IyoTextVariant.cardTitle),
                      const SizedBox(height: 4),
                      Footnote(t.cancelBody),
                      const SizedBox(height: 8),
                      for (final e in reasons.entries)
                        IyoListRow(
                          title: e.value,
                          showChevron: false,
                          verticalPadding: 4,
                          onPressed: () => setState(() => reason = e.key),
                          trailing:
                              reason == e.key ? const IyoIcon(LucideIcons.check, size: 18) : null,
                        ),
                      const SizedBox(height: 12),
                      IyoButton(
                        label: t.confirmCancel,
                        variant: IyoButtonVariant.danger,
                        onPressed: () => Navigator.of(sheet).pop(true),
                      ),
                      const SizedBox(height: 10),
                      IyoButton(
                        label: t.keepRide,
                        variant: IyoButtonVariant.secondary,
                        onPressed: () => Navigator.of(sheet).pop(false),
                      ),
                    ],
                  ),
                ),
              ),
        ),
  );
  if (confirmed == true) await ref.read(backendProvider).cancel(rideId, reason: reason);
}

/// RIDER · 05 — Driver on the way / arrived, pickup PIN (Figma 2005:50366).
class DriverArrivingView extends ConsumerWidget {
  const DriverArrivingView({super.key, required this.view, this.rideId, this.arrived = false});

  final TripView view;

  /// Null in the design preview.
  final String? rideId;
  final bool arrived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('05')),
      heading: IyoPageHeading(
        title: arrived ? t.driverArrivedTitle(view.driverFirst) : t.arrivingTitle(view.driverFirst),
        subtitle:
            arrived
                ? t.driverArrivedSubtitle(view.pickupName)
                : t.arrivingSubtitle(view.etaMinutes, view.etaDistance),
      ),
      footer: [
        IyoButton(
          label: t.viewPickupDetails,
          variant: IyoButtonVariant.secondary,
          onPressed:
              rideId == null
                  ? () => context.push('/trip/live')
                  : () => showPickupSheet(context, ref, view, rideId!),
        ),
      ],
      children: [
        if (view.pickup == null)
          const RouteMap(height: 256)
        else
          RouteMap(
            height: 256,
            pickup: view.pickup!,
            destination: view.dropoff!,
            car: view.car,
            carHeading: view.carHeading,
          ),
        _DriverCard(view: view),
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.pickupPin(view.pin))),
            IyoText(t.pinCardBody(view.pickupName, view.driverFirst), color: IyoPalette.charcoal),
          ],
        ),
        _TripTiles(rideId: rideId),
        Footnote('${t.checkPlate}\n${t.standardFare(view.fare)}'),
      ],
    );
  }
}

/// RIDER · 06 — Live trip (Figma 2005:50425).
class OnYourWayView extends StatelessWidget {
  const OnYourWayView({super.key, required this.view, this.rideId});

  final TripView view;
  final String? rideId;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('06')),
      heading: IyoPageHeading(
        title: t.onWayTitle,
        subtitle: t.arriveAt(view.dropoffName, view.arriveTime),
      ),
      children: [
        if (view.pickup == null)
          const RouteMap(height: 316)
        else
          RouteMap(
            height: 316,
            pickup: view.pickup!,
            destination: view.dropoff!,
            car: view.car,
            carHeading: view.carHeading,
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.timeLeft(view.etaMinutes, view.etaDistance)),
        ),
        _DriverCard(view: view),
        _TripTiles(rideId: rideId),
        IyoCard(
          onPressed: rideId == null ? () => context.push('/trip/complete') : null,
          children: [
            IyoListRow(
              icon: LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.none,
              title: view.dropoffName,
              titleVariant: IyoTextVariant.listTitle,
              subtitle: view.dropoffDetail,
            ),
            Footnote(t.tripFooter(view.fare, view.paymentLabel, view.tripRef)),
          ],
        ),
      ],
    );
  }
}

/// RIDER · 07 — Arrived: receipt and rating (Figma 2005:50486).
class TripCompleteView extends ConsumerStatefulWidget {
  const TripCompleteView({super.key, required this.view, this.rideId});

  final TripView view;
  final String? rideId;

  @override
  ConsumerState<TripCompleteView> createState() => _TripCompleteViewState();
}

class _TripCompleteViewState extends ConsumerState<TripCompleteView> {
  int _stars = 5;
  int _tip = 0;
  bool _sending = false;

  static const _tipAmounts = [0, 200, 500, 1000];

  Future<void> _finish() async {
    final id = widget.rideId;
    if (id != null) {
      setState(() => _sending = true);
      try {
        await ref.read(backendProvider).rate(id, _stars, tip: _tipAmounts[_tip]);
      } on BackendException {
        // Rating is optional; never block the rider here.
      }
      ref.read(bookingProvider.notifier).reset();
    }
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final view = widget.view;
    Widget line(String label, String value) => Row(
      children: [
        Expanded(child: IyoText(label, color: IyoPalette.charcoal)),
        IyoText(value, variant: IyoTextVariant.bodyStrong),
      ],
    );
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('07')),
      heading: IyoPageHeading(title: t.arrivedTitle, subtitle: t.arrivedSubtitle),
      footer: [IyoButton(label: t.submitRating, loading: _sending, onPressed: _finish)],
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.paymentComplete, tone: IyoBadgeTone.success),
        ),
        IyoCard(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IyoText(view.fare, variant: IyoTextVariant.amountHero),
                const SizedBox(height: 17),
                line(t.rideFare, view.rideFare ?? view.fare),
                if (view.bookingFee != null) ...[
                  const SizedBox(height: 12),
                  line(t.bookingFee, view.bookingFee!),
                ],
                const SizedBox(height: 12),
                Footnote(t.receiptSent(view.paymentLabel)),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Footnote('${view.pickupName} → ${view.dropoffName}\n${view.tripDate}'),
            const SizedBox(height: 14),
            _DriverCard(view: view),
            const SizedBox(height: 14),
            IyoText(
              t.howWasRide,
              variant: IyoTextVariant.heading,
              align: TextAlign.center,
              header: true,
            ),
            const SizedBox(height: 10),
            RatingStars(value: _stars, onChanged: (v) => setState(() => _stars = v)),
            const SizedBox(height: 12),
            TipSelector(
              options: [t.noTip, for (final a in _tipAmounts.skip(1)) formatFcfa(a)],
              selected: _tip,
              onChanged: (v) => setState(() => _tip = v),
            ),
          ],
        ),
      ],
    );
  }
}

class _CancelledView extends StatelessWidget {
  const _CancelledView({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(title: t.rideCancelledTitle),
      footer: [IyoButton(label: t.backHome, onPressed: () => context.go('/home'))],
      children: [
        IyoEmptyState(
          icon: LucideIcons.circleX,
          title: t.rideCancelledTitle,
          message:
              ride.status == RideStatus.cancelledByDriver
                  ? t.rideCancelledByDriver
                  : t.rideCancelledByYou,
        ),
      ],
    );
  }
}

/// Chat with the driver (Figma 2025:342). Without [rideId] it shows the design sample.
class TripChatScreen extends ConsumerWidget {
  const TripChatScreen({super.key, this.rideId});

  final String? rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final id = rideId;
    final ride = id == null ? null : ref.watch(rideProvider(id)).value;
    final driver = ride == null ? null : ref.watch(_driverProvider((id!, ride.status))).value;
    final view = ride == null ? TripView.sample(context) : TripView.live(context, ride, driver);
    final me = ref.watch(profileProvider).value?.id;

    final List<IyoChatMessage> messages;
    if (id == null) {
      messages = [
        for (final line in driverChat)
          IyoChatMessage(
            id: line.time + line.en,
            body: tr(context, line.en, line.fr),
            mine: line.mine,
            meta: line.read ? '${line.time} · ${t.read}' : line.time,
          ),
      ];
    } else {
      messages = [
        for (final m in ref.watch(chatProvider(id)).value ?? const <ChatEntry>[])
          IyoChatMessage(
            id: m.id,
            body: m.body,
            mine: m.senderId == me,
            meta:
                m.readAt != null && m.senderId == me
                    ? '${formatTime(m.sentAt)} · ${t.read}'
                    : formatTime(m.sentAt),
          ),
      ];
    }

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.chatWith(view.driverFirst),
        subtitle: t.chatSubtitle(id == null ? Sample.rideId : view.tripRef, view.pickupName),
        onBack: context.pop,
      ),
      children: [
        IyoCard(
          children: [
            Row(
              children: [
                IyoAvatar(name: view.driverFull),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IyoText(view.driverFull, variant: IyoTextVariant.heading),
                      IyoText(
                        '${view.vehicleShort} · ★ ${driver?.rating?.toStringAsFixed(1) ?? Sample.driverRating}',
                        variant: IyoTextVariant.caption,
                        color: IyoPalette.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.arrivingIn(view.etaMinutes))),
          ],
        ),
        IyoText(
          t.privacyNote,
          variant: IyoTextVariant.micro,
          color: IyoPalette.textSecondary,
          align: TextAlign.center,
        ),
        for (final m in messages) IyoChatBubble(message: m),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: IyoButton(
                    label: t.imHere,
                    variant: IyoButtonVariant.secondary,
                    size: IyoButtonSize.sm,
                    onPressed:
                        id == null ? () {} : () => ref.read(backendProvider).send(id, t.imHere),
                  ),
                ),
                const SizedBox(width: IyoSpacing.sm),
                Expanded(
                  child: IyoButton(
                    label: t.callDriver,
                    icon: LucideIcons.phone,
                    variant: IyoButtonVariant.secondary,
                    size: IyoButtonSize.sm,
                    onPressed: () => _dial(view.driverPhone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Footnote(t.chatFooter(Sample.emergencyNumber)),
          ],
        ),
        IyoChatComposer(
          placeholder: t.writeMessage,
          sendLabel: t.send,
          attachLabel: t.attach,
          onAttach: () {},
          onSend: (text) {
            if (id != null) ref.read(backendProvider).send(id, text);
          },
        ),
      ],
    );
  }
}

/// No drivers available (Figma 2025:438).
class NoDriversView extends ConsumerWidget {
  const NoDriversView({super.key, required this.view, this.live = false});

  final TripView view;
  final bool live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    Future<void> again() async {
      if (!live) {
        await context.push('/trip/arriving');
        return;
      }
      await ref.read(bookingProvider.notifier).refresh();
      if (context.mounted) context.go('/choose');
    }

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.noDriversTitle,
        subtitle: t.noDriversSubtitle(live ? view.pickupName : Sample.pickupArea),
        onBack: () => live ? context.go('/home') : context.pop(),
      ),
      footer: [
        IyoButton(label: t.tryAgain, icon: LucideIcons.rotateCw, onPressed: again),
        IyoButton(
          label: t.changePickup,
          variant: IyoButtonVariant.secondary,
          onPressed: () => live ? context.go('/plan') : context.push('/design/plan'),
        ),
      ],
      children: [
        PickupMap(height: 222, pickup: view.pickup),
        IyoCard(
          children: [
            IconTitleRow(
              icon: LucideIcons.carFront,
              title: t.tryAgainShortly,
              titleVariant: IyoTextVariant.cardTitle,
              iconGap: 8,
            ),
            IyoText(t.noMatchBody, color: IyoPalette.textSecondary),
          ],
        ),
        IyoCard(
          children: [
            IyoText(view.pickupName, variant: IyoTextVariant.listTitle),
            Footnote(t.toPlace(view.dropoffName)),
            Align(
              alignment: Alignment.centerLeft,
              child: IyoBadge(t.requestNotBooked, tone: IyoBadgeTone.neutral),
            ),
          ],
        ),
        Footnote(t.noDriversHint),
      ],
    );
  }
}
