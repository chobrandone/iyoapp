import { Pressable, StyleSheet, type PressableProps, type ViewStyle } from 'react-native';

import { useTheme, type Theme } from '../theme';
import { Icon, type LucideIcon } from './Icon';

export type IconButtonTone = 'soft' | 'surface' | 'white' | 'accent' | 'ghost';

export type IconButtonProps = Omit<PressableProps, 'style' | 'children'> & {
  icon: LucideIcon;
  /** Required: icon-only buttons need a spoken label. */
  accessibilityLabel: string;
  tone?: IconButtonTone;
  /** Visual diameter. The touch target is always at least 44 px. */
  size?: number;
  iconSize?: number;
  shape?: 'circle' | 'rounded';
  style?: ViewStyle;
};

const toneBg: Record<IconButtonTone, keyof Theme['colors']> = {
  soft: 'accentSoft',
  surface: 'surface',
  white: 'white',
  accent: 'accent',
  ghost: 'transparent',
};

/** Round icon-only button: call/contact (40 px, soft), map recenter (36 px, white), send (32 px, accent). */
export function IconButton({
  icon,
  tone = 'soft',
  size,
  iconSize,
  shape = 'circle',
  style,
  disabled,
  ...rest
}: IconButtonProps) {
  const theme = useTheme();
  const diameter = size ?? theme.sizes.contactButton;
  const hitSlop = Math.max(0, (theme.sizes.minTouchTarget - diameter) / 2);

  return (
    <Pressable
      accessibilityRole="button"
      hitSlop={hitSlop}
      disabled={disabled}
      style={({ pressed }) => [
        styles.base,
        {
          width: diameter,
          height: diameter,
          borderRadius: shape === 'circle' ? diameter / 2 : theme.radii.md,
          backgroundColor: theme.colors[toneBg[tone]],
          opacity: disabled ? 0.5 : pressed ? 0.8 : 1,
        },
        tone === 'white' ? theme.shadows.card : null,
        style,
      ]}
      {...rest}
    >
      <Icon icon={icon} size={iconSize ?? Math.round(diameter * 0.48)} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: { alignItems: 'center', justifyContent: 'center' },
});
