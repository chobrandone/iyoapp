import { forwardRef, useState, type ReactNode } from 'react';
import { StyleSheet, TextInput, View, type TextInputProps } from 'react-native';

import { fontFamily, useTheme } from '../theme';
import { FormField } from './FormField';
import { Text } from './Text';

export type TextFieldProps = Omit<TextInputProps, 'style' | 'placeholderTextColor'> & {
  label?: string;
  helper?: string;
  error?: string;
  /** Fixed text before the input, e.g. "+237". */
  prefix?: string;
  left?: ReactNode;
  right?: ReactNode;
};

/**
 * Figma "Input": min 48 px, padding 13, radius 10, 1 px #E9E9E6 border,
 * 2 px primary border when focused, 13 px Regular value.
 */
export const TextField = forwardRef<TextInput, TextFieldProps>(function TextField(
  { label, helper, error, prefix, left, right, onFocus, onBlur, editable = true, ...inputProps },
  ref,
) {
  const theme = useTheme();
  const [focused, setFocused] = useState(false);
  const borderColor = error
    ? theme.colors.danger
    : focused
      ? theme.colors.accent
      : theme.colors.border;
  const borderWidth = focused || error ? 2 : 1;

  return (
    <FormField label={label} helper={helper} error={error}>
      <View
        style={[
          styles.box,
          {
            minHeight: theme.sizes.inputMinHeight,
            borderRadius: theme.radii.md,
            borderColor,
            borderWidth,
            // Keep content from shifting when the border thickens.
            paddingHorizontal: 13 - (borderWidth - 1),
            backgroundColor: editable ? theme.colors.white : theme.colors.surface,
            gap: theme.spacing.sm,
          },
        ]}
      >
        {left}
        {prefix ? <Text variant="input">{prefix}</Text> : null}
        <TextInput
          ref={ref}
          editable={editable}
          accessibilityLabel={label}
          placeholderTextColor={theme.colors.muted}
          selectionColor={theme.colors.accent}
          cursorColor={theme.colors.ink}
          maxFontSizeMultiplier={1.6}
          onFocus={(e) => {
            setFocused(true);
            onFocus?.(e);
          }}
          onBlur={(e) => {
            setFocused(false);
            onBlur?.(e);
          }}
          style={[
            styles.input,
            { fontFamily: fontFamily.regular, color: theme.colors.ink },
            inputProps.multiline ? styles.multiline : null,
          ]}
          {...inputProps}
        />
        {right}
      </View>
    </FormField>
  );
});

const styles = StyleSheet.create({
  box: { flexDirection: 'row', alignItems: 'center' },
  input: { flex: 1, fontSize: 13, paddingVertical: 12, minHeight: 44 },
  multiline: { minHeight: 88, textAlignVertical: 'top' },
});
