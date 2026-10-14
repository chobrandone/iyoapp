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

export type ButtonVariant = 'primary' | 'secondary' | 'soft' | 'danger' | 'ghost';
export type ButtonSize = 'lg' | 'sm';

export type ButtonProps = Omit<PressableProps, 'children' | 'style'> & {
  label: string;
  variant?: ButtonVariant;
  /** `lg` = 52 px pinned action; `sm` = 40 px quick action ("I'm here", "Call driver"). */
  size?: ButtonSize;
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
  soft: { bg: 'accentSoft', fg: 'ink' },
  danger: { bg: 'danger', fg: 'white' },
  ghost: { bg: 'transparent', fg: 'ink' },
};

/** Figma "Action": 52 px tall, radius 10, 14 px SemiBold label. */
export function Button({
  label,
  variant = 'primary',
  size = 'lg',
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
  const small = size === 'sm';

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled: !!isDisabled, busy: loading }}
      disabled={isDisabled}
      hitSlop={small ? 2 : 0}
      style={({ pressed }) => [
        styles.base,
        {
          height: small ? theme.sizes.buttonSmallHeight : theme.sizes.buttonHeight,
          borderRadius: theme.radii.md,
          backgroundColor: theme.colors[bg],
          paddingHorizontal: theme.spacing.lg,
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
          <Text variant={small ? 'buttonSmall' : 'button'} color={fg} numberOfLines={1}>
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
