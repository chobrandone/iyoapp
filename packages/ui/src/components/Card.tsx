import type { ReactNode } from 'react';
import { Pressable, View, type ViewStyle } from 'react-native';

import { useTheme, type Theme } from '../theme';
import { Text } from './Text';

export type CardTone = 'surface' | 'accent' | 'white' | 'success' | 'danger';

export type CardProps = {
  tone?: CardTone;
  title?: string;
  /** Body copy under the title (charcoal on accent cards, secondary on surface cards). */
  description?: string;
  onPress?: () => void;
  accessibilityLabel?: string;
  style?: ViewStyle;
  children?: ReactNode;
};

const toneBg: Record<CardTone, keyof Theme['colors']> = {
  surface: 'surface',
  accent: 'accentSoft',
  white: 'white',
  success: 'successSoft',
  danger: 'dangerSoft',
};

/** Figma "Information card": radius 16, padding 16, gap 10. */
export function Card({
  tone = 'surface',
  title,
  description,
  onPress,
  accessibilityLabel,
  style,
  children,
}: CardProps) {
  const theme = useTheme();
  const base: ViewStyle = {
    backgroundColor: theme.colors[toneBg[tone]],
    borderRadius: theme.radii.lg,
    padding: theme.spacing.lg,
    gap: 10,
    alignSelf: 'stretch',
    ...(tone === 'white' ? { borderWidth: 1, borderColor: theme.colors.border } : null),
  };

  const content = (
    <>
      {title ? <Text variant="cardTitle">{title}</Text> : null}
      {description ? (
        <Text
          variant="body"
          color={tone === 'surface' || tone === 'white' ? 'textSecondary' : 'charcoal'}
        >
          {description}
        </Text>
      ) : null}
      {children}
    </>
  );

  if (onPress) {
    return (
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={accessibilityLabel ?? title}
        onPress={onPress}
        style={({ pressed }) => [base, { opacity: pressed ? 0.85 : 1 }, style]}
      >
        {content}
      </Pressable>
    );
  }
  return <View style={[base, style]}>{content}</View>;
}
