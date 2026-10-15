import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/driver_location.dart';
import '../state/online.dart';
import '../widgets/driver_widgets.dart';
import '../sample/sample_data.dart';
import 'home_screens.dart';
import 'safety_screens.dart';

final _riderProvider = FutureProvider.family<Counterpart?, (String, RideStatus)>(
  (ref, key) => ref.watch(backendProvider).riderFor(key.$1),
);

/// Opens turn-by-turn in Google Maps (falls back to the browser); the in-app map keeps the route.
Future<void> _navigateTo(GeoPoint p) => launchUrl(
  Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}&travelmode=driving',
  ),
  mode: LaunchMode.externalApplication,
);

Future<void> _dial(String? phone) async {
  if (phone == null) return;
  // TODO(spec §9.8): masked calling is out of scope for v1.
  await launchUrl(Uri(scheme: 'tel', path: phone));
}

/// Driver side of a live ride: one screen per status, following the ride in real time.
class DriverTripScreen extends ConsumerWidget {
  const DriverTripScreen({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(rideProvider(rideId));
    return rideAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => _EndedView(title: context.t.errorGeneric, body: ''),
      data: (ride) {
        final rider = ref.watch(_riderProvider((rideId, ride.status))).value;
        return switch (ride.status) {
          RideStatus.driverAssigned ||
          RideStatus.driverArriving => _ToPickupView(ride: ride, rider: rider),
          RideStatus.driverArrived => _ArrivedView(ride: ride, rider: rider),
          RideStatus.inProgress => _LiveView(ride: ride, rider: rider),
          RideStatus.completed => _CompleteView(ride: ride, rider: rider),
          RideStatus.cancelledByRider => _EndedView(
            title: context.t.riderCancelled,
            body: context.t.riderCancelledBody,
          ),
          _ => _EndedView(title: context.t.cancelRide, body: ''),
        };
      },
    );
  }
}

void _leaveTrip(BuildContext context, WidgetRef ref) {
  ref.read(activeRideProvider.notifier).set(null);
  ref
      .read(onlineControllerProvider.notifier)
      .setOnTrip(
        false,
        notificationTitle: context.t.onlineNotificationTitle,
        notificationBody: context.t.onlineNotificationBody,
      );
  context.go('/home');
}

/// Rider card on the trip screens (Figma "Trip companion"): photo, rating, PIN reminder, call.
class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.rider, this.preview = false});

  final Counterpart? rider;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final r = preview ? DriverSample.rider : rider;
    return IyoPersonInfoCard(
      name: r?.displayName ?? '…',
      photo: preview ? DriverSample.riderPhoto : null,
      meta: t.verifiedRider(r?.rating?.toStringAsFixed(1) ?? '–'),
      detail: t.askForPin,
      onCall: preview ? () {} : (r?.phone == null ? null : () => _dial(r!.phone)),
      callLabel: t.callRider(r?.firstName ?? ''),
    );
  }
}

/// Message · Share trip · Safety for a live ride (no-ops in previews).
class _RideTools extends ConsumerWidget {
  const _RideTools({required this.ride, this.preview = false, this.onCancel});

  final Ride ride;
  final bool preview;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (preview) return const TripTools();
    return TripTools(
      onMessage: () => context.push('/trip/${ride.id}/chat'),
      onShare: () => shareRide(context, ref, ride.id),
      onSafety: () => showDriverSafetySheet(context, ref, ride.id, onCancel: onCancel),
    );
  }
}

/// Next step towards [target]: the in-app card; turn-by-turn itself opens in Google Maps.
InstructionCard _instruction(BuildContext context, GeoPoint me, Place target) {
  final t = context.t;
  final left = demoRoute(me, target.location!).distanceMeters;
  if (left < 80) {
    return InstructionCard(icon: LucideIcons.mapPin, title: t.navArriving(target.name));
  }
  return InstructionCard(
    icon: LucideIcons.arrowUp,
    title: t.navContinue(formatDistance(left)),
    subtitle: t.navTowards(target.name),
  );
}

/// DRIVER · 04 — Navigate to pickup (Figma 2005:51403).
class _ToPickupView extends ConsumerStatefulWidget {
  const _ToPickupView({required this.ride, required this.rider, this.preview = false});

  final Ride ride;
  final Counterpart? rider;
  final bool preview;

  @override
  ConsumerState<_ToPickupView> createState() => _ToPickupViewState();
}

class _ToPickupViewState extends ConsumerState<_ToPickupView> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Accepted → on the way as soon as the driver opens the trip.
    if (!widget.preview && widget.ride.status == RideStatus.driverAssigned) {
      Future.microtask(
        () =>
            ref
                .read(backendProvider)
                .updateStatus(widget.ride.id, RideStatus.driverArriving)
                .ignore(),
      );
    }
  }

  Future<void> _arrived() async {
    if (widget.preview) return;
    setState(() => _busy = true);
    try {
      await ref.read(backendProvider).updateStatus(widget.ride.id, RideStatus.driverArrived);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ride = widget.ride;
    final preview = widget.preview;
    final me = ref.watch(lastPositionProvider);
    final pickup = ride.pickup.location!;
    final route = demoRoute(me.point, pickup);
    final name = preview ? DriverSample.riderFirstName : widget.rider?.firstName ?? '';
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('04')),
      heading: IyoPageHeading(
        title: t.headToRider(name),
        subtitle:
            preview
                ? t.headToSubtitle(ride.pickup.name, '3', '0.8 km')
                : t.headToSubtitle(
                  ride.pickup.name,
                  '${(route.durationSeconds / 60).ceil()}',
                  formatDistance(route.distanceMeters),
                ),
      ),
      footer: [IyoButton(label: t.arrivedAtPickup, loading: _busy, onPressed: _arrived)],
      children: [
        if (preview)
          InstructionCard(
            icon: LucideIcons.cornerUpRight,
            title: t.navTurnRight('150 m'),
            subtitle: t.navInto(DriverSample.pickupName),
          )
        else
          _instruction(context, me.point, ride.pickup),
        GestureDetector(
          onTap: preview ? null : () => _navigateTo(pickup),
          child: DriverMap(
            me: me.point,
            heading: me.heading,
            pickup: pickup,
            destination: ride.dropoff.location,
            height: 283,
          ),
        ),
        _RiderCard(rider: widget.rider, preview: preview),
        _RideTools(
          ride: ride,
          preview: preview,
          onCancel: () => _cancelSheet(context, ref, ride.id),
        ),
        Footnote([if (preview) t.pickupNote(DriverSample.pickupNote), t.stopSafely].join('\n')),
      ],
    );
  }
}

/// DRIVER · 05 — Arrival and rider PIN (Figma 2005:51465): wait timer, 4-digit PIN, start.
class _ArrivedView extends ConsumerStatefulWidget {
  const _ArrivedView({required this.ride, required this.rider, this.preview = false});

  final Ride ride;
  final Counterpart? rider;
  final bool preview;

  @override
  ConsumerState<_ArrivedView> createState() => _ArrivedViewState();
}

class _ArrivedViewState extends ConsumerState<_ArrivedView> {
  late String _pin = widget.preview ? DriverSample.pin : '';
  String? _error;
  bool _checking = false;
  bool _locked = false;
  late int _waited = widget.preview ? 84 : 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.preview) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _waited++));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (widget.preview) return;
    final t = context.t;
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final r = await ref.read(backendProvider).verifyPin(widget.ride.id, _pin);
      if (!mounted) return;
      if (r.locked) {
        setState(() {
          _locked = true;
          _error = t.pinLocked;
        });
      } else if (!r.ok) {
        setState(() {
          _error = t.pinWrong('${r.attemptsLeft}');
          _pin = '';
        });
      }
      // On success the ride stream moves to in_progress and this view is replaced.
    } on BackendException {
      if (mounted) setState(() => _error = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final name = preview ? DriverSample.riderFirstName : widget.rider?.firstName ?? '';
    final me = ref.watch(lastPositionProvider);
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('05')),
      heading: IyoPageHeading(title: t.atPickupTitle, subtitle: t.atPickupSubtitle(name)),
      footer: [
        IyoButton(
          label: t.startRide,
          disabled: _pin.length != 4 || _locked,
          loading: _checking,
          onPressed: _start,
        ),
      ],
      children: [
        DriverMap(
          me: me.point,
          heading: me.heading,
          pickup: widget.ride.pickup.location,
          destination: widget.ride.dropoff.location,
          height: 229,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.waitTime(formatDuration(_waited))),
        ),
        _RiderCard(rider: widget.rider, preview: preview),
        IyoPinInput(
          label: t.askPinLabel(name),
          value: _pin,
          onChanged:
              (v) => setState(() {
                _pin = v;
                _error = null;
              }),
          error: _error,
          highlighted: preview,
          helper:
              preview
                  ? t.pinVerified
                  : (ref.watch(backendProvider).isDemo ? t.pinDemoHint(demoPin) : null),
        ),
        _RideTools(
          ride: widget.ride,
          preview: preview,
          onCancel: () => _cancelSheet(context, ref, widget.ride.id),
        ),
        Footnote(t.confirmRiderNote(widget.ride.dropoff.name)),
      ],
    );
  }
}

/// DRIVER · 06 — Live ride navigation (Figma 2005:51527).
class _LiveView extends ConsumerStatefulWidget {
  const _LiveView({required this.ride, required this.rider, this.preview = false});

  final Ride ride;
  final Counterpart? rider;
  final bool preview;

  @override
  ConsumerState<_LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends ConsumerState<_LiveView> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ride = widget.ride;
    final preview = widget.preview;
    final me = ref.watch(lastPositionProvider);
    final left = demoRoute(me.point, ride.dropoff.location!);
    final arrive = DateTime.now().add(Duration(seconds: left.durationSeconds));
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('06')),
      heading: IyoPageHeading(
        title: t.driveTo(ride.dropoff.name),
        subtitle:
            preview
                ? t.driveSubtitle('09:56', '8', '2.1 km')
                : t.driveSubtitle(
                  formatTime(arrive),
                  '${(left.durationSeconds / 60).ceil()}',
                  formatDistance(left.distanceMeters),
                ),
      ),
      footer: [
        IyoButton(
          label: t.endRide,
          loading: _busy,
          onPressed: () async {
            if (preview) return;
            setState(() => _busy = true);
            try {
              await ref.read(backendProvider).updateStatus(ride.id, RideStatus.completed);
            } finally {
              if (mounted) setState(() => _busy = false);
            }
          },
        ),
      ],
      children: [
        if (preview)
          InstructionCard(
            icon: LucideIcons.arrowUp,
            title: t.navContinue('600 m'),
            subtitle: t.navOn('Boulevard de la Liberté'),
          )
        else
          _instruction(context, me.point, ride.dropoff),
        GestureDetector(
          onTap: preview ? null : () => _navigateTo(ride.dropoff.location!),
          child: DriverMap(
            me: me.point,
            heading: me.heading,
            pickup: ride.pickup.location,
            destination: ride.dropoff.location,
            height: 275,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(
            t.tripInProgress(preview ? DriverSample.tripRef : tripRef(ride.id)),
            tone: IyoBadgeTone.success,
          ),
        ),
        _RideTools(ride: ride, preview: preview),
        IyoListRow(
          icon: LucideIcons.mapPin,
          title: ride.dropoff.name,
          subtitle: preview ? t.mainEntrance(DriverSample.dropoffArea) : placeArea(ride.dropoff),
          showChevron: false,
        ),
      ],
    );
  }
}

/// Design previews of the live trip views (Figma sample ride and rider).
class TripPreview extends StatelessWidget {
  const TripPreview({super.key, required this.status});

  final RideStatus status;

  @override
  Widget build(BuildContext context) {
    final ride = DriverSample.ride(status);
    return switch (status) {
      RideStatus.driverArrived => _ArrivedView(
        ride: ride,
        rider: DriverSample.rider,
        preview: true,
      ),
      RideStatus.inProgress => _LiveView(ride: ride, rider: DriverSample.rider, preview: true),
      _ => _ToPickupView(ride: ride, rider: DriverSample.rider, preview: true),
    };
  }
}

// D14 — Ride complete and earnings (Figma 2005:51588).
class _CompleteView extends ConsumerStatefulWidget {
  const _CompleteView({required this.ride, required this.rider});

  final Ride ride;
  final Counterpart? rider;

  @override
  ConsumerState<_CompleteView> createState() => _CompleteViewState();
}

class _CompleteViewState extends ConsumerState<_CompleteView> {
  int _stars = 5;

  Future<void> _done() async {
    try {
      await ref.read(backendProvider).rateRider(widget.ride.id, _stars);
    } on BackendException {
      // Optional.
    }
    if (mounted) _leaveTrip(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ride = widget.ride;
    final name = widget.rider?.firstName ?? '';
    final accent = context.iyo.accent;
    Widget line(String label, String value) => Row(
      children: [
        Expanded(child: IyoText(label, color: IyoPalette.charcoal)),
        IyoText(value, variant: IyoTextVariant.bodyStrong),
      ],
    );
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('14')),
      heading: IyoPageHeading(
        title: t.completeTitle,
        subtitle: t.completeSubtitle(ride.dropoff.name, paymentLabel(context, ride.paymentMethod)),
      ),
      footer: [IyoButton(label: t.done, onPressed: _done)],
      children: [
        IyoCard(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Footnote(t.earnings),
                IyoText(formatFcfa(ride.driverEarnings), variant: IyoTextVariant.amountHero),
                const SizedBox(height: 14),
                line(t.fare, formatFcfa(ride.fareAmount)),
                const SizedBox(height: 10),
                line(t.commission, '− ${formatFcfa(ride.fareAmount - ride.driverEarnings)}'),
              ],
            ),
          ],
        ),
        if (ride.paymentMethod == PaymentMethodType.cash)
          IyoCard(
            tone: IyoCardTone.accent,
            description: t.collectCash(formatFcfa(ride.fareAmount), name),
          ),
        IyoText(t.rateRider(name), variant: IyoTextVariant.heading, align: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IyoPressable(
                onPressed: () => setState(() => _stars = i),
                semanticLabel: '$i',
                selected: i == _stars,
                child: Icon(
                  Icons.star_rounded,
                  size: 36,
                  color: i <= _stars ? accent : IyoPalette.border,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _EndedView extends ConsumerWidget {
  const _EndedView({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowPlain),
      footer: [IyoButton(label: t.backHome, onPressed: () => _leaveTrip(context, ref))],
      children: [IyoEmptyState(title: title, message: body, icon: LucideIcons.circleX)],
    );
  }
}

Future<void> _cancelSheet(BuildContext context, WidgetRef ref, String rideId) async {
  final t = context.t;
  final reasons = {
    'rider_no_show': t.cancelReasonNoShow,
    'unsafe': t.cancelReasonUnsafe,
    'vehicle_problem': t.cancelReasonVehicle,
    'other': t.cancelReasonOther,
  };
  String reason = reasons.keys.first;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: IyoPalette.white,
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
                        label: t.cancelRide,
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
  if (ok == true) {
    await ref
        .read(backendProvider)
        .updateStatus(rideId, RideStatus.cancelledByDriver, reason: reason);
    if (context.mounted) _leaveTrip(context, ref);
  }
}

/// D23 — In-trip chat with the rider (rider chat layout 2025:342 with the driver header).
class DriverChatScreen extends ConsumerWidget {
  const DriverChatScreen({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final ride = ref.watch(rideProvider(rideId)).value;
    final rider = ride == null ? null : ref.watch(_riderProvider((rideId, ride.status))).value;
    final me = ref.watch(profileProvider).value?.id;
    final messages = ref.watch(chatProvider(rideId)).value ?? const <ChatEntry>[];
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(
        title: t.chatWith(rider?.firstName ?? ''),
        subtitle: ride?.pickup.name,
        onBack: context.pop,
      ),
      children: [
        Footnote(t.chatPrivacy, align: TextAlign.center),
        for (final m in messages)
          IyoChatBubble(
            message: IyoChatMessage(
              id: m.id,
              body: m.body,
              mine: m.senderId == me,
              meta: formatTime(m.sentAt),
            ),
          ),
        IyoChatComposer(
          placeholder: t.writeMessage,
          sendLabel: t.send,
          onSend: (text) => ref.read(backendProvider).send(rideId, text),
        ),
      ],
    );
  }
}
