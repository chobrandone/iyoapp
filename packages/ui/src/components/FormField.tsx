import type { ReactNode } from 'react';
import { View } from 'react-native';

import { Text } from './Text';

export type FormFieldProps = {
  label?: string;
  /** Helper text under the control ("We'll text you a 6-digit verification code."). */
  helper?: string;
  /** Error text; replaces helper and turns red. */
  error?: string;
  children: ReactNode;
};

/** Figma "Form field": 11 px Medium label, control, 10 px helper; gap 6. */
export function FormField({ label, helper, error, children }: FormFieldProps) {
  return (
    <View style={{ gap: 6, alignSelf: 'stretch' }}>
      {label ? (
        <Text variant="captionMedium" color="charcoal">
          {label}
        </Text>
      ) : null}
      {children}
      {error ? (
        <Text variant="helper" color="danger" accessibilityLiveRegion="polite">
          {error}
        </Text>
      ) : helper ? (
        <Text variant="helper" color="textSecondary">
          {helper}
        </Text>
      ) : null}
    </View>
  );
}
