// Dev-only screen: strings here are internal sample data, intentionally not translated.
import 'package:flutter/material.dart';

import '../../iyo_ui.dart';

const _pickup = LatLng(4.0469, 9.6953); // Akwa
const _dropoff = LatLng(4.0283, 9.6931); // Bonapriso
const _car = LatLng(4.0452, 9.7005);
const _route = [_pickup, LatLng(4.0405, 9.6985), LatLng(4.0335, 9.6942), _dropoff];

const _tabs = [
  IyoTabItem(key: 'home', label: 'Home', icon: LucideIcons.house),
  IyoTabItem(key: 'activity', label: 'Activity', icon: LucideIcons.clock3),
  IyoTabItem(key: 'safety', label: 'Safety', icon: LucideIcons.shieldCheck, badge: true),
  IyoTabItem(key: 'account', label: 'Account', icon: LucideIcons.userRound),
];

const _messages = [
  IyoChatMessage(
    id: '1',
    body: "Bonjour Aïcha, j'arrive. Je m'arrête devant l'entrée principale.",
    mine: false,
    meta: '09:38',
  ),
  IyoChatMessage(
    id: '2',
    body: 'Merci ! Je suis devant la pharmacie, en robe bleue.',
    mine: true,
    meta: '09:39 · Lu',
  ),
];

/// Every iyo_ui widget in its main states, for side-by-side comparison with the Figma frames.
class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key, required this.flowLabel, this.badge, this.onBack});

  /// Flow label shown in the header, e.g. "RIDER · DEV".
  final String flowLabel;

  /// Header badge (the driver app shows "DRIVER").
  final String? badge;
  final VoidCallback? onBack;

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

enum _Service { ride, rent }

enum _View { all, unread }

class _ComponentGalleryState extends State<ComponentGallery> {
  var _service = _Service.ride;
  var _view = _View.all;
  String? _city = 'douala';
  var _otp = '48261';
  var _pin = '4826';
  var _online = true;
  var _push = false;
  var _tab = 'home';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IyoScreen(
            inTabs: true,
            header: IyoAppHeader(flowLabel: widget.flowLabel, badge: widget.badge),
            heading: IyoPageHeading(
              title: 'Components',
              subtitle: 'iyo_ui · compare with Figma frames',
              onBack: widget.onBack,
            ),
            children: [
              _section('Colours', [
                Wrap(
                  spacing: IyoSpacing.md,
                  runSpacing: IyoSpacing.md,
                  children: [
                    for (final e in IyoPalette.swatches.entries)
                      _Swatch(name: e.key, color: e.value),
                  ],
                ),
              ]),
              _section('Typography', const [
                IyoText('Your city.', variant: IyoTextVariant.hero),
                IyoText('Where to, Aïcha?', variant: IyoTextVariant.title),
                IyoText('You’re at Rue Joss, Akwa, Douala', color: IyoPalette.textSecondary),
                IyoText('You’re in a busy area', variant: IyoTextVariant.cardTitle),
                IyoText('Home · Bonapriso', variant: IyoTextVariant.rowTitle),
                IyoText(
                  'Nearby rides from 1 500 FCFA · Pickup in about 3 min',
                  variant: IyoTextVariant.caption,
                  color: IyoPalette.textSecondary,
                ),
              ]),
              _section('Buttons', [
                IyoButton(label: 'Where are you going?', onPressed: () {}),
                IyoButton(
                  label: 'Create an account',
                  variant: IyoButtonVariant.secondary,
                  onPressed: () {},
                ),
                IyoButton(
                  label: 'Send security alert',
                  variant: IyoButtonVariant.danger,
                  onPressed: () {},
                ),
                const IyoButton(label: 'Loading', loading: true),
                const IyoButton(label: 'Disabled', disabled: true),
                Row(
                  children: [
                    Expanded(
                      child: IyoButton(
                        label: 'I’m here',
                        variant: IyoButtonVariant.secondary,
                        size: IyoButtonSize.sm,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: IyoSpacing.sm),
                    Expanded(
                      child: IyoButton(
                        label: 'Call driver',
                        icon: LucideIcons.phone,
                        variant: IyoButtonVariant.secondary,
                        size: IyoButtonSize.sm,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                IyoButton(label: 'Skip for now', variant: IyoButtonVariant.ghost, onPressed: () {}),
                Row(
                  children: [
                    IyoIconButton(icon: LucideIcons.phone, semanticLabel: 'Call', onPressed: () {}),
                    const SizedBox(width: IyoSpacing.md),
                    IyoIconButton(
                      icon: LucideIcons.messageCircle,
                      tone: IyoIconButtonTone.surface,
                      semanticLabel: 'Message',
                      onPressed: () {},
                    ),
                  ],
                ),
              ]),
              _section('Segmented tabs', [
                IyoSegmentedTabs<_Service>(
                  large: true,
                  value: _service,
                  onChanged: (v) => setState(() => _service = v),
                  options: const [
                    IyoSegment(value: _Service.ride, label: 'Ride', icon: LucideIcons.carFront),
                    IyoSegment(
                      value: _Service.rent,
                      label: 'Rent a car',
                      icon: LucideIcons.calendarDays,
                    ),
                  ],
                ),
                IyoSegmentedTabs<_View>(
                  value: _view,
                  onChanged: (v) => setState(() => _view = v),
                  options: const [
                    IyoSegment(value: _View.all, label: 'All'),
                    IyoSegment(value: _View.unread, label: 'Unread'),
                  ],
                ),
              ]),
              _section('Badges', const [
                Wrap(
                  spacing: IyoSpacing.sm,
                  runSpacing: IyoSpacing.sm,
                  children: [
                    IyoBadge('Your pickup PIN · 4826'),
                    IyoBadge('Accepting ride requests', tone: IyoBadgeTone.success, dot: true),
                    IyoBadge('Rejected', tone: IyoBadgeTone.danger),
                    IyoBadge('Driver', tone: IyoBadgeTone.dark),
                    IyoBadge('Pending', tone: IyoBadgeTone.neutral),
                  ],
                ),
              ]),
              _section('Form fields', [
                IyoSelectField<String>(
                  label: 'City',
                  value: _city,
                  onChanged: (v) => setState(() => _city = v),
                  options: const [
                    IyoSelectOption(value: 'douala', label: 'Douala'),
                    IyoSelectOption(value: 'yaounde', label: 'Yaoundé'),
                  ],
                ),
                const IyoTextField(
                  label: 'Mobile number',
                  prefix: '+237',
                  initialValue: '6 71 23 45 67',
                  keyboardType: TextInputType.phone,
                  helper: 'We’ll text you a 6-digit verification code.',
                ),
                const IyoTextField(label: 'Full name', placeholder: 'e.g. Aïcha Ngo Mbappe'),
                const IyoTextField(
                  label: 'Flight number',
                  initialValue: 'AF 900',
                  error: 'Enter a valid flight number (e.g. AF 982).',
                ),
                IyoOtpInput(
                  label: 'Verification code',
                  value: _otp,
                  onChanged: (v) => setState(() => _otp = v),
                ),
                IyoPinInput(
                  label: 'Ask Aïcha for her 4-digit pickup PIN',
                  value: _pin,
                  onChanged: (v) => setState(() => _pin = v),
                  helper: '✓ PIN verified · You can start the ride.',
                ),
                IyoToggle(
                  label: 'Online',
                  description: 'Receive ride requests nearby',
                  value: _online,
                  onChanged: (v) => setState(() => _online = v),
                ),
                IyoToggle(
                  label: 'Push notifications',
                  value: _push,
                  onChanged: (v) => setState(() => _push = v),
                ),
              ]),
              _section('Cards & rows', [
                const IyoCard(
                  tone: IyoCardTone.accent,
                  title: 'You’re in a busy area',
                  description:
                      'Akwa & Bonanjo · Stay nearby for your next ride. Keep your phone mounted safely.',
                ),
                IyoCard(
                  children: [
                    IyoListRow(
                      icon: LucideIcons.house,
                      title: 'Home',
                      subtitle: 'Rue Njo-Njo, Bonapriso',
                      onPressed: () {},
                    ),
                    IyoListRow(
                      icon: LucideIcons.clock3,
                      title: 'Marché Sandaga',
                      subtitle: 'Recent destination · Akwa',
                      onPressed: () {},
                    ),
                  ],
                ),
                IyoCard(
                  title: 'Personal details',
                  children: [
                    IyoListRow(
                      title: 'Mobile number',
                      subtitle: '+237 6 71 23 45 67',
                      onPressed: () {},
                    ),
                    const IyoDivider(),
                    IyoListRow(title: 'Language', subtitle: 'Français', onPressed: () {}),
                  ],
                ),
                const IyoListRow(
                  icon: LucideIcons.wallet,
                  title: 'Today · 18 500 FCFA',
                  subtitle: '7 trips · 2 h 18 min online',
                ),
                IyoListRow(
                  icon: LucideIcons.shieldCheck,
                  title: 'Report a safety issue',
                  destructive: true,
                  onPressed: () {},
                ),
                const Row(
                  children: [
                    Expanded(
                      child: IyoStatTile(
                        label: 'Today',
                        value: '18 500 FCFA',
                        detail: '7 trips',
                        icon: LucideIcons.wallet,
                      ),
                    ),
                    SizedBox(width: IyoSpacing.sm),
                    Expanded(
                      child: IyoStatTile(
                        label: 'Rating',
                        value: '4.9',
                        detail: 'Last 100 trips',
                        accent: true,
                      ),
                    ),
                  ],
                ),
              ]),
              _section('People', [
                IyoPersonInfoCard(
                  name: 'Jean-Paul Mbarga',
                  meta: '★ 4.9 · 1 248 trips',
                  detail: 'Toyota Corolla · Blanc · LT 123 AB',
                  onCall: () {},
                ),
                IyoPersonInfoCard(
                  name: 'Aïcha Ngo Mbappe',
                  meta: '★ 4.8 · Verified rider',
                  detail: 'Pickup PIN · 4826',
                  onMessage: () {},
                  onCall: () {},
                ),
                const Row(
                  children: [
                    IyoAvatar(name: 'Aïcha Ngo Mbappe'),
                    SizedBox(width: IyoSpacing.md),
                    IyoAvatar(name: 'Jean-Paul Mbarga', size: 40),
                  ],
                ),
                const IyoActionTileRow(
                  children: [
                    IyoActionTile(icon: LucideIcons.messageCircle, label: 'Message'),
                    IyoActionTile(icon: LucideIcons.share2, label: 'Share trip'),
                    IyoActionTile(icon: LucideIcons.shieldCheck, label: 'Safety', accent: true),
                  ],
                ),
              ]),
              _section('Map', [
                if (!googleMapsAvailable)
                  const IyoText(
                    'No GOOGLE_MAPS_API_KEY in this build: showing the schematic fallback map.',
                    variant: IyoTextVariant.caption,
                    color: IyoPalette.textSecondary,
                  ),
                IyoMapCard(
                  center: doualaCenter,
                  onRecenter: () {},
                  markers: const [
                    IyoMapMarker(id: 'pickup', kind: IyoMarkerKind.pickup, position: _pickup),
                    IyoMapMarker(id: 'car', kind: IyoMarkerKind.car, position: _car, heading: 35),
                  ],
                ),
                const IyoMapCard(
                  center: _pickup,
                  height: 255,
                  fitToContent: true,
                  route: _route,
                  markers: [
                    IyoMapMarker(id: 'pickup', kind: IyoMarkerKind.pickup, position: _pickup),
                    IyoMapMarker(
                      id: 'dropoff',
                      kind: IyoMarkerKind.destination,
                      position: _dropoff,
                    ),
                    IyoMapMarker(id: 'car', kind: IyoMarkerKind.car, position: _car),
                  ],
                ),
              ]),
              _section('Chat', [
                for (final m in _messages) IyoChatBubble(message: m),
                IyoChatComposer(
                  placeholder: 'Write a message…',
                  sendLabel: 'Send',
                  attachLabel: 'Attach',
                  onAttach: () {},
                  onSend: (_) {},
                ),
              ]),
              _section('States', [
                IyoOfflineBanner(
                  message: 'You’re offline. We’ll retry when you’re back online.',
                  retryLabel: 'Retry',
                  onRetry: () {},
                ),
                const IyoSkeletonRow(),
                const IyoSkeleton(height: 120, radius: IyoRadii.lg),
                IyoEmptyState(
                  title: 'No trips yet',
                  message: 'Your rides and rentals will show up here.',
                  actionLabel: 'Book a ride',
                  onAction: () {},
                ),
                IyoErrorState(
                  title: 'Couldn’t load your trips',
                  message: 'Check your connection and try again.',
                  retryLabel: 'Try again',
                  onRetry: () {},
                ),
              ]),
            ],
          ),
        ),
        IyoBottomTabBar(items: _tabs, activeKey: _tab, onSelect: (k) => setState(() => _tab = k)),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IyoText(title, variant: IyoTextVariant.label, color: IyoPalette.textSecondary),
        for (final c in children) ...[const SizedBox(height: IyoSpacing.md), c],
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex = '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(IyoRadii.md),
              border: Border.all(color: IyoPalette.border),
            ),
          ),
          const SizedBox(height: 2),
          IyoText(name, variant: IyoTextVariant.micro),
          IyoText(hex, variant: IyoTextVariant.micro, color: IyoPalette.textSecondary),
        ],
      ),
    );
  }
}
