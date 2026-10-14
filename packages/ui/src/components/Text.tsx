import { Text as RNText, type TextProps as RNTextProps } from 'react-native';

import { useTheme, type Theme, type TypographyVariant } from '../theme';

export type TextProps = RNTextProps & {
  variant?: TypographyVariant;
  color?: keyof Theme['colors'];
  align?: 'auto' | 'left' | 'center' | 'right';
};

/** The only text primitive apps should use; enforces Poppins and colour tokens. */
export function Text({ variant = 'body', color = 'ink', align, style, ...rest }: TextProps) {
  const theme = useTheme();
  return (
    <RNText
      maxFontSizeMultiplier={1.6}
      {...rest}
      style={[
        theme.typography[variant],
        { color: theme.colors[color] },
        align ? { textAlign: align } : null,
        style,
      ]}
    />
  );
}
