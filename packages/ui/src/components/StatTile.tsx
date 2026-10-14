import { StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Icon, type LucideIcon } from './Icon';
import { Text } from './Text';

export type StatTileProps = {
  label: string;
  value: string;
  /** Secondary line under the value, e.g. "7 trips · 2 h 18 min online". */
  detail?: string;
  icon?: LucideIcon;
  tone?: 'surface' | 'accent';
};

/** Compact metric (earnings, trips, rating). Uses card tokens: radius 10, padding 14. */
export function StatTile({ label, value, detail, icon, tone = 'surface' }: StatTileProps) {
  const theme = useTheme();
  return (
    <View
      accessible
      accessibilityLabel={[label, value, detail].filter(Boolean).join(', ')}
      style={[
        styles.tile,
        {
          backgroundColor: tone === 'accent' ? theme.colors.accentSoft : theme.colors.surface,
          borderRadius: theme.radii.md,
          padding: 14,
          gap: theme.spacing.xs,
        },
      ]}
    >
      <View style={[styles.labelRow, { gap: 6 }]}>
        {icon ? <Icon icon={icon} size={16} color="textSecondary" /> : null}
        <Text variant="caption" color="textSecondary" numberOfLines={1}>
          {label}
        </Text>
      </View>
      <Text variant="cardTitle" numberOfLines={1} adjustsFontSizeToFit>
        {value}
      </Text>
      {detail ? (
        <Text variant="helper" color="textSecondary" numberOfLines={2}>
          {detail}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  tile: { flex: 1 },
  labelRow: { flexDirection: 'row', alignItems: 'center' },
});
