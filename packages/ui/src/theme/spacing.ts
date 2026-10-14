/** 4-pt spacing scale. Screens use `screenPadding` (24) as their horizontal gutter. */
export const spacing = {
  none: 0,
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  huge: 48,
  screenPadding: 24,
} as const;

export type SpacingToken = keyof typeof spacing;

/** Fixed sizes used across components. */
export const sizes = {
  buttonHeight: 52,
  inputHeight: 52,
  minTouchTarget: 44,
  icon: 22,
  iconLarge: 24,
  iconStroke: 1.75,
  tabBarHeight: 64,
  avatar: 48,
} as const;
