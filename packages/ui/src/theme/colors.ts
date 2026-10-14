/**
 * Colour tokens from the iyodriver Figma file.
 * Apps must use these tokens (via `useTheme()` or `colors`) and never hard-code hex values.
 */
export const colors = {
  primary: '#F6C200',
  /** Pale yellow used for highlight cards, status pills, contact buttons and "my" chat bubbles. */
  primarySoft: '#FFF8DC',
  ink: '#191919',
  /** Body copy inside highlight cards and form field labels. */
  charcoal: '#312C2C',
  black: '#000000',
  danger: '#FF0000',
  success: '#008011',
  /** Secondary text: subtitles, captions, inactive tab labels (#747474 in every Figma frame). */
  textSecondary: '#747474',
  /** Placeholders, disabled text and inactive icons. */
  muted: '#AFAFAF',
  white: '#FFFFFF',
  /** Light warm grey: secondary buttons, list cards, icon wells, chat bubbles. */
  surface: '#F6F6F3',
  /** Hairline borders, dividers and the tab bar top border. */
  border: '#E9E9E6',
  /** Background behind map tiles while they load. */
  mapBackground: '#ECEEE9',
  /** Parks and water in the Google map style. */
  mapPark: '#DCE8D8',
  mapWater: '#D3E3EA',
  /** Pale green behind "Accepting ride requests"-style success pills. */
  successSoft: '#EDF7EF',
  /** Pale red behind danger pills (derived; no Figma reference yet). */
  dangerSoft: '#FFECEC',
  /** Scrim behind sheets and modals. */
  overlay: 'rgba(25, 25, 25, 0.48)',
  /** Pickup halo on maps: primary at 22% opacity. */
  primaryHalo: 'rgba(246, 194, 0, 0.22)',
  transparent: 'transparent',
} as const;

export type ColorToken = keyof typeof colors;
export type ColorValue = (typeof colors)[ColorToken];
