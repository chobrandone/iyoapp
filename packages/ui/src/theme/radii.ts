export const radii = {
  none: 0,
  /** Status pills. */
  xs: 6,
  /** Car marker. */
  sm: 8,
  /** Buttons, inputs, tiles, icon wells. */
  md: 10,
  /** Cards, map card, chat bubbles. */
  lg: 16,
  xl: 24,
  pill: 999,
} as const;

export type RadiusToken = keyof typeof radii;
