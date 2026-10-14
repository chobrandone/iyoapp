import MessageCircle from 'lucide-react-native/icons/message-circle';
import Phone from 'lucide-react-native/icons/phone';
import { StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Avatar } from './Avatar';
import { IconButton } from './IconButton';
import { Text } from './Text';

export type PersonInfoCardProps = {
  name: string;
  photoUrl?: string | null;
  /** Secondary line, e.g. "★ 4.9 · 1 248 trips" or "★ 4.9 · Verified rider". */
  meta?: string;
  /** Ink line, e.g. "Toyota Corolla · White · LT 123 AB" or "Pickup PIN · 4826". */
  detail?: string;
  onCall?: () => void;
  callLabel?: string;
  onMessage?: () => void;
  messageLabel?: string;
};

/**
 * Figma "Trip companion": 52 px portrait, 14 px SemiBold name, two 11 px lines, 40 px
 * pale-yellow contact button. Used as DriverInfoCard (rider app) and RiderInfoCard (driver app).
 */
export function PersonInfoCard({
  name,
  photoUrl,
  meta,
  detail,
  onCall,
  callLabel = 'Call',
  onMessage,
  messageLabel = 'Message',
}: PersonInfoCardProps) {
  const theme = useTheme();
  return (
    <View style={[styles.row, { gap: theme.spacing.md }]}>
      <Avatar name={name} uri={photoUrl} size={theme.sizes.portrait} />
      <View style={[styles.identity, { gap: theme.spacing.xxs }]}>
        <Text variant="subheading" numberOfLines={1}>
          {name}
        </Text>
        {meta ? (
          <Text variant="caption" color="textSecondary" numberOfLines={1}>
            {meta}
          </Text>
        ) : null}
        {detail ? (
          <Text variant="caption" numberOfLines={1}>
            {detail}
          </Text>
        ) : null}
      </View>
      {onMessage ? (
        <IconButton
          icon={MessageCircle}
          accessibilityLabel={messageLabel}
          onPress={onMessage}
          iconSize={19}
        />
      ) : null}
      {onCall ? (
        <IconButton icon={Phone} accessibilityLabel={callLabel} onPress={onCall} iconSize={19} />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', alignSelf: 'stretch' },
  identity: { flex: 1 },
});
