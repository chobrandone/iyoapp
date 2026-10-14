import type { ViewStyle } from 'react-native';

import { colors } from './colors';

/** Cross-platform elevation presets (iOS shadow* props + Android elevation). */
export const shadows = {
  none: {},
  card: {
    shadowColor: colors.black,
    shadowOpacity: 0.06,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 4 },
    elevation: 2,
  },
  floating: {
    shadowColor: colors.black,
    shadowOpacity: 0.12,
    shadowRadius: 20,
    shadowOffset: { width: 0, height: 8 },
    elevation: 6,
  },
} as const satisfies Record<string, ViewStyle>;

export type ShadowToken = keyof typeof shadows;
