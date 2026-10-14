import { createContext, useContext, useMemo, type ReactNode } from 'react';

import { colors } from './colors';
import { radii } from './radii';
import { shadows } from './shadows';
import { sizes, spacing } from './spacing';
import { typography } from './typography';

/**
 * The small set of tokens an app may override without touching components
 * (e.g. a distinct accent for the driver app later).
 */
export type ThemeOverrides = {
  accent?: string;
  accentSoft?: string;
  /** Text/icon colour drawn on top of `accent`. */
  onAccent?: string;
};

export type Theme = {
  colors: typeof colors & { accent: string; accentSoft: string; onAccent: string };
  typography: typeof typography;
  spacing: typeof spacing;
  sizes: typeof sizes;
  radii: typeof radii;
  shadows: typeof shadows;
};

export function createTheme(overrides: ThemeOverrides = {}): Theme {
  return {
    colors: {
      ...colors,
      accent: overrides.accent ?? colors.primary,
      accentSoft: overrides.accentSoft ?? colors.primarySoft,
      onAccent: overrides.onAccent ?? colors.ink,
    },
    typography,
    spacing,
    sizes,
    radii,
    shadows,
  };
}

const defaultTheme = createTheme();
const ThemeContext = createContext<Theme>(defaultTheme);

export function ThemeProvider({
  overrides,
  children,
}: {
  overrides?: ThemeOverrides;
  children: ReactNode;
}) {
  const accent = overrides?.accent;
  const accentSoft = overrides?.accentSoft;
  const onAccent = overrides?.onAccent;
  const theme = useMemo(
    () => createTheme({ accent, accentSoft, onAccent }),
    [accent, accentSoft, onAccent],
  );
  return <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>;
}

export function useTheme(): Theme {
  return useContext(ThemeContext);
}
