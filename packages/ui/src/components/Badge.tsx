import { StyleSheet, View, type ViewStyle } from 'react-native';

import { useTheme, type Theme } from '../theme';
import { Text } from './Text';

export type BadgeTone = 'accent' | 'neutral' | 'dark' | 'success' | 'danger';

export type BadgeProps = {
  label: string;
  tone?: BadgeTone;
  /** Leading dot, e.g. "● ACCEPTING RIDE REQUESTS". */
  dot?: boolean;
  style?: ViewStyle;
};

type ToneColors = { bg: keyof Theme['colors']; fg: keyof Theme['colors'] };

const toneColors: Record<BadgeTone, ToneColors> = {
  accent: { bg: 'accentSoft', fg: 'ink' },
  neutral: { bg: 'surface', fg: 'ink' },
  dark: { bg: 'ink', fg: 'white' },
  success: { bg: 'successSoft', fg: 'success' },
  danger: { bg: 'dangerSoft', fg: 'danger' },
};

/** Status pill (Figma "Status"): 10 px Medium uppercase, radius 6, padding 10 × 5. */
export function Badge({ label, tone = 'accent', dot = false, style }: BadgeProps) {
  const theme = useTheme();
  const { bg, fg } = toneColors[tone];
  return (
    <View
      style={[
        styles.base,
        {
          backgroundColor: theme.colors[bg],
          borderRadius: theme.radii.xs,
          gap: theme.spacing.xs + 2,
        },
        style,
      ]}
    >
      {dot ? <View style={[styles.dot, { backgroundColor: theme.colors[fg] }]} /> : null}
      <Text variant="status" color={fg}>
        {label}
      </Text>
    </View>
  );
}

/** Alias: the prompt refers to status pills as both Badge and Pill. */
export const Pill = Badge;
export type PillProps = BadgeProps;

const styles = StyleSheet.create({
  base: {
    alignSelf: 'flex-start',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  dot: { width: 7, height: 7, borderRadius: 4 },
});
