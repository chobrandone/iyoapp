import { useRef, useState } from 'react';
import { Pressable, StyleSheet, TextInput, View } from 'react-native';

import { useTheme } from '../theme';
import { FormField } from './FormField';
import { Text } from './Text';

type CodeInputBaseProps = {
  value: string;
  onChange: (value: string) => void;
  /** Called once all digits are entered. */
  onComplete?: (value: string) => void;
  label?: string;
  helper?: string;
  error?: string;
  autoFocus?: boolean;
  disabled?: boolean;
  /** Hide digits (e.g. PIN entry shown to others). */
  secure?: boolean;
  accessibilityLabel?: string;
};

type CodeInputProps = CodeInputBaseProps & {
  length: number;
  /** `boxes` = one 58 px box per digit (OTP); `field` = digits spaced inside one input (PIN). */
  appearance: 'boxes' | 'field';
  textContentType?: 'oneTimeCode' | 'none';
};

/**
 * Digit entry backed by a single hidden TextInput, so paste, SMS autofill
 * (iOS oneTimeCode / Android sms-otp) and backspace behave natively.
 */
function CodeInput({
  length,
  appearance,
  value,
  onChange,
  onComplete,
  label,
  helper,
  error,
  autoFocus,
  disabled = false,
  secure = false,
  accessibilityLabel,
  textContentType = 'none',
}: CodeInputProps) {
  const theme = useTheme();
  const inputRef = useRef<TextInput>(null);
  const [focused, setFocused] = useState(false);

  const handleChange = (text: string) => {
    const digits = text.replace(/\D/g, '').slice(0, length);
    onChange(digits);
    if (digits.length === length) onComplete?.(digits);
  };

  const chars = Array.from({ length }, (_, i) => value[i] ?? '');
  const display = (c: string) => (secure && c ? '•' : c);
  const activeIndex = Math.min(value.length, length - 1);
  const borderFor = (active: boolean) =>
    error ? theme.colors.danger : active ? theme.colors.accent : theme.colors.border;

  return (
    <FormField label={label} helper={helper} error={error}>
      <Pressable
        onPress={() => inputRef.current?.focus()}
        disabled={disabled}
        accessible={false}
        style={{ opacity: disabled ? 0.5 : 1 }}
      >
        {appearance === 'boxes' ? (
          <View style={[styles.row, { gap: theme.spacing.sm }]}>
            {chars.map((c, i) => {
              const active = focused && i === activeIndex;
              return (
                <View
                  key={i}
                  style={[
                    styles.box,
                    {
                      height: theme.sizes.digitHeight,
                      borderRadius: theme.radii.md,
                      borderWidth: active || error ? 2 : 1,
                      borderColor: borderFor(active),
                    },
                  ]}
                >
                  <Text variant="digit" color="black">
                    {display(c)}
                  </Text>
                </View>
              );
            })}
          </View>
        ) : (
          <View
            style={[
              styles.field,
              {
                minHeight: theme.sizes.inputMinHeight,
                borderRadius: theme.radii.md,
                borderWidth: focused || error ? 2 : 1,
                borderColor: borderFor(focused),
                paddingHorizontal: focused || error ? 12 : 13,
              },
            ]}
          >
            {chars.map((c, i) => (
              <Text key={i} variant="input" color={c ? 'ink' : 'muted'} style={styles.fieldDigit}>
                {c ? display(c) : '–'}
              </Text>
            ))}
          </View>
        )}
      </Pressable>
      <TextInput
        ref={inputRef}
        value={value}
        onChangeText={handleChange}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        keyboardType="number-pad"
        inputMode="numeric"
        maxLength={length}
        autoFocus={autoFocus}
        editable={!disabled}
        textContentType={textContentType}
        autoComplete={textContentType === 'oneTimeCode' ? 'sms-otp' : 'off'}
        secureTextEntry={secure}
        caretHidden
        accessibilityLabel={accessibilityLabel ?? label}
        style={styles.hiddenInput}
      />
    </FormField>
  );
}

export type OtpInputProps = CodeInputBaseProps;
export type PinInputProps = CodeInputBaseProps;

/** 6-digit SMS verification code, one box per digit (Figma 2005:50088). */
export function OtpInput(props: OtpInputProps) {
  return <CodeInput {...props} length={6} appearance="boxes" textContentType="oneTimeCode" />;
}

/** 4-digit pickup PIN entered by the driver (Figma 2005:51465). */
export function PinInput(props: PinInputProps) {
  return <CodeInput {...props} length={4} appearance="field" />;
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row' },
  box: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  field: { flexDirection: 'row', alignItems: 'center', gap: 24 },
  fieldDigit: { minWidth: 10, textAlign: 'center' },
  hiddenInput: { position: 'absolute', width: 1, height: 1, opacity: 0 },
});
