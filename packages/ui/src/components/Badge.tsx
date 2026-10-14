import { StyleSheet, View, type ViewStyle } from 'react-native';

import { useTheme, type Theme } from '../theme';
import { Text } from './Text';

export type BadgeTone = 'accent' | 'neutral' | 'dark' | 'success' | 'danger';

export type BadgeProps = {
  label: string;
  tone?: BadgeTone;
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

/** Small uppercase pill, e.g. "DRIVER", "VERIFIED". */
export function Badge({ label, tone = 'accent', style }: BadgeProps) {
  const theme = useTheme();
  const { bg, fg } = toneColors[tone];
  return (
    <View
      style={[
        styles.base,
        {
          backgroundColor: theme.colors[bg],
          borderRadius: theme.radii.pill,
          paddingHorizontal: theme.spacing.sm,
        },
        style,
      ]}
    >
      <Text variant="label" color={fg}>
        {label}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  base: { alignSelf: 'flex-start', paddingVertical: 2 },
});
