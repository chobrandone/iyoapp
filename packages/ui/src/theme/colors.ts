/**
 * Colour tokens from the iyodriver Figma file.
 * Apps must use these tokens (via `useTheme()` or `colors`) and never hard-code hex values.
 */
export const colors = {
  primary: '#F6C200',
  /** ~15% tint of primary: highlight cards, badges, selected ride card. */
  primarySoft: '#FFF6D6',
  ink: '#191919',
  charcoal: '#312C2C',
  black: '#000000',
  danger: '#FF0000',
  success: '#008011',
  muted: '#AFAFAF',
  white: '#FFFFFF',
  /** Light warm grey: secondary buttons, list cards, map card background. */
  surface: '#F5F5F0',

  // Derived tokens (not named in the Figma styles; verify against frames in Phase 2).
  /** Hairline borders and dividers. */
  border: '#E8E8E3',
  /** Tinted backgrounds for danger / success badges. */
  dangerSoft: '#FFE5E5',
  successSoft: '#E5F2E7',
  /** Scrim behind sheets and modals. */
  overlay: 'rgba(25, 25, 25, 0.48)',
  transparent: 'transparent',
} as const;

export type ColorToken = keyof typeof colors;
export type ColorValue = (typeof colors)[ColorToken];
