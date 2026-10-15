import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../sample/sample_data.dart';
import '../widgets/rider_widgets.dart';

enum _Service { ride, rent }

/// RIDER · 01 — Home tab (Figma 2005:50127).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _service = _Service.ride;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      inTabs: true,
      header: IyoAppHeader(flowLabel: t.flowRider('01')),
      heading: IyoPageHeading(
        title: t.homeGreeting(Sample.riderFirstName),
        subtitle: t.homeYouAreAt(Sample.currentPlace),
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
        const PickupMap(height: 218),
        IyoButton(
          label: t.whereTo,
          icon: LucideIcons.search,
          iconSize: 11,
          mirrorIcon: true,
          onPressed: () => context.push('/plan'),
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.house,
              iconWellTone: IyoIconWellTone.none,
              title: t.savedHome,
              subtitle: Sample.homeAddress,
              showChevron: false,
              onPressed: () => context.push('/plan'),
            ),
            IyoListRow(
              icon: LucideIcons.clock3,
              iconWellTone: IyoIconWellTone.none,
              title: Sample.recentPlace,
              subtitle: t.recentDestination(Sample.recentArea),
              showChevron: false,
              onPressed: () => context.push('/plan'),
            ),
          ],
        ),
        Footnote(t.nearbyRides(Sample.nearbyFrom, '3')),
      ],
    );
  }
}

/// RIDER · 02 — Plan your ride (Figma 2005:50194).
class PlanRideScreen extends StatelessWidget {
  const PlanRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('02')),
      heading: IyoPageHeading(title: t.planTitle, subtitle: t.planSubtitle),
      footer: [IyoButton(label: t.confirmRoute, onPressed: () => context.push('/trip/arriving'))],
      children: [
        IyoTextField(
          label: t.fieldPickup,
          initialValue: Sample.currentPlace,
          helper: '${t.currentLocation} · ${t.editPickup}',
        ),
        IyoTextField(
          label: t.fieldDestination,
          initialValue: Sample.destination,
          highlighted: true,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.whenWho, trailingIcon: LucideIcons.chevronDown),
        ),
        const IyoListRow(
          icon: LucideIcons.trainFront,
          title: Sample.destination,
          subtitle: Sample.destinationAddress,
          verticalPadding: 0,
          trailing: IyoIcon(LucideIcons.check, size: IyoSizes.iconSmall),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const RouteMap(height: 238),
            const SizedBox(height: 14),
            Footnote(t.routeSummary(Sample.tripDistance, Sample.tripMinutes)),
          ],
        ),
      ],
    );
  }
}

/// Driver card used on the trip screens (DriverInfoCard).
class _DriverCard extends StatelessWidget {
  const _DriverCard();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoPersonInfoCard(
      name: Sample.driverFullName,
      meta: t.ratingTrips(Sample.driverRating, Sample.driverTrips),
      detail: Sample.vehicle(context),
      onCall: () {},
      callLabel: t.callPerson(Sample.driverFirstName),
    );
  }
}

class _TripTiles extends StatelessWidget {
  const _TripTiles();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoActionTileRow(
      children: [
        IyoActionTile(
          icon: LucideIcons.messageCircle,
          label: t.tileMessage,
          onPressed: () => context.push('/trip/chat'),
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

/// RIDER · 05 — Driver on the way, pickup PIN (Figma 2005:50366).
class DriverArrivingScreen extends StatelessWidget {
  const DriverArrivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('05')),
      heading: IyoPageHeading(
        title: t.arrivingTitle(Sample.driverFirstName),
        subtitle: t.arrivingSubtitle(Sample.etaMinutes, Sample.etaDistance),
      ),
      footer: [
        IyoButton(
          label: t.viewPickupDetails,
          variant: IyoButtonVariant.secondary,
          onPressed: () => context.push('/trip/live'),
        ),
      ],
      children: [
        const RouteMap(height: 256),
        const _DriverCard(),
        IyoCard(
          tone: IyoCardTone.accent,
          children: [
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.pickupPin(Sample.pin))),
            IyoText(
              t.pinCardBody(Sample.pickupShort, Sample.driverFirstName),
              color: IyoPalette.charcoal,
            ),
          ],
        ),
        const _TripTiles(),
        Footnote('${t.checkPlate}\n${t.standardFare(Sample.fare)}'),
      ],
    );
  }
}

/// RIDER · 06 — Live trip (Figma 2005:50425).
class OnYourWayScreen extends StatelessWidget {
  const OnYourWayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('06')),
      heading: IyoPageHeading(
        title: t.onWayTitle,
        subtitle: t.arriveAt(Sample.destination, Sample.arriveTime),
      ),
      children: [
        const RouteMap(height: 316),
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.timeLeft(Sample.minutesLeft, Sample.distanceLeft)),
        ),
        const _DriverCard(),
        const _TripTiles(),
        IyoCard(
          onPressed: () => context.push('/trip/complete'),
          children: [
            IyoListRow(
              icon: LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.none,
              title: Sample.destination,
              titleVariant: IyoTextVariant.listTitle,
              subtitle: Sample.destinationDetail(context),
            ),
            Footnote(t.tripFooter(Sample.fare, Sample.paymentMethod, Sample.tripId)),
          ],
        ),
      ],
    );
  }
}

/// RIDER · 07 — Arrived: receipt and rating (Figma 2005:50486).
class TripCompleteScreen extends StatefulWidget {
  const TripCompleteScreen({super.key});

  @override
  State<TripCompleteScreen> createState() => _TripCompleteScreenState();
}

class _TripCompleteScreenState extends State<TripCompleteScreen> {
  int _stars = 5;
  int _tip = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget line(String label, String value) => Row(
      children: [
        Expanded(child: IyoText(label, color: IyoPalette.charcoal)),
        IyoText(value, variant: IyoTextVariant.bodyStrong),
      ],
    );
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRider('07')),
      heading: IyoPageHeading(title: t.arrivedTitle, subtitle: t.arrivedSubtitle),
      footer: [IyoButton(label: t.submitRating, onPressed: () => context.go('/home'))],
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
                IyoText(Sample.fare, variant: IyoTextVariant.amountHero),
                const SizedBox(height: 17),
                line(t.rideFare, Sample.rideFare),
                const SizedBox(height: 12),
                line(t.bookingFee, Sample.bookingFee),
                const SizedBox(height: 12),
                Footnote(t.receiptSent(Sample.paymentMethod)),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Footnote('${Sample.pickupShort} → ${Sample.destination}\n${Sample.tripDate}'),
            const SizedBox(height: 14),
            const _DriverCard(),
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
              options: [t.noTip, ...Sample.tipAmounts],
              selected: _tip,
              onChanged: (v) => setState(() => _tip = v),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chat with the driver (Figma 2025:342).
class TripChatScreen extends StatelessWidget {
  const TripChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.chatWith(Sample.driverFirstName),
        subtitle: t.chatSubtitle(Sample.rideId, Sample.pickupShort),
        onBack: context.pop,
      ),
      children: [
        IyoCard(
          children: [
            const Row(
              children: [
                IyoAvatar(name: Sample.driverFullName),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IyoText(Sample.driverFullName, variant: IyoTextVariant.heading),
                      IyoText(
                        '${Sample.vehicleShort} · ★ ${Sample.driverRating}',
                        variant: IyoTextVariant.caption,
                        color: IyoPalette.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IyoBadge(t.arrivingIn(Sample.etaMinutes)),
            ),
          ],
        ),
        IyoText(
          t.privacyNote,
          variant: IyoTextVariant.micro,
          color: IyoPalette.textSecondary,
          align: TextAlign.center,
        ),
        for (final line in driverChat)
          IyoChatBubble(
            message: IyoChatMessage(
              id: line.time + line.en,
              body: tr(context, line.en, line.fr),
              mine: line.mine,
              meta: line.read ? '${line.time} · ${t.read}' : line.time,
            ),
          ),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: IyoButton(
                    label: t.imHere,
                    variant: IyoButtonVariant.secondary,
                    size: IyoButtonSize.sm,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: IyoSpacing.sm),
                Expanded(
                  child: IyoButton(
                    label: t.callDriver,
                    icon: LucideIcons.phone,
                    variant: IyoButtonVariant.secondary,
                    size: IyoButtonSize.sm,
                    onPressed: () {},
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
          onSend: (_) {},
        ),
      ],
    );
  }
}

/// No drivers available (Figma 2025:438).
class NoDriversScreen extends StatelessWidget {
  const NoDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.noDriversTitle,
        subtitle: t.noDriversSubtitle(Sample.pickupArea),
        onBack: context.pop,
      ),
      footer: [
        IyoButton(
          label: t.tryAgain,
          icon: LucideIcons.rotateCw,
          onPressed: () => context.push('/trip/arriving'),
        ),
        IyoButton(
          label: t.changePickup,
          variant: IyoButtonVariant.secondary,
          onPressed: () => context.push('/plan'),
        ),
      ],
      children: [
        const PickupMap(height: 222),
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
            const IyoText(Sample.pickupShort, variant: IyoTextVariant.listTitle),
            Footnote(t.toPlace(Sample.destination)),
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
