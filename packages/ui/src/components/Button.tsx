import type { ReactNode } from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  View,
  type PressableProps,
  type ViewStyle,
} from 'react-native';

import { useTheme, type Theme } from '../theme';
import { Text } from './Text';

export type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost';

export type ButtonProps = Omit<PressableProps, 'children' | 'style'> & {
  label: string;
  variant?: ButtonVariant;
  loading?: boolean;
  /** Icon rendered before the label. */
  icon?: ReactNode;
  /** Full width (default) or hug the content. */
  fullWidth?: boolean;
  style?: ViewStyle;
};

type VariantColors = {
  bg: keyof Theme['colors'];
  fg: keyof Theme['colors'];
};

const variantColors: Record<ButtonVariant, VariantColors> = {
  primary: { bg: 'accent', fg: 'onAccent' },
  secondary: { bg: 'surface', fg: 'ink' },
  danger: { bg: 'danger', fg: 'white' },
  ghost: { bg: 'transparent', fg: 'ink' },
};

/** 52 px, radius 12 action button used in every pinned bottom action area. */
export function Button({
  label,
  variant = 'primary',
  loading = false,
  disabled,
  icon,
  fullWidth = true,
  style,
  ...rest
}: ButtonProps) {
  const theme = useTheme();
  const { bg, fg } = variantColors[variant];
  const isDisabled = disabled || loading;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled: !!isDisabled, busy: loading }}
      disabled={isDisabled}
      style={({ pressed }) => [
        styles.base,
        {
          height: theme.sizes.buttonHeight,
          borderRadius: theme.radii.md,
          backgroundColor: theme.colors[bg],
          paddingHorizontal: theme.spacing.xl,
          opacity: isDisabled ? 0.5 : pressed ? 0.85 : 1,
        },
        fullWidth ? styles.fullWidth : null,
        style,
      ]}
      {...rest}
    >
      {loading ? (
        <ActivityIndicator color={theme.colors[fg]} />
      ) : (
        <View style={[styles.content, { gap: theme.spacing.sm }]}>
          {icon}
          <Text variant="button" color={fg} numberOfLines={1}>
            {label}
          </Text>
        </View>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: { alignItems: 'center', justifyContent: 'center' },
  fullWidth: { alignSelf: 'stretch' },
  content: { flexDirection: 'row', alignItems: 'center' },
});
