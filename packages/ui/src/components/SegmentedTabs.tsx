import { Pressable, StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Icon, type LucideIcon } from './Icon';
import { Text } from './Text';

export type SegmentOption<T extends string> = {
  value: T;
  label: string;
  icon?: LucideIcon;
};

export type SegmentedTabsProps<T extends string> = {
  options: readonly SegmentOption<T>[];
  value: T;
  onChange: (value: T) => void;
  /** `lg` = 56 px service selector (Ride / Rent a car); `md` = 40 px view filter (All / Unread). */
  size?: 'lg' | 'md';
  accessibilityLabel?: string;
};

/** Row of equal-width options; the active one is filled with the accent colour. */
export function SegmentedTabs<T extends string>({
  options,
  value,
  onChange,
  size = 'md',
  accessibilityLabel,
}: SegmentedTabsProps<T>) {
  const theme = useTheme();
  const large = size === 'lg';

  return (
    <View
      accessibilityRole="tablist"
      accessibilityLabel={accessibilityLabel}
      style={[styles.row, { gap: large ? 10 : theme.spacing.sm }]}
    >
      {options.map((option) => {
        const active = option.value === value;
        return (
          <Pressable
            key={option.value}
            accessibilityRole="tab"
            accessibilityState={{ selected: active }}
            accessibilityLabel={option.label}
            onPress={() => onChange(option.value)}
            style={({ pressed }) => [
              styles.option,
              {
                height: large ? theme.sizes.serviceOptionHeight : theme.sizes.buttonSmallHeight,
                borderRadius: theme.radii.md,
                backgroundColor: active ? theme.colors.accent : theme.colors.surface,
                paddingHorizontal: large ? theme.spacing.md : theme.spacing.sm,
                gap: 9,
                opacity: pressed ? 0.85 : 1,
              },
            ]}
          >
            {option.icon ? <Icon icon={option.icon} size={theme.sizes.icon} /> : null}
            <Text
              variant={large ? 'bodyStrong' : active ? 'buttonSmall' : 'body'}
              color={active ? 'onAccent' : 'ink'}
              numberOfLines={1}
              style={large ? styles.labelLarge : null}
            >
              {option.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row' },
  option: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
  labelLarge: { flexShrink: 1 },
});
