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

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.ride, required this.rider});

  final Ride ride;
  final Counterpart? rider;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final name = rider?.displayName ?? '…';
    return IyoPersonInfoCard(
      name: name,
      meta: t.riderRating(rider?.rating?.toStringAsFixed(1) ?? '–'),
      detail: '${formatFcfa(ride.fareAmount)} · ${paymentLabel(context, ride.paymentMethod)}',
      onMessage: () => context.push('/trip/${ride.id}/chat'),
      messageLabel: t.messageRider(rider?.firstName ?? ''),
      onCall: rider?.phone == null ? null : () => _dial(rider!.phone),
      callLabel: t.callRider(rider?.firstName ?? ''),
    );
  }
}

/// D11 — Navigate to pickup (Figma 2005:51403).
class _ToPickupView extends ConsumerStatefulWidget {
  const _ToPickupView({required this.ride, required this.rider});

  final Ride ride;
  final Counterpart? rider;

  @override
  ConsumerState<_ToPickupView> createState() => _ToPickupViewState();
}

class _ToPickupViewState extends ConsumerState<_ToPickupView> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Accepted → on the way as soon as the driver opens the trip.
    if (widget.ride.status == RideStatus.driverAssigned) {
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
    final me = ref.watch(lastPositionProvider);
    final pickup = ride.pickup.location!;
    final eta = (demoRoute(me.point, pickup).durationSeconds / 60).ceil();
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('11')),
      heading: IyoPageHeading(
        title: t.toPickupTitle(widget.rider?.firstName ?? ''),
        subtitle: t.toPickupSubtitle(ride.pickup.name, '$eta'),
      ),
      footer: [
        IyoButton(label: t.imHere, loading: _busy, onPressed: _arrived),
        IyoButton(
          label: t.cancelRide,
          variant: IyoButtonVariant.ghost,
          onPressed: () => _cancelSheet(context, ref, ride.id),
        ),
      ],
      children: [
        DriverMap(me: me.point, heading: me.heading, pickup: pickup),
        _RiderCard(ride: ride, rider: widget.rider),
        IyoButton(
          label: t.navigate,
          icon: LucideIcons.navigation,
          variant: IyoButtonVariant.secondary,
          size: IyoButtonSize.sm,
          onPressed: () => _navigateTo(pickup),
        ),
      ],
    );
  }
}

/// D12 — Arrival and rider PIN (Figma 2005:51465): wait timer, 4-digit PIN, start.
class _ArrivedView extends ConsumerStatefulWidget {
  const _ArrivedView({required this.ride, required this.rider});

  final Ride ride;
  final Counterpart? rider;

  @override
  ConsumerState<_ArrivedView> createState() => _ArrivedViewState();
}

class _ArrivedViewState extends ConsumerState<_ArrivedView> {
  String _pin = '';
  String? _error;
  bool _checking = false;
  bool _locked = false;
  int _waited = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _waited++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
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
    final name = widget.rider?.firstName ?? '';
    final me = ref.watch(lastPositionProvider);
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('12')),
      heading: IyoPageHeading(title: t.arrivedTitle(name), subtitle: widget.ride.pickup.name),
      footer: [
        IyoButton(
          label: t.startRide,
          disabled: _pin.length != 4 || _locked,
          loading: _checking,
          onPressed: _start,
        ),
        IyoButton(
          label: t.cancelRide,
          variant: IyoButtonVariant.ghost,
          onPressed: () => _cancelSheet(context, ref, widget.ride.id),
        ),
      ],
      children: [
        DriverMap(
          me: me.point,
          heading: me.heading,
          pickup: widget.ride.pickup.location,
          height: 180,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.waitTime(formatDuration(_waited))),
        ),
        _RiderCard(ride: widget.ride, rider: widget.rider),
        IyoPinInput(
          label: t.pinLabel(name),
          value: _pin,
          onChanged:
              (v) => setState(() {
                _pin = v;
                _error = null;
              }),
          error: _error,
          helper: ref.watch(backendProvider).isDemo ? t.pinDemoHint(demoPin) : null,
        ),
      ],
    );
  }
}

/// D13 — Live ride navigation (Figma 2005:51527).
class _LiveView extends ConsumerStatefulWidget {
  const _LiveView({required this.ride, required this.rider});

  final Ride ride;
  final Counterpart? rider;

  @override
  ConsumerState<_LiveView> createState() => _LiveViewState();
}

class _LiveViewState extends ConsumerState<_LiveView> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ride = widget.ride;
    final me = ref.watch(lastPositionProvider);
    final left = demoRoute(me.point, ride.dropoff.location!);
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('13')),
      heading: IyoPageHeading(
        title: t.liveTitle(ride.dropoff.name),
        subtitle: t.liveSubtitle(
          '${(left.durationSeconds / 60).ceil()}',
          formatDistance(left.distanceMeters),
        ),
      ),
      footer: [
        IyoButton(
          label: t.completeRide,
          loading: _busy,
          onPressed: () async {
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
        DriverMap(
          me: me.point,
          heading: me.heading,
          destination: ride.dropoff.location,
          height: 300,
        ),
        _RiderCard(ride: ride, rider: widget.rider),
        Row(
          children: [
            Expanded(
              child: IyoButton(
                label: t.navigate,
                icon: LucideIcons.navigation,
                variant: IyoButtonVariant.secondary,
                size: IyoButtonSize.sm,
                onPressed: () => _navigateTo(ride.dropoff.location!),
              ),
            ),
            const SizedBox(width: IyoSpacing.sm),
            Expanded(
              child: IyoButton(
                label: t.safety,
                icon: LucideIcons.shieldCheck,
                variant: IyoButtonVariant.soft,
                size: IyoButtonSize.sm,
                onPressed: () => showDriverSafetySheet(context, ref, ride.id),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// D14 — Ride complete and earnings (Figma 2005:51588).
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
