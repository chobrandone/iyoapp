import type { LucideIcon } from 'lucide-react-native';

import { useTheme, type Theme } from '../theme';

export type { LucideIcon };

export type IconProps = {
  icon: LucideIcon;
  size?: number;
  color?: keyof Theme['colors'];
  strokeWidth?: number;
};

/**
 * Lucide outline icon with the design-system stroke (1.75) and colour tokens.
 * Decorative: SVGs are not focusable, so the parent control carries the label.
 */
export function Icon({ icon: Glyph, size, color = 'ink', strokeWidth }: IconProps) {
  const theme = useTheme();
  return (
    <Glyph
      size={size ?? theme.sizes.icon}
      color={theme.colors[color]}
      strokeWidth={strokeWidth ?? theme.sizes.iconStroke}
    />
  );
}
