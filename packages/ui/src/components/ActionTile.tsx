import { Pressable, StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Icon, type LucideIcon } from './Icon';
import { Text } from './Text';

export type ActionTileProps = {
  icon: LucideIcon;
  label: string;
  onPress?: () => void;
  /** `accent` = pale yellow (Safety); `surface` = grey (Message, Share trip). */
  tone?: 'surface' | 'accent';
  disabled?: boolean;
};

/** Figma "Trip action": 64 px tall, radius 10, 20 px icon over a 10 px Medium label. */
export function ActionTile({ icon, label, onPress, tone = 'surface', disabled }: ActionTileProps) {
  const theme = useTheme();
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled: !!disabled }}
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.tile,
        {
          height: theme.sizes.tileHeight,
          borderRadius: theme.radii.md,
          backgroundColor: tone === 'accent' ? theme.colors.accentSoft : theme.colors.surface,
          opacity: disabled ? 0.5 : pressed ? 0.8 : 1,
        },
      ]}
    >
      <Icon icon={icon} size={theme.sizes.iconTab} />
      <Text variant="tileLabel" color="black" numberOfLines={1}>
        {label}
      </Text>
    </Pressable>
  );
}

/** Lays tiles out in an equal-width row with an 8 px gap. */
export function ActionTileRow({ children }: { children: React.ReactNode }) {
  const theme = useTheme();
  return <View style={[styles.row, { gap: theme.spacing.sm }]}>{children}</View>;
}

const styles = StyleSheet.create({
  tile: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 5 },
  row: { flexDirection: 'row', alignSelf: 'stretch' },
});
