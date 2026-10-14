/* Dev-only screen: strings here are internal sample data, intentionally not translated. */
import CalendarDays from 'lucide-react-native/icons/calendar-days';
import CarFront from 'lucide-react-native/icons/car-front';
import Clock3 from 'lucide-react-native/icons/clock-3';
import House from 'lucide-react-native/icons/house';
import MessageCircle from 'lucide-react-native/icons/message-circle';
import Phone from 'lucide-react-native/icons/phone';
import Share2 from 'lucide-react-native/icons/share-2';
import ShieldCheck from 'lucide-react-native/icons/shield-check';
import UserRound from 'lucide-react-native/icons/user-round';
import Wallet from 'lucide-react-native/icons/wallet';
import { useState, type ReactNode } from 'react';
import { StyleSheet, View } from 'react-native';

import { ActionTile, ActionTileRow } from '../components/ActionTile';
import { AppHeader } from '../components/AppHeader';
import { Avatar } from '../components/Avatar';
import { Badge } from '../components/Badge';
import { BottomTabBar, type BottomTabItem } from '../components/BottomTabBar';
import { Button } from '../components/Button';
import { Card } from '../components/Card';
import { ChatBubble, ChatComposer, type ChatMessage } from '../components/ChatThread';
import { OtpInput, PinInput } from '../components/CodeInput';
import { Divider } from '../components/Divider';
import { IconButton } from '../components/IconButton';
import { ListRow } from '../components/ListRow';
import { PageHeading } from '../components/PageHeading';
import { PersonInfoCard } from '../components/PersonInfoCard';
import { Screen } from '../components/Screen';
import { SegmentedTabs } from '../components/SegmentedTabs';
import { SelectField } from '../components/SelectField';
import { StatTile } from '../components/StatTile';
import { EmptyState, ErrorState, OfflineBanner, Skeleton, SkeletonRow } from '../components/States';
import { Text } from '../components/Text';
import { TextField } from '../components/TextField';
import { Toggle } from '../components/Toggle';
import { MapCard } from '../map/MapCard';
import { CarMarker, DestinationMarker, PickupMarker, RoutePolyline } from '../map/markers';
import { DOUALA_CENTER, type LatLng } from '../map/types';
import { colors, useTheme } from '../theme';

const PICKUP: LatLng = { latitude: 4.0469, longitude: 9.6953 }; // Akwa
const DROPOFF: LatLng = { latitude: 4.0283, longitude: 9.6931 }; // Bonapriso
const CAR: LatLng = { latitude: 4.0452, longitude: 9.7005 };
const ROUTE: LatLng[] = [
  PICKUP,
  { latitude: 4.0405, longitude: 9.6985 },
  { latitude: 4.0335, longitude: 9.6942 },
  DROPOFF,
];

const TABS: BottomTabItem[] = [
  { key: 'home', label: 'Home', icon: House },
  { key: 'activity', label: 'Activity', icon: Clock3 },
  { key: 'safety', label: 'Safety', icon: ShieldCheck, badge: true },
  { key: 'account', label: 'Account', icon: UserRound },
];

const MESSAGES: ChatMessage[] = [
  {
    id: '1',
    body: "Bonjour Aïcha, j'arrive. Je m'arrête devant l'entrée principale.",
    mine: false,
    meta: '09:38',
  },
  {
    id: '2',
    body: 'Merci ! Je suis devant la pharmacie, en robe bleue.',
    mine: true,
    meta: '09:39 · Lu',
  },
];

function Section({ title, children }: { title: string; children: ReactNode }) {
  const theme = useTheme();
  return (
    <View style={{ gap: theme.spacing.md }}>
      <Text variant="label" color="textSecondary">
        {title}
      </Text>
      {children}
    </View>
  );
}

function Swatch({ name, value }: { name: string; value: string }) {
  const theme = useTheme();
  return (
    <View style={styles.swatch}>
      <View
        style={[
          styles.swatchChip,
          {
            backgroundColor: value,
            borderRadius: theme.radii.md,
            borderColor: theme.colors.border,
          },
        ]}
      />
      <Text variant="micro">{name}</Text>
      <Text variant="micro" color="textSecondary">
        {value}
      </Text>
    </View>
  );
}

export type ComponentGalleryProps = {
  /** Flow label shown in the header, e.g. "RIDER · DEV". */
  flowLabel: string;
  /** Header badge (driver app shows "DRIVER"). */
  badge?: string;
  onBack?: () => void;
};

/** Every @iyodriver/ui component in its main states, for side-by-side comparison with Figma. */
export function ComponentGallery({ flowLabel, badge, onBack }: ComponentGalleryProps) {
  const theme = useTheme();
  const [service, setService] = useState<'ride' | 'rent'>('ride');
  const [view, setView] = useState<'all' | 'unread'>('all');
  const [phone, setPhone] = useState('6 71 23 45 67');
  const [city, setCity] = useState<'douala' | 'yaounde' | null>('douala');
  const [otp, setOtp] = useState('48261');
  const [pin, setPin] = useState('4826');
  const [online, setOnline] = useState(true);
  const [push, setPush] = useState(false);
  const [tab, setTab] = useState('home');

  return (
    <View style={styles.flex}>
      <Screen
        inTabs
        header={<AppHeader flowLabel={flowLabel} badge={badge} />}
        heading={
          <PageHeading
            title="Components"
            subtitle="@iyodriver/ui · compare with Figma frames"
            onBack={onBack}
          />
        }
      >
        <Section title="Colours">
          <View style={[styles.wrap, { gap: theme.spacing.md }]}>
            {Object.entries(colors)
              .filter(([, v]) => v.startsWith('#'))
              .map(([k, v]) => (
                <Swatch key={k} name={k} value={v} />
              ))}
          </View>
        </Section>

        <Section title="Typography">
          <Text variant="hero">Your city.</Text>
          <Text variant="title">Where to, Aïcha?</Text>
          <Text variant="body" color="textSecondary">
            You’re at Rue Joss, Akwa, Douala
          </Text>
          <Text variant="cardTitle">You’re in a busy area</Text>
          <Text variant="rowTitle">Home · Bonapriso</Text>
          <Text variant="caption" color="textSecondary">
            Nearby rides from 1 500 FCFA · Pickup in about 3 min
          </Text>
        </Section>

        <Section title="Buttons">
          <Button label="Where are you going?" />
          <Button label="Create an account" variant="secondary" />
          <Button label="Send security alert" variant="danger" />
          <Button label="Loading" loading />
          <Button label="Disabled" disabled />
          <View style={[styles.row, { gap: theme.spacing.sm }]}>
            <Button label="I’m here" variant="secondary" size="sm" style={styles.flex} />
            <Button
              label="Call driver"
              variant="secondary"
              size="sm"
              style={styles.flex}
              icon={
                <Phone size={18} color={theme.colors.ink} strokeWidth={theme.sizes.iconStroke} />
              }
            />
          </View>
          <Button label="Skip for now" variant="ghost" />
          <View style={[styles.row, { gap: theme.spacing.md }]}>
            <IconButton icon={Phone} accessibilityLabel="Call" />
            <IconButton icon={MessageCircle} tone="surface" accessibilityLabel="Message" />
          </View>
        </Section>

        <Section title="Segmented tabs">
          <SegmentedTabs
            size="lg"
            value={service}
            onChange={setService}
            options={[
              { value: 'ride', label: 'Ride', icon: CarFront },
              { value: 'rent', label: 'Rent a car', icon: CalendarDays },
            ]}
          />
          <SegmentedTabs
            value={view}
            onChange={setView}
            options={[
              { value: 'all', label: 'All' },
              { value: 'unread', label: 'Unread' },
            ]}
          />
        </Section>

        <Section title="Badges">
          <View style={[styles.wrap, { gap: theme.spacing.sm }]}>
            <Badge label="Your pickup PIN · 4826" />
            <Badge label="Accepting ride requests" tone="success" dot />
            <Badge label="Rejected" tone="danger" />
            <Badge label="Driver" tone="dark" />
            <Badge label="Pending" tone="neutral" />
          </View>
        </Section>

        <Section title="Form fields">
          <SelectField
            label="City"
            value={city}
            onChange={setCity}
            options={[
              { value: 'douala', label: 'Douala' },
              { value: 'yaounde', label: 'Yaoundé' },
            ]}
          />
          <TextField
            label="Mobile number"
            prefix="+237"
            value={phone}
            onChangeText={setPhone}
            keyboardType="phone-pad"
            helper="We’ll text you a 6-digit verification code."
          />
          <TextField label="Full name" placeholder="e.g. Aïcha Ngo Mbappe" />
          <TextField
            label="Flight number"
            value="AF 900"
            error="Enter a valid flight number (e.g. AF 982)."
          />
          <OtpInput label="Verification code" value={otp} onChange={setOtp} />
          <PinInput
            label="Ask Aïcha for her 4-digit pickup PIN"
            value={pin}
            onChange={setPin}
            helper="✓ PIN verified · You can start the ride."
          />
          <Toggle
            label="Online"
            description="Receive ride requests nearby"
            value={online}
            onValueChange={setOnline}
          />
          <Toggle label="Push notifications" value={push} onValueChange={setPush} />
        </Section>

        <Section title="Cards & rows">
          <Card
            tone="accent"
            title="You’re in a busy area"
            description="Akwa & Bonanjo · Stay nearby for your next ride. Keep your phone mounted safely."
          />
          <Card>
            <ListRow
              icon={House}
              title="Home"
              subtitle="Rue Njo-Njo, Bonapriso"
              onPress={() => undefined}
            />
            <ListRow
              icon={Clock3}
              title="Marché Sandaga"
              subtitle="Recent destination · Akwa"
              onPress={() => undefined}
            />
          </Card>
          <Card title="Personal details">
            <ListRow
              title="Mobile number"
              subtitle="+237 6 71 23 45 67"
              onPress={() => undefined}
            />
            <Divider />
            <ListRow title="Language" subtitle="Français" onPress={() => undefined} />
          </Card>
          <ListRow
            icon={Wallet}
            title="Today · 18 500 FCFA"
            subtitle="7 trips · 2 h 18 min online"
          />
          <ListRow
            icon={ShieldCheck}
            title="Report a safety issue"
            destructive
            onPress={() => undefined}
          />
          <View style={[styles.row, { gap: theme.spacing.sm }]}>
            <StatTile label="Today" value="18 500 FCFA" detail="7 trips" icon={Wallet} />
            <StatTile label="Rating" value="4.9" detail="Last 100 trips" tone="accent" />
          </View>
        </Section>

        <Section title="People">
          <PersonInfoCard
            name="Jean-Paul Mbarga"
            meta="★ 4.9 · 1 248 trips"
            detail="Toyota Corolla · Blanc · LT 123 AB"
            onCall={() => undefined}
          />
          <PersonInfoCard
            name="Aïcha Ngo Mbappe"
            meta="★ 4.8 · Verified rider"
            detail="Pickup PIN · 4826"
            onMessage={() => undefined}
            onCall={() => undefined}
          />
          <View style={[styles.row, { gap: theme.spacing.md }]}>
            <Avatar name="Aïcha Ngo Mbappe" />
            <Avatar name="Jean-Paul Mbarga" size={40} />
          </View>
          <ActionTileRow>
            <ActionTile icon={MessageCircle} label="Message" />
            <ActionTile icon={Share2} label="Share trip" />
            <ActionTile icon={ShieldCheck} label="Safety" tone="accent" />
          </ActionTileRow>
        </Section>

        <Section title="Map">
          <MapCard center={DOUALA_CENTER} onRecenter={() => undefined} height={220}>
            <PickupMarker coordinate={PICKUP} />
            <CarMarker coordinate={CAR} heading={35} />
          </MapCard>
          <MapCard center={PICKUP} fitTo={ROUTE} height={255}>
            <RoutePolyline coordinates={ROUTE} />
            <PickupMarker coordinate={PICKUP} />
            <DestinationMarker coordinate={DROPOFF} />
            <CarMarker coordinate={CAR} />
          </MapCard>
        </Section>

        <Section title="Chat">
          {MESSAGES.map((m) => (
            <ChatBubble key={m.id} message={m} />
          ))}
          <ChatComposer
            placeholder="Write a message…"
            sendLabel="Send"
            attachLabel="Attach"
            onAttach={() => undefined}
            onSend={() => undefined}
          />
        </Section>

        <Section title="States">
          <OfflineBanner
            message="You’re offline. We’ll retry when you’re back online."
            retryLabel="Retry"
            onRetry={() => undefined}
          />
          <SkeletonRow />
          <Skeleton height={120} radius={theme.radii.lg} />
          <EmptyState
            title="No trips yet"
            message="Your rides and rentals will show up here."
            actionLabel="Book a ride"
            onAction={() => undefined}
          />
          <ErrorState
            title="Couldn’t load your trips"
            message="Check your connection and try again."
            actionLabel="Try again"
            onRetry={() => undefined}
          />
        </Section>
      </Screen>
      <BottomTabBar items={TABS} activeKey={tab} onSelect={setTab} />
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  row: { flexDirection: 'row', alignItems: 'center' },
  wrap: { flexDirection: 'row', flexWrap: 'wrap' },
  swatch: { width: 92, gap: 2 },
  swatchChip: { height: 40, borderWidth: 1 },
});
