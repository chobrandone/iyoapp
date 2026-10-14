import ChevronRight from 'lucide-react-native/icons/chevron-right';
import type { ReactNode } from 'react';
import { Pressable, StyleSheet, View, type ViewStyle } from 'react-native';

import { useTheme, type Theme } from '../theme';
import { Icon, type LucideIcon } from './Icon';
import { Text } from './Text';

export type ListRowProps = {
  title: string;
  subtitle?: string;
  /** Icon shown in a 36 px rounded well on the left. */
  icon?: LucideIcon;
  iconWellTone?: 'surface' | 'accent' | 'white';
  /** Custom left element (e.g. Avatar); overrides `icon`. */
  left?: ReactNode;
  /** Custom right element; defaults to a chevron when `onPress` is set. */
  right?: ReactNode;
  showChevron?: boolean;
  onPress?: () => void;
  destructive?: boolean;
  style?: ViewStyle;
};

const wellBg: Record<NonNullable<ListRowProps['iconWellTone']>, keyof Theme['colors']> = {
  surface: 'surface',
  accent: 'accentSoft',
  white: 'white',
};

/** Figma "Detail row": 36 px icon well, 13 px Medium title, 11 px secondary subtitle; padding 9, gap 12. */
export function ListRow({
  title,
  subtitle,
  icon,
  iconWellTone = 'surface',
  left,
  right,
  showChevron,
  onPress,
  destructive = false,
  style,
}: ListRowProps) {
  const theme = useTheme();
  const chevron = showChevron ?? !!onPress;

  const content = (
    <>
      {left ??
        (icon ? (
          <View
            style={[
              styles.well,
              {
                width: theme.sizes.iconWell,
                height: theme.sizes.iconWell,
                borderRadius: theme.radii.md,
                backgroundColor: theme.colors[wellBg[iconWellTone]],
              },
            ]}
          >
            <Icon icon={icon} size={theme.sizes.iconSmall} color={destructive ? 'danger' : 'ink'} />
          </View>
        ) : null)}
      <View style={[styles.text, { gap: theme.spacing.xxs }]}>
        <Text variant="rowTitle" color={destructive ? 'danger' : 'ink'}>
          {title}
        </Text>
        {subtitle ? (
          <Text variant="caption" color="textSecondary">
            {subtitle}
          </Text>
        ) : null}
      </View>
      {right ??
        (chevron ? (
          <Icon icon={ChevronRight} size={theme.sizes.iconSmall} color="textSecondary" />
        ) : null)}
    </>
  );

  const rowStyle = [styles.row, { gap: theme.spacing.md, paddingVertical: 9 }];

  if (onPress) {
    return (
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={subtitle ? `${title}, ${subtitle}` : title}
        onPress={onPress}
        style={({ pressed }) => [...rowStyle, { opacity: pressed ? 0.7 : 1 }, style]}
      >
        {content}
      </Pressable>
    );
  }
  return <View style={[...rowStyle, style]}>{content}</View>;
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', minHeight: 44, alignSelf: 'stretch' },
  well: { alignItems: 'center', justifyContent: 'center' },
  text: { flex: 1 },
});
