import type { TextStyle } from 'react-native';

/**
 * Poppins is the only typeface. Each weight is a separate font family name because
 * Android does not synthesise weights for custom fonts.
 */
export const fontFamily = {
  regular: 'Poppins_400Regular',
  medium: 'Poppins_500Medium',
  semibold: 'Poppins_600SemiBold',
  bold: 'Poppins_700Bold',
  extrabold: 'Poppins_800ExtraBold',
} as const;

export type FontWeightToken = keyof typeof fontFamily;

const variant = (
  family: FontWeightToken,
  fontSize: number,
  lineHeight: number,
  extra: TextStyle = {},
): TextStyle => ({ fontFamily: fontFamily[family], fontSize, lineHeight, ...extra });

export const typography = {
  /** Hero headlines, e.g. "Your city. Your way." */
  hero: variant('semibold', 36, 44, { letterSpacing: -0.5 }),
  /** Screen titles. */
  title: variant('semibold', 28, 36, { letterSpacing: -0.3 }),
  /** Section headings and card titles. */
  heading: variant('semibold', 20, 28),
  subheading: variant('semibold', 16, 24),
  bodyLarge: variant('regular', 16, 24),
  body: variant('regular', 14, 21),
  bodyMedium: variant('medium', 14, 21),
  caption: variant('regular', 12, 18),
  /** Small caps labels, e.g. "RIDER · 01", "WAIT TIME · 01:24". */
  label: variant('medium', 11, 16, { letterSpacing: 0.5, textTransform: 'uppercase' }),
  button: variant('semibold', 16, 24),
  wordmark: variant('extrabold', 20, 26, { letterSpacing: -0.4 }),
} as const satisfies Record<string, TextStyle>;

export type TypographyVariant = keyof typeof typography;
