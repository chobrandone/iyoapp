import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../locale_controller.dart';
import '../sample/sample_data.dart';
import '../widgets/rider_widgets.dart';

enum _Filter { all, unread }

/// Notifications (Figma 2025:289), inside the Account tab.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  var _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget card({
      String? badge,
      required String title,
      required String body,
      required String meta,
      bool chevron = true,
    }) => IyoCard(
      onPressed: chevron ? () {} : null,
      children: [
        if (badge != null) Align(alignment: Alignment.centerLeft, child: IyoBadge(badge)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IyoListRow(
              title: title,
              titleVariant: IyoTextVariant.listTitle,
              subtitle: body,
              inlineChevron: chevron,
              verticalPadding: 0,
            ),
            const SizedBox(height: 10),
            IyoText(meta, variant: IyoTextVariant.micro, color: IyoPalette.textSecondary),
          ],
        ),
      ],
    );

    return IyoScreen(
      inTabs: true,
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.notificationsTitle,
        subtitle: t.notificationsSubtitle,
        compact: true,
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IyoSegmentedTabs<_Filter>(
              value: _filter,
              onChanged: (v) => setState(() => _filter = v),
              options: [
                IyoSegment(value: _Filter.all, label: t.filterAll),
                IyoSegment(value: _Filter.unread, label: t.filterUnread),
              ],
            ),
            IyoPressable(
              onPressed: () {},
              semanticLabel: t.markAllRead,
              minHitSize: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: IyoText(t.markAllRead, variant: IyoTextVariant.captionMedium),
              ),
            ),
          ],
        ),
        SectionTitle(t.today),
        card(
          badge: t.badgeNew,
          title: tr(context, 'Your receipt is ready', 'Votre reçu est prêt'),
          body: tr(
            context,
            'Ride to ${Sample.destination} · 3 600 FCFA paid',
            'Course vers ${Sample.destination} · 3 600 FCFA payés',
          ),
          meta: tr(context, '09:22 · 19 min ago', 'il y a 19 min · 09:22'),
        ),
        card(
          badge: t.badgeRentalUpdate,
          title: tr(
            context,
            'Douala airport pickup confirmed',
            "Retrait à l'aéroport de Douala confirmé",
          ),
          body: tr(context, '17/10, 10:00 · Arrivals hall', '17/10, 10:00 · Hall des arrivées'),
          meta: tr(context, '08:15 · Booking RN-2048', '08:15 · Réservation RN-2048'),
        ),
        if (_filter == _Filter.all) ...[
          SectionTitle(t.yesterday),
          card(
            title: tr(context, 'Payment received', 'Paiement reçu'),
            body: '105 000 FCFA · Toyota RAV4, 17–20/10',
            meta: '13/10 · 16:32',
          ),
          card(
            title: tr(context, 'Trusted contact added', 'Contact de confiance ajouté'),
            body: tr(
              context,
              'Grâce can receive your shared trip links.',
              'Grâce peut recevoir vos liens de trajet.',
            ),
            meta: '13/10 · 12:10',
            chevron: false,
          ),
        ],
        Footnote(t.notificationsFooter),
      ],
    );
  }
}

enum _Activity { all, rides, rentals }

/// Ride and rental activity (Figma 2025:51), Activity tab.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  var _filter = _Activity.all;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget journey(String title, String fare, String meta, {bool completed = false}) => IyoCard(
      onPressed: () {},
      children: [
        IyoListRow(
          title: title,
          titleVariant: IyoTextVariant.listTitle,
          titleAside: fare,
          inlineChevron: true,
          subtitle: meta,
          verticalPadding: 0,
        ),
        if (completed)
          Align(
            alignment: Alignment.centerLeft,
            child: IyoBadge(t.statusCompleted, tone: IyoBadgeTone.success),
          ),
      ],
    );

    final showRentals = _filter != _Activity.rides;
    final showRides = _filter != _Activity.rentals;
    return IyoScreen(
      inTabs: true,
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(title: t.activityTitle, subtitle: t.activitySubtitle, compact: true),
      children: [
        IyoSegmentedTabs<_Activity>(
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
          options: [
            IyoSegment(value: _Activity.all, label: t.filterAll),
            IyoSegment(value: _Activity.rides, label: t.filterRides),
            IyoSegment(value: _Activity.rentals, label: t.filterRentals),
          ],
        ),
        if (showRentals) ...[
          SectionTitle(t.upcomingRental),
          IyoCard(
            onPressed: () {},
            children: [
              Row(
                children: [
                  // TODO(design): use the vehicle's own photo from rental_vehicles.image_paths.
                  Image.asset(
                    'assets/images/rental_car.png',
                    width: 86,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IyoText('Toyota RAV4', variant: IyoTextVariant.cardTitle),
                        Footnote(
                          tr(
                            context,
                            'Petrol · Automatic · 5 seats',
                            'Essence · Automatique · 5 places',
                          ),
                        ),
                        const SizedBox(height: 4),
                        IyoBadge(t.perDay(formatFcfa(35000))),
                      ],
                    ),
                  ),
                ],
              ),
              IyoListRow(
                title: '17–20/10 · 10:00',
                titleVariant: IyoTextVariant.listTitle,
                inlineChevron: true,
                subtitle: tr(
                  context,
                  'Douala airport (DLA) · Booking RN-2048',
                  'Aéroport de Douala (DLA) · Réservation RN-2048',
                ),
                verticalPadding: 0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IyoBadge(t.statusConfirmed, tone: IyoBadgeTone.success),
              ),
            ],
          ),
        ],
        if (showRides || showRentals) SectionTitle(t.recentJourneys),
        if (showRides) ...[
          journey(
            Sample.destination,
            formatFcfa(3600),
            '14/10 · 09:22 · ${tr(context, 'Ride', 'Course')} RD-1042',
            completed: true,
          ),
          journey(
            'Bonapriso',
            formatFcfa(2500),
            '12/10 · 18:45 · ${tr(context, 'Ride', 'Course')} RD-1031',
          ),
        ],
        if (showRentals)
          journey(
            'Toyota Corolla',
            formatFcfa(75000),
            tr(context, '3–5/10 · Akwa pickup · Rental', '3–5/10 · Retrait Akwa · Location'),
          ),
        Footnote(t.activityFooter),
      ],
    );
  }
}

/// Account tab root. The Figma account frame (2025:2) was not attached, so this is a plain menu
/// built from the design-system rows until that frame is implemented.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final common = CommonLocalizations.of(context);
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    return IyoScreen(
      inTabs: true,
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(title: t.accountTitle, subtitle: t.accountSubtitle),
      children: [
        IyoCard(
          children: [
            IyoListRow(
              leading: const IyoAvatar(name: Sample.riderFullName, size: 44),
              title: Sample.riderFullName,
              titleVariant: IyoTextVariant.listTitle,
              subtitle: Sample.riderPhoneDisplay,
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoListRow(
              icon: LucideIcons.bell,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuNotifications,
              onPressed: () => context.push('/account/notifications'),
            ),
            IyoListRow(
              icon: LucideIcons.wallet,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuWallet,
              onPressed: () => context.push('/wallet'),
            ),
            IyoListRow(
              icon: LucideIcons.mapPin,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuSavedPlaces,
              onPressed: () => context.push('/saved-places'),
            ),
            IyoListRow(
              icon: LucideIcons.users,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuTrustedContacts,
              onPressed: () => context.push('/trusted-contacts'),
            ),
            IyoListRow(
              icon: LucideIcons.headset,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuSupport,
              onPressed: () => context.push('/support'),
            ),
            IyoListRow(
              icon: LucideIcons.languages,
              iconWellTone: IyoIconWellTone.white,
              title: t.menuLanguage,
              subtitle: isFrench ? common.languageFr : common.languageEn,
              onPressed:
                  () => ref
                      .read(localeControllerProvider.notifier)
                      .set(Locale(isFrench ? 'en' : 'fr')),
            ),
          ],
        ),
        if (kDebugMode)
          IyoButton(
            label: t.menuScreens,
            variant: IyoButtonVariant.ghost,
            onPressed: () => context.push('/dev/screens'),
          ),
      ],
    );
  }
}

/// Saved places (Figma 2025:246).
class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    IyoListRow place(String title, String address) => IyoListRow(
      title: title,
      titleVariant: IyoTextVariant.listTitle,
      subtitle: address,
      inlineChevron: true,
      verticalPadding: 3,
      onPressed: () {},
    );
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(title: t.savedTitle, subtitle: t.savedSubtitle, onBack: context.pop),
      footer: [IyoButton(label: t.addPlace, icon: LucideIcons.plus, onPressed: () {})],
      children: [
        const PickupMap(height: 180),
        IyoCard(
          children: [
            place(t.savedHome, Sample.homeAddressFull),
            place(t.savedWork, Sample.workAddressFull),
          ],
        ),
        SectionTitle(t.otherFavourites),
        IyoCard(
          children: [
            place(Sample.destination, Sample.destinationAddress),
            place(
              tr(context, 'Douala International Airport', 'Aéroport international de Douala'),
              tr(context, 'Arrivals hall, Douala', 'Hall des arrivées, Douala'),
            ),
            place(tr(context, "Mum's place", 'Chez Maman'), '42 Rue Kotto, Makepe, Douala'),
          ],
        ),
        Footnote(t.savedFooter),
      ],
    );
  }
}

/// Wallet and payment methods (Figma 2025:156). Figma shows cards and Apple Pay; per the spec
/// the methods are MTN MoMo (default), Orange Money and cash.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    IyoListRow method(String title, String subtitle) => IyoListRow(
      title: title,
      titleVariant: IyoTextVariant.listTitle,
      subtitle: subtitle,
      inlineChevron: true,
      verticalPadding: 0,
      onPressed: () {},
    );
    IyoListRow payment(String title, String amount, String meta) => IyoListRow(
      title: title,
      titleVariant: IyoTextVariant.listTitle,
      titleAside: amount,
      subtitle: meta,
      verticalPadding: 0,
    );
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.walletTitle,
        subtitle: t.walletSubtitle,
        onBack: context.pop,
      ),
      footer: [IyoButton(label: t.addPaymentMethod, icon: LucideIcons.plus, onPressed: () {})],
      children: [
        IyoCard(
          children: [
            Footnote(t.rideCredit),
            IyoText(formatFcfa(2500), variant: IyoTextVariant.amount),
            Footnote(t.creditApplied),
          ],
        ),
        SectionTitle(t.paymentMethods),
        IyoCard(
          children: divided([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                method('MTN MoMo •••• 45 67', t.walletNumber(Sample.riderPhoneDisplay)),
                const SizedBox(height: 10),
                IyoBadge(t.badgeDefault),
              ],
            ),
            method('Orange Money •••• 22 33', t.walletNumber(formatPhone('699112233'))),
            method(t.cashMethod, t.cashBody),
          ]),
        ),
        SectionTitle(t.recentPayments),
        IyoCard(
          children: divided([
            payment(
              tr(context, 'Ride to ${Sample.destination}', 'Course vers ${Sample.destination}'),
              formatFcfa(3600),
              tr(context, '14/10 · Paid with MTN MoMo', '14/10 · Payé avec MTN MoMo'),
            ),
            payment(
              tr(context, 'Rental RN-2048', 'Location RN-2048'),
              formatFcfa(105000),
              tr(context, '13/10 · Booking payment', '13/10 · Paiement de la réservation'),
            ),
          ]),
        ),
        Footnote(t.walletFooter),
      ],
    );
  }
}

/// Help and support conversation (Figma 2025:485).
class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(
        title: t.supportTitle,
        subtitle: t.supportSubtitle(
          'SP-081',
          tr(context, 'Rental pickup question', 'Question sur un retrait de location'),
        ),
        onBack: context.pop,
      ),
      children: [
        IyoCard(
          children: [
            IyoText(t.supportAgent('Mireille'), variant: IyoTextVariant.listTitle),
            Footnote(t.repliesWithin),
            Align(
              alignment: Alignment.centerLeft,
              child: IyoBadge(t.conversationOpen, tone: IyoBadgeTone.success),
            ),
          ],
        ),
        IyoText(
          '${t.today} · 09:30',
          variant: IyoTextVariant.micro,
          color: IyoPalette.textSecondary,
          align: TextAlign.center,
        ),
        for (final line in supportChat)
          IyoChatBubble(
            message: IyoChatMessage(
              id: line.time + line.en,
              body: tr(context, line.en, line.fr),
              mine: line.mine,
              meta: line.read ? '${line.time} · ${t.read}' : line.time,
            ),
          ),
        Footnote(t.supportFooter(Sample.emergencyNumber)),
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
