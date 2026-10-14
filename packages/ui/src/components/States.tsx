import CircleAlert from 'lucide-react-native/icons/circle-alert';
import Inbox from 'lucide-react-native/icons/inbox';
import WifiOff from 'lucide-react-native/icons/wifi-off';
import { useEffect, useState } from 'react';
import {
  Animated,
  Pressable,
  StyleSheet,
  View,
  type DimensionValue,
  type ViewStyle,
} from 'react-native';

import { useTheme } from '../theme';
import { Button } from './Button';
import { Icon, type LucideIcon } from './Icon';
import { Text } from './Text';

type StateProps = {
  title: string;
  message?: string;
  icon?: LucideIcon;
  actionLabel?: string;
  onAction?: () => void;
};

function StateLayout({
  title,
  message,
  icon,
  actionLabel,
  onAction,
  danger,
}: StateProps & { danger?: boolean }) {
  const theme = useTheme();
  return (
    <View style={[styles.state, { gap: theme.spacing.md, padding: theme.spacing.xxl }]}>
      <View
        style={[
          styles.stateIcon,
          { backgroundColor: danger ? theme.colors.dangerSoft : theme.colors.surface },
        ]}
      >
        <Icon icon={icon ?? Inbox} size={26} color={danger ? 'danger' : 'ink'} />
      </View>
      <Text variant="cardTitle" align="center" accessibilityRole="header">
        {title}
      </Text>
      {message ? (
        <Text variant="body" color="textSecondary" align="center">
          {message}
        </Text>
      ) : null}
      {actionLabel && onAction ? (
        <Button
          label={actionLabel}
          variant="secondary"
          size="sm"
          fullWidth={false}
          onPress={onAction}
        />
      ) : null}
    </View>
  );
}

/** Shown when a list or screen has no data yet. */
export function EmptyState(props: StateProps) {
  return <StateLayout {...props} />;
}

export type ErrorStateProps = Omit<StateProps, 'onAction'> & { onRetry?: () => void };

/** Shown when loading failed; offers a retry. */
export function ErrorState({ onRetry, icon, ...rest }: ErrorStateProps) {
  return <StateLayout {...rest} icon={icon ?? CircleAlert} onAction={onRetry} danger />;
}

export type SkeletonProps = {
  width?: DimensionValue;
  height?: number;
  radius?: number;
  style?: ViewStyle;
};

/** Pulsing placeholder block. Compose several to sketch the loading layout. */
export function Skeleton({ width = '100%', height = 16, radius, style }: SkeletonProps) {
  const theme = useTheme();
  const [opacity] = useState(() => new Animated.Value(0.5));

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, { toValue: 1, duration: 700, useNativeDriver: true }),
        Animated.timing(opacity, { toValue: 0.5, duration: 700, useNativeDriver: true }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [opacity]);

  return (
    <Animated.View
      aria-hidden
      style={[
        {
          width,
          height,
          borderRadius: radius ?? theme.radii.sm,
          backgroundColor: theme.colors.surface,
          opacity,
        },
        style,
      ]}
    />
  );
}

/** Skeleton shaped like a ListRow. */
export function SkeletonRow() {
  const theme = useTheme();
  return (
    <View style={[styles.skeletonRow, { gap: theme.spacing.md }]}>
      <Skeleton
        width={theme.sizes.iconWell}
        height={theme.sizes.iconWell}
        radius={theme.radii.md}
      />
      <View style={{ flex: 1, gap: 6 }}>
        <Skeleton width="60%" height={13} />
        <Skeleton width="40%" height={11} />
      </View>
    </View>
  );
}

export type OfflineBannerProps = {
  message: string;
  retryLabel?: string;
  onRetry?: () => void;
};

/** Dark strip shown at the top of a screen while the device is offline. */
export function OfflineBanner({ message, retryLabel, onRetry }: OfflineBannerProps) {
  const theme = useTheme();
  return (
    <View
      accessibilityRole="alert"
      accessibilityLiveRegion="polite"
      style={[
        styles.banner,
        { backgroundColor: theme.colors.ink, borderRadius: theme.radii.md, gap: theme.spacing.sm },
      ]}
    >
      <Icon icon={WifiOff} size={theme.sizes.iconSmall} color="white" />
      <Text variant="caption" color="white" style={styles.flex}>
        {message}
      </Text>
      {retryLabel && onRetry ? (
        <Pressable accessibilityRole="button" onPress={onRetry} hitSlop={12}>
          <Text variant="captionMedium" color="accent">
            {retryLabel}
          </Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  state: { alignItems: 'center', justifyContent: 'center', alignSelf: 'stretch' },
  stateIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    alignItems: 'center',
    justifyContent: 'center',
  },
  skeletonRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 9 },
  banner: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  flex: { flex: 1 },
});
