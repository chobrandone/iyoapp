import { Pressable, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { useTheme } from '../theme';
import { Icon, type LucideIcon } from './Icon';
import { Text } from './Text';

export type BottomTabItem = {
  key: string;
  label: string;
  icon: LucideIcon;
  /** Shows a small red dot (e.g. unread notifications). */
  badge?: boolean;
};

export type BottomTabBarProps = {
  items: readonly BottomTabItem[];
  activeKey: string;
  onSelect: (key: string) => void;
};

/**
 * Figma "Navigation": 64 px bar with a top border, 20 px icons, 9 px labels
 * (SemiBold ink when active, Regular grey otherwise) and a 16 × 3 accent indicator.
 * Presentational only: each app adapts it to Expo Router's `<Tabs tabBar>`.
 */
export function BottomTabBar({ items, activeKey, onSelect }: BottomTabBarProps) {
  const theme = useTheme();
  const insets = useSafeAreaInsets();

  return (
    <View
      accessibilityRole="tablist"
      style={[
        styles.bar,
        {
          height: theme.sizes.tabBarHeight + insets.bottom,
          paddingBottom: insets.bottom,
          borderTopColor: theme.colors.border,
          backgroundColor: theme.colors.white,
          paddingHorizontal: theme.spacing.md,
        },
      ]}
    >
      {items.map((item) => {
        const active = item.key === activeKey;
        return (
          <Pressable
            key={item.key}
            accessibilityRole="tab"
            accessibilityLabel={item.label}
            accessibilityState={{ selected: active }}
            onPress={() => onSelect(item.key)}
            style={styles.item}
          >
            <View>
              <Icon
                icon={item.icon}
                size={theme.sizes.iconTab}
                color={active ? 'ink' : 'textSecondary'}
              />
              {item.badge ? (
                <View
                  style={[
                    styles.badge,
                    { backgroundColor: theme.colors.danger, borderColor: theme.colors.white },
                  ]}
                />
              ) : null}
            </View>
            <Text
              variant={active ? 'tabActive' : 'tab'}
              color={active ? 'ink' : 'textSecondary'}
              numberOfLines={1}
            >
              {item.label}
            </Text>
            <View
              style={[
                styles.indicator,
                { backgroundColor: active ? theme.colors.accent : theme.colors.transparent },
              ]}
            />
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  bar: { flexDirection: 'row', borderTopWidth: 1, alignItems: 'flex-start' },
  item: { flex: 1, alignItems: 'center', paddingTop: 8, gap: 3, minHeight: 56 },
  indicator: { width: 16, height: 3, borderRadius: 2 },
  badge: {
    position: 'absolute',
    top: -2,
    right: -4,
    width: 9,
    height: 9,
    borderRadius: 5,
    borderWidth: 1.5,
  },
});
