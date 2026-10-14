import { View, type ViewStyle } from 'react-native';

import { useTheme } from '../theme';
import { Text } from './Text';

export type PageHeadingProps = {
  title: string;
  subtitle?: string;
  /** Use the larger hero size (welcome / onboarding screens). */
  hero?: boolean;
  style?: ViewStyle;
};

export function PageHeading({ title, subtitle, hero = false, style }: PageHeadingProps) {
  const theme = useTheme();
  return (
    <View style={[{ gap: theme.spacing.sm, paddingVertical: theme.spacing.lg }, style]}>
      <Text variant={hero ? 'hero' : 'title'} accessibilityRole="header">
        {title}
      </Text>
      {subtitle ? (
        <Text variant="bodyLarge" color="muted">
          {subtitle}
        </Text>
      ) : null}
    </View>
  );
}
