/** Spacing scale. Screens use `screenPadding` (24) as their horizontal gutter. */
export const spacing = {
  none: 0,
  xxs: 2,
  xs: 4,
  sm: 8,
  /** Gap between stacked cards in a content column (Figma: 14). */
  stack: 14,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  huge: 48,
  screenPadding: 24,
} as const;

export type SpacingToken = keyof typeof spacing;

/** Fixed sizes measured from the Figma components. */
export const sizes = {
  buttonHeight: 52,
  buttonSmallHeight: 40,
  inputMinHeight: 48,
  digitHeight: 58,
  minTouchTarget: 44,
  /** Header row height (wordmark + flow label). */
  headerHeight: 44,
  icon: 22,
  iconSmall: 18,
  iconTab: 20,
  iconStroke: 1.75,
  iconWell: 36,
  tabBarHeight: 64,
  tileHeight: 64,
  serviceOptionHeight: 56,
  portrait: 52,
  avatar: 56,
  contactButton: 40,
  mapRecenter: 36,
} as const;
