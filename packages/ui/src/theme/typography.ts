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

/** Sizes measured from the 390 × 844 Figma frames (line height 1.5 unless noted). */
export const typography = {
  /** Welcome / onboarding headline. */
  hero: variant('semibold', 36, 44, { letterSpacing: -0.5 }),
  /** Page heading title, e.g. "Where to, Amelia?". */
  title: variant('semibold', 24, 36),
  /** Profile name in identity cards (line height 1.6). */
  heading: variant('semibold', 16, 25.6),
  /** Information card title, e.g. "You're in a busy area". */
  cardTitle: variant('semibold', 15, 22.5),
  /** Person name next to a portrait. */
  subheading: variant('semibold', 14, 21),
  /** Section headings ("Today") and service option labels. */
  bodyStrong: variant('semibold', 13, 19.5),
  /** List row titles. */
  rowTitle: variant('medium', 13, 19.5),
  /** Text field value. */
  input: variant('regular', 13, 19.5),
  /** Page subtitles, chat messages, card body copy. */
  body: variant('regular', 12, 18),
  /** Row subtitles, footnotes. */
  caption: variant('regular', 11, 16.5),
  /** Form field labels and inline links. */
  captionMedium: variant('medium', 11, 16.5),
  /** Field helper text. */
  helper: variant('regular', 10, 15),
  /** Action tile labels. */
  tileLabel: variant('medium', 10, 15),
  /** Status pills, e.g. "YOUR PICKUP PIN · 4826". */
  status: variant('medium', 10, 15, { textTransform: 'uppercase' }),
  /** Timestamps under chat bubbles and notification cards. */
  micro: variant('regular', 9, 13.5),
  /** Flow label in the header, e.g. "RIDER · 01". */
  label: variant('medium', 9, 13.5, { letterSpacing: 0.3, textTransform: 'uppercase' }),
  tab: variant('regular', 9, 13.5),
  tabActive: variant('semibold', 9, 13.5),
  button: variant('semibold', 14, 21),
  buttonSmall: variant('semibold', 12, 18),
  /** One digit of an OTP / PIN box. */
  digit: variant('medium', 23, 30),
  /** Initials inside a 56 px avatar. */
  avatar: variant('semibold', 19, 28.5),
  wordmark: variant('bold', 17, 25.5),
} as const satisfies Record<string, TextStyle>;

export type TypographyVariant = keyof typeof typography;
