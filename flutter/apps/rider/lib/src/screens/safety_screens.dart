import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../sample/sample_data.dart';
import '../state/location.dart';
import '../widgets/rider_widgets.dart';
import 'trip_view.dart';

/// The rider's ride that is still under way, if any (Safety tab, no ride id in the route).
final openRideProvider = FutureProvider.autoDispose<Ride?>(
  (ref) => ref.watch(backendProvider).openRide(),
);

final _rideDriverProvider = FutureProvider.autoDispose.family<Counterpart?, String>(
  (ref, rideId) => ref.watch(backendProvider).driverFor(rideId),
);

bool _isUnderWay(RideStatus s) => const {
  RideStatus.driverAssigned,
  RideStatus.driverArriving,
  RideStatus.driverArrived,
  RideStatus.inProgress,
}.contains(s);

EmergencyNumber _police(List<EmergencyNumber> numbers) =>
    numbers.firstWhere((n) => n.service == 'police', orElse: () => numbers.first);

Future<void> dialEmergency(String number) => launchUrl(Uri(scheme: 'tel', path: number));

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

/// Creates a share token for [rideId] (expires server-side) and opens the system share sheet.
Future<void> shareLiveTrip(BuildContext context, WidgetRef ref, String rideId) async {
  final t = context.t;
  try {
    final share = await ref.read(backendProvider).shareTrip(rideId);
    await SharePlus.instance.share(
      ShareParams(
        text: t.shareTripText(formatTime(share.expiresAt), share.url),
        subject: t.shareTripSubject,
      ),
    );
  } on BackendException {
    if (context.mounted) _snack(context, t.shareFailed);
  }
}

/// RIDER · SAFETY — Safety and security alert (Figma 2005:50537). Also the Safety tab root.
/// Live: raises a safety alert (trip snapshot + location, server-side), texts the trusted
/// contacts that have alerts on, and opens the alert-sent screen.
class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key, this.inTabs = false, this.rideId, this.preview = false});

  final bool inTabs;

  /// The trip the alert is about; the open ride is used when null.
  final String? rideId;

  /// Figma sample content (design index, snapshots).
  final bool preview;

  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen> {
  bool _sampleSelected = true;
  final _note = TextEditingController();
  final _notify = <String, bool>{};
  bool _sending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_note.text.isEmpty) _note.text = context.t.defaultAlertMessage;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Ride? _ride() {
    final ride =
        widget.rideId != null
            ? ref.watch(rideProvider(widget.rideId!)).value
            : ref.watch(openRideProvider).value;
    return ride != null && _isUnderWay(ride.status) ? ride : null;
  }

  Future<void> _toggle(TrustedContact c, bool notify) async {
    setState(() => _notify[c.id] = notify);
    try {
      await ref.read(backendProvider).setNotifyOnAlert(c.id, notify: notify);
      ref.invalidate(trustedContactsProvider);
    } on BackendException {
      if (mounted) setState(() => _notify.remove(c.id));
    }
  }

  Future<void> _send(
    Ride? ride,
    GeoPoint? here,
    List<TrustedContact> contacts,
    String police,
  ) async {
    final t = context.t;
    setState(() => _sending = true);
    final backend = ref.read(backendProvider);
    try {
      final alert = await backend.raiseAlert(
        rideId: ride?.id,
        at: here,
        reason: 'rider_sos',
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      var notified = 0;
      try {
        notified = await backend.notifyTrustedContacts(alert.id);
      } on BackendException {
        // The alert itself is recorded and seen by the safety team; texting can be retried by them.
      }
      if (!mounted) return;
      final names = [
        for (final c in contacts)
          if (_notify[c.id] ?? c.notifyOnAlert) c.firstName,
      ];
      await context.push(
        '/safety-sent',
        extra: AlertSentArgs(
          alert: alert,
          notified: notified,
          contactNames: names.take(notified).toList(),
          rideId: ride?.id,
          emergencyNumber: police,
        ),
      );
    } on BackendException {
      if (mounted) _snack(context, t.alertFailed(police));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preview) return _buildSample(context);
    final t = context.t;
    final ride = _ride();
    final driver = ride == null ? null : ref.watch(_rideDriverProvider(ride.id)).value;
    final contacts = ref.watch(trustedContactsProvider);
    final numbers = ref.watch(emergencyNumbersProvider).value ?? defaultEmergencyNumbers;
    final police = _police(numbers).number;
    final here = switch (ref.watch(locationProvider).value) {
      LocationFound(:final point) => point,
      _ => null,
    };
    final list = contacts.value ?? const <TrustedContact>[];

    return IyoScreen(
      inTabs: widget.inTabs,
      header: IyoAppHeader(flowLabel: t.flowSafety),
      heading: IyoPageHeading(
        title: t.safetyTitle,
        subtitle: t.safetySubtitle,
        onBack: widget.inTabs ? null : context.pop,
      ),
      footer: [
        IyoButton(
          label: t.sendAlert,
          variant: IyoButtonVariant.danger,
          loading: _sending,
          onPressed: _sending ? null : () => _send(ride, here, list, police),
        ),
        Footnote(t.sendAlertFooter, align: TextAlign.center),
      ],
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child:
              ride == null
                  ? IyoBadge(t.noActiveTrip, tone: IyoBadgeTone.neutral)
                  : IyoBadge(t.activeTrip(tripRefOf(ride.id))),
        ),
        IyoCard(
          onPressed: () => dialEmergency(police),
          children: [
            IconTitleRow(
              icon: LucideIcons.phoneCall,
              title: t.emergencyHelp(police),
              subtitle: t.emergencyHelpBody,
            ),
            const SizedBox(height: 2),
            IyoText(t.alertNotEmergency, variant: IyoTextVariant.caption, color: IyoPalette.danger),
          ],
        ),
        _EmergencyNumbers(numbers: numbers),
        IyoListRow(
          icon: LucideIcons.share2,
          title: t.shareLiveTrip,
          titleVariant: IyoTextVariant.listTitle,
          subtitle: ride == null ? t.shareNeedsTrip : t.shareLiveTripBody,
          verticalPadding: 0,
          showChevron: false,
          onPressed: ride == null ? null : () => shareLiveTrip(context, ref, ride.id),
        ),
        IyoFormField(
          label: t.contactsToNotify,
          helper: t.trustedContactHelper,
          child: _Outlined(
            children: [
              if (contacts.isLoading && list.isEmpty)
                const IyoSkeletonRow()
              else if (list.isEmpty)
                InlineLink(
                  lead: t.noContactsYet,
                  link: t.addContactLink,
                  onPressed: () => context.push('/trusted-contacts'),
                )
              else
                for (final c in list)
                  IyoCheckbox(
                    value: _notify[c.id] ?? c.notifyOnAlert,
                    onChanged: (v) => _toggle(c, v),
                    label: '${c.name} · ${formatPhone(c.phone)}',
                    labelVariant: IyoTextVariant.input,
                  ),
            ],
          ),
        ),
        IyoTextField(label: t.messagePreview, controller: _note, multiline: true),
        Footnote(
          [
            if (driver != null)
              [
                driver.fullName ?? driver.firstName,
                if (driver.vehicle != null)
                  '${driver.vehicle!.make} ${driver.vehicle!.model} · ${driver.vehicle!.plate}',
              ].join(' · '),
            if (here != null)
              t.currentLocationAt('${here.lat.toStringAsFixed(5)}, ${here.lng.toStringAsFixed(5)}')
            else
              t.locationUnknown,
          ].join('\n'),
        ),
      ],
    );
  }

  Widget _buildSample(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      inTabs: widget.inTabs,
      header: IyoAppHeader(flowLabel: t.flowSafety),
      heading: IyoPageHeading(title: t.safetyTitle, subtitle: t.safetySubtitle),
      footer: [
        IyoButton(
          label: t.sendAlert,
          variant: IyoButtonVariant.danger,
          onPressed: () => context.push('/design/safety-sent'),
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
          child: _Outlined(
            children: [
              IyoCheckbox(
                value: _sampleSelected,
                onChanged: (v) => setState(() => _sampleSelected = v),
                label: '${Sample.trustedContactName} · ${Sample.trustedContactPhone}',
                labelVariant: IyoTextVariant.input,
              ),
            ],
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

/// Input-style box around the contact checkboxes (Figma: one 48 px field per contact).
class _Outlined extends StatelessWidget {
  const _Outlined({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: IyoSizes.inputMinHeight),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(IyoRadii.md),
      border: Border.all(color: IyoPalette.border),
    ),
    alignment: Alignment.centerLeft,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: children),
  );
}

/// Police / fire / ambulance quick-dial chips (numbers from app_config, placeholders to verify).
class _EmergencyNumbers extends StatelessWidget {
  const _EmergencyNumbers({required this.numbers});

  final List<EmergencyNumber> numbers;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    String label(EmergencyNumber n) => switch (n.service) {
      'police' => t.emergencyPolice,
      'fire' => t.emergencyFire,
      'ambulance' => t.emergencyAmbulance,
      _ => n.service,
    };
    return Row(
      spacing: 8,
      children: [
        for (final n in numbers)
          Expanded(
            child: IyoButton(
              label: '${label(n)} · ${n.number}',
              size: IyoButtonSize.sm,
              variant: IyoButtonVariant.secondary,
              onPressed: () => dialEmergency(n.number),
            ),
          ),
      ],
    );
  }
}

/// What the alert-sent screen shows about the alert just raised.
class AlertSentArgs {
  const AlertSentArgs({
    required this.alert,
    required this.notified,
    required this.contactNames,
    required this.emergencyNumber,
    this.rideId,
  });

  final SafetyAlert alert;
  final int notified;
  final List<String> contactNames;
  final String emergencyNumber;
  final String? rideId;
}

/// RIDER · SAFETY SENT — Alert sent (Figma 2005:50584).
class AlertSentScreen extends StatelessWidget {
  const AlertSentScreen({super.key, this.args});

  /// Null: Figma sample content.
  final AlertSentArgs? args;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final a = args;
    final number = a?.emergencyNumber ?? Sample.emergencyNumber;
    final time = a == null ? Sample.alertTime : formatTime(a.alert.createdAt);
    final rideId = a?.rideId;
    final String contactTitle;
    final String contactBody;
    if (a == null) {
      contactTitle = t.contactNotified(Sample.trustedContactName.split(' ').first);
      contactBody = t.contactNotifiedBody;
    } else if (a.notified == 0) {
      contactTitle = t.noContactNotified;
      contactBody = t.noContactNotifiedBody;
    } else {
      contactTitle =
          a.notified == 1 && a.contactNames.isNotEmpty
              ? t.contactNotified(a.contactNames.first)
              : t.contactsNotifiedCount('${a.notified}');
      contactBody = t.contactNotifiedBody;
    }
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowSafetySent),
      heading: IyoPageHeading(title: t.alertSentTitle, subtitle: t.alertSentSubtitle),
      footer: [
        IyoButton(
          label: t.callEmergency(number),
          variant: IyoButtonVariant.danger,
          onPressed: () => dialEmergency(number),
        ),
        IyoButton(
          label: a == null || rideId != null ? t.returnToTrip : t.backHome,
          variant: IyoButtonVariant.secondary,
          onPressed:
              () => context.go(
                a == null
                    ? '/trip/live'
                    : rideId != null
                    ? '/ride/$rideId'
                    : '/home',
              ),
        ),
      ],
      children: [
        IyoCard(
          tone: IyoCardTone.danger,
          children: [
            IconTitleRow(
              icon: LucideIcons.shieldAlert,
              iconColor: IyoPalette.danger,
              title: '${t.alertActive}\n${t.sentTodayAt(time)}',
              titleVariant: IyoTextVariant.subheading,
            ),
          ],
        ),
        const RouteMap(height: 148),
        IyoCard(
          children: [
            IconTitleRow(
              icon: a != null && a.notified == 0 ? LucideIcons.userX : LucideIcons.checkCheck,
              title: contactTitle,
              subtitle: contactBody,
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
            if (a == null || rideId != null) ...[
              IyoBadge(t.liveSharingOn, tone: IyoBadgeTone.success),
              const SizedBox(height: 14),
            ],
            Footnote(t.alertSentHint(number)),
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
    this.onPressed,
  });

  final String name;
  final String detail;
  final IyoBadge badge;
  final Widget footer;
  final bool divider;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IyoCard(
      onPressed: onPressed ?? () {},
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
        footer,
      ],
    );
  }
}

const _maxContacts = 5;

/// Trusted contacts (Figma 2025:529). Live: up to 5 contacts, alerts on/off per contact.
/// The Figma "Verified / Invitation pending" states have no backing yet (contacts are texted,
/// not invited), so the live badge shows whether alerts are on.
class TrustedContactsScreen extends ConsumerWidget {
  const TrustedContactsScreen({super.key, this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final numbers = preview ? defaultEmergencyNumbers : ref.watch(emergencyNumbersProvider).value;
    final police = _police(numbers ?? defaultEmergencyNumbers).number;
    final contacts = preview ? null : ref.watch(trustedContactsProvider);
    final list = contacts?.value ?? const <TrustedContact>[];
    final full = list.length >= _maxContacts;

    Future<void> remove(TrustedContact c) async {
      final ok = await showDialog<bool>(
        context: context,
        builder:
            (d) => AlertDialog(
              title: Text(t.removeContactTitle(c.firstName)),
              content: Text(t.removeContactBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(d, false),
                  child: Text(CommonLocalizations.of(context).actionCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(d, true),
                  child: Text(t.removeContact, style: const TextStyle(color: IyoPalette.danger)),
                ),
              ],
            ),
      );
      if (ok != true) return;
      await ref.read(backendProvider).removeTrustedContact(c.id);
      ref.invalidate(trustedContactsProvider);
    }

    Future<void> toggle(TrustedContact c, bool v) async {
      await ref.read(backendProvider).setNotifyOnAlert(c.id, notify: v);
      ref.invalidate(trustedContactsProvider);
    }

    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowRiderPlain),
      heading: IyoPageHeading(title: t.tcTitle, subtitle: t.tcSubtitle, onBack: context.pop),
      footer: [
        IyoButton(
          label: t.addTrustedContact,
          icon: LucideIcons.plus,
          disabled: full,
          onPressed: preview || full ? null : () => showAddContactSheet(context, ref),
        ),
        if (full) Footnote(t.contactLimit('$_maxContacts'), align: TextAlign.center),
      ],
      children: [
        IyoCard(
          children: [
            IyoText(t.shareJourney, variant: IyoTextVariant.listTitle),
            IyoText(t.shareJourneyBody1, color: IyoPalette.textSecondary),
            IyoText(t.shareJourneyBody2, color: IyoPalette.textSecondary),
          ],
        ),
        if (preview) ...[
          SectionTitle(t.yourContacts('2', '$_maxContacts')),
          _ContactCard(
            name: Sample.trustedContactName,
            detail: '${tr(context, 'Sister', 'Sœur')} · ${Sample.trustedContactPhone}',
            badge: IyoBadge(t.statusVerified, tone: IyoBadgeTone.success),
            footer: IyoText(
              t.shareTripsWith(Sample.trustedContactName.split(' ').first),
              variant: IyoTextVariant.captionMedium,
            ),
            divider: true,
          ),
          _ContactCard(
            name: 'Samuel Ekane',
            detail: '${tr(context, 'Friend', 'Ami')} · +237 6 99 00 33 52',
            badge: IyoBadge(t.invitationPending),
            footer: IyoText(t.resendInvitation, variant: IyoTextVariant.captionMedium),
          ),
        ] else if (contacts!.isLoading && list.isEmpty)
          const IyoSkeletonRow()
        else if (list.isEmpty)
          IyoEmptyState(
            icon: LucideIcons.usersRound,
            title: t.contactsEmptyTitle,
            message: t.contactsEmptyBody,
          )
        else ...[
          SectionTitle(t.yourContacts('${list.length}', '$_maxContacts')),
          for (final c in list)
            _ContactCard(
              name: c.name,
              detail: [
                if (c.relationship != null && c.relationship!.isNotEmpty) c.relationship!,
                formatPhone(c.phone),
              ].join(' · '),
              badge:
                  c.notifyOnAlert
                      ? IyoBadge(t.alertsOn, tone: IyoBadgeTone.success)
                      : IyoBadge(t.alertsOff, tone: IyoBadgeTone.neutral),
              divider: true,
              onPressed: () => toggle(c, !c.notifyOnAlert),
              footer: Row(
                children: [
                  Expanded(
                    child: IyoCheckbox(
                      value: c.notifyOnAlert,
                      onChanged: (v) => toggle(c, v),
                      label: t.textOnAlert(c.firstName),
                      labelVariant: IyoTextVariant.captionMedium,
                    ),
                  ),
                  IyoPressable(
                    onPressed: () => remove(c),
                    child: IyoText(
                      t.removeContact,
                      variant: IyoTextVariant.captionMedium,
                      color: IyoPalette.danger,
                    ),
                  ),
                ],
              ),
            ),
        ],
        IyoCard(
          children: [
            IyoText(t.inControl, variant: IyoTextVariant.cardTitle),
            IyoText(t.inControlBody, color: IyoPalette.textSecondary),
          ],
        ),
        Footnote(t.tcFooter(police)),
      ],
    );
  }
}

/// Add a trusted contact: name, mobile (any African country), optional relationship.
Future<void> showAddContactSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: IyoPalette.white,
  barrierColor: IyoPalette.overlay,
  builder: (_) => const _AddContactSheet(),
);

class _AddContactSheet extends ConsumerStatefulWidget {
  const _AddContactSheet();

  @override
  ConsumerState<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends ConsumerState<_AddContactSheet> {
  String _name = '', _relationship = '';
  ParsedPhone? _phone;
  String? _nameError, _phoneError, _error;
  bool _saving = false;

  Future<void> _save() async {
    final t = context.t;
    final common = CommonLocalizations.of(context);
    final e164 = (_phone?.isValid ?? false ? _phone!.e164 : null);
    setState(() {
      _nameError = _name.trim().isEmpty ? common.validationRequired : null;
      _phoneError = e164 == null ? common.validationPhoneInvalid : null;
      _error = null;
    });
    if (_nameError != null || _phoneError != null) return;
    final existing = ref.read(trustedContactsProvider).value ?? const <TrustedContact>[];
    if (existing.any((c) => c.phone == e164)) {
      setState(() => _error = t.contactDuplicate);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(backendProvider)
          .addTrustedContact(
            name: _name.trim(),
            phoneE164: e164!,
            relationship: _relationship.trim().isEmpty ? null : _relationship.trim(),
          );
      ref.invalidate(trustedContactsProvider);
      if (mounted) Navigator.pop(context);
    } on BackendException catch (e) {
      setState(
        () =>
            _error = switch (e.code) {
              'trusted_contacts_limit_reached' => t.contactLimit('$_maxContacts'),
              'invalid_request' || 'duplicate' => t.contactDuplicate,
              _ => common.errorGeneric,
            },
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            IyoText(t.addTrustedContact, variant: IyoTextVariant.cardTitle),
            IyoTextField(
              label: t.contactName,
              error: _nameError,
              onChanged: (v) => _name = v,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
            ),
            IyoPhoneField(label: t.contactPhone, error: _phoneError, onChanged: (v) => _phone = v),
            IyoTextField(
              label: t.contactRelationship,
              placeholder: t.contactRelationshipHint,
              onChanged: (v) => _relationship = v,
            ),
            if (_error != null) IyoText(_error!, color: IyoPalette.danger),
            IyoButton(label: t.saveContact, loading: _saving, onPressed: _saving ? null : _save),
          ],
        ),
      ),
    );
  }
}
