import type { ReactNode } from 'react';
import { StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Badge } from './Badge';
import { Text } from './Text';

export type AppHeaderProps = {
  /** Small badge next to the wordmark, e.g. "DRIVER" in the driver app. */
  badge?: string;
  /** Uppercase flow label on the right, e.g. "RIDER · 01". */
  flowLabel?: string;
  /** Replaces the wordmark (e.g. a back button). */
  left?: ReactNode;
  right?: ReactNode;
};

export function AppHeader({ badge, flowLabel, left, right }: AppHeaderProps) {
  const theme = useTheme();
  return (
    <View style={[styles.row, { paddingVertical: theme.spacing.md }]}>
      <View style={[styles.side, { gap: theme.spacing.sm }]}>
        {left ?? (
          <>
            <Text variant="wordmark" accessibilityRole="header">
              iyodriver
            </Text>
            {badge ? <Badge label={badge} tone="dark" /> : null}
          </>
        )}
      </View>
      {right ??
        (flowLabel ? (
          <Text variant="label" color="muted">
            {flowLabel}
          </Text>
        ) : null)}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    minHeight: 44,
  },
  side: { flexDirection: 'row', alignItems: 'center' },
});
