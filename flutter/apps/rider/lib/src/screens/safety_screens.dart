import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../sample/sample_data.dart';
import '../widgets/rider_widgets.dart';

/// RIDER · SAFETY — Safety and security alert (Figma 2005:50537). Also the Safety tab root.
class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  bool _contactSelected = true;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      inTabs: widget.inTabs,
      header: IyoAppHeader(flowLabel: t.flowSafety),
      heading: IyoPageHeading(title: t.safetyTitle, subtitle: t.safetySubtitle),
      footer: [
        IyoButton(
          label: t.sendAlert,
          variant: IyoButtonVariant.danger,
          onPressed: () => context.push('/safety-sent'),
        ),
        Footnote(t.sendAlertFooter, align: TextAlign.center),
      ],
      children: [
        Align(alignment: Alignment.centerLeft, child: IyoBadge(t.activeTrip(Sample.tripId))),
        IyoCard(
          onPressed: () {},
          children: [
            IconTitleRow(
              icon: LucideIcons.phoneCall,
              title: t.emergencyHelp(Sample.emergencyNumber),
              subtitle: t.emergencyHelpBody,
            ),
            const SizedBox(height: 2),
            IyoText(t.alertNotEmergency, variant: IyoTextVariant.caption, color: IyoPalette.danger),
          ],
        ),
        IyoListRow(
          icon: LucideIcons.share2,
          title: t.shareLiveTrip,
          titleVariant: IyoTextVariant.listTitle,
          subtitle: t.shareLiveTripBody,
          verticalPadding: 0,
          showChevron: false,
          onPressed: () {},
        ),
        IyoFormField(
          label: t.trustedContactSelected,
          helper: t.trustedContactHelper,
          child: Container(
            constraints: const BoxConstraints(minHeight: IyoSizes.inputMinHeight),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IyoRadii.md),
              border: Border.all(color: IyoPalette.border),
            ),
            alignment: Alignment.centerLeft,
            child: IyoCheckbox(
              value: _contactSelected,
              onChanged: (v) => setState(() => _contactSelected = v),
              label: '${Sample.trustedContactName} · ${Sample.trustedContactPhone}',
              labelVariant: IyoTextVariant.input,
            ),
          ),
        ),
        IyoTextField(label: t.messagePreview, initialValue: t.defaultAlertMessage, multiline: true),
        Footnote(
          '${Sample.driverFullName} · ${Sample.vehicleShort}\n'
          '${t.currentLocationAt('${Sample.pickupArea}, Douala')}',
        ),
      ],
    );
  }
}

/// RIDER · SAFETY SENT — Alert sent (Figma 2005:50584).
class AlertSentScreen extends StatelessWidget {
  const AlertSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowSafetySent),
      heading: IyoPageHeading(title: t.alertSentTitle, subtitle: t.alertSentSubtitle),
      footer: [
        IyoButton(
          label: t.callEmergency(Sample.emergencyNumber),
          variant: IyoButtonVariant.danger,
          onPressed: () {},
        ),
        IyoButton(
          label: t.returnToTrip,
          variant: IyoButtonVariant.secondary,
          onPressed: () => context.go('/trip/live'),
        ),
      ],
      children: [
        IyoCard(
          tone: IyoCardTone.danger,
          children: [
            IconTitleRow(
              icon: LucideIcons.shieldAlert,
              iconColor: IyoPalette.danger,
              title: '${t.alertActive}\n${t.sentTodayAt(Sample.alertTime)}',
              titleVariant: IyoTextVariant.subheading,
            ),
          ],
        ),
        const RouteMap(height: 148),
        IyoCard(
          children: [
            IconTitleRow(
              icon: LucideIcons.checkCheck,
              title: t.contactNotified(Sample.trustedContactName.split(' ').first),
              subtitle: t.contactNotifiedBody,
            ),
            const SizedBox(height: 10),
            IconTitleRow(
              icon: LucideIcons.headset,
              title: t.safetyTeamNotified,
              subtitle: t.safetyTeamBody,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IyoBadge(t.liveSharingOn, tone: IyoBadgeTone.success),
            const SizedBox(height: 14),
            Footnote(t.alertSentHint(Sample.emergencyNumber)),
          ],
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.name,
    required this.detail,
    required this.badge,
    required this.footer,
    this.divider = false,
  });

  final String name;
  final String detail;
  final IyoBadge badge;
  final String footer;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return IyoCard(
      onPressed: () {},
      children: [
        IyoListRow(
          title: name,
          titleVariant: IyoTextVariant.listTitle,
          subtitle: detail,
          inlineChevron: true,
          verticalPadding: 0,
        ),
        Align(alignment: Alignment.centerLeft, child: badge),
        if (divider) const IyoDivider(),
        IyoText(footer, variant: IyoTextVariant.captionMedium),
      ],
    );
  }
}

/// Trusted contacts (Figma 2025:529).
class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(title: t.tcTitle, subtitle: t.tcSubtitle, onBack: context.pop),
      footer: [IyoButton(label: t.addTrustedContact, icon: LucideIcons.plus, onPressed: () {})],
      children: [
        IyoCard(
          children: [
            IyoText(t.shareJourney, variant: IyoTextVariant.listTitle),
            IyoText(t.shareJourneyBody1, color: IyoPalette.textSecondary),
            IyoText(t.shareJourneyBody2, color: IyoPalette.textSecondary),
          ],
        ),
        SectionTitle(t.yourContacts('2', '5')),
        _ContactCard(
          name: Sample.trustedContactName,
          detail: '${tr(context, 'Sister', 'Sœur')} · ${Sample.trustedContactPhone}',
          badge: IyoBadge(t.statusVerified, tone: IyoBadgeTone.success),
          footer: t.shareTripsWith(Sample.trustedContactName.split(' ').first),
          divider: true,
        ),
        _ContactCard(
          name: 'Samuel Ekane',
          detail: '${tr(context, 'Friend', 'Ami')} · +237 6 99 00 33 52',
          badge: IyoBadge(t.invitationPending),
          footer: t.resendInvitation,
        ),
        IyoCard(
          children: [
            IyoText(t.inControl, variant: IyoTextVariant.cardTitle),
            IyoText(t.inControlBody, color: IyoPalette.textSecondary),
          ],
        ),
        Footnote(t.tcFooter(Sample.emergencyNumber)),
      ],
    );
  }
}
