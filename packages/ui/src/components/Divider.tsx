import { StyleSheet, View, type ViewStyle } from 'react-native';

import { useTheme } from '../theme';

export function Divider({ style }: { style?: ViewStyle }) {
  const theme = useTheme();
  return (
    <View
      style={[
        { height: StyleSheet.hairlineWidth * 2, backgroundColor: theme.colors.border },
        style,
      ]}
    />
  );
}
