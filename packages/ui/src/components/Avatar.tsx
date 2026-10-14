import { Image } from 'expo-image';
import { StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Text } from './Text';

export type AvatarProps = {
  name: string;
  uri?: string | null;
  size?: number;
};

export function initialsOf(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  const first = parts[0]?.[0] ?? '';
  const last = parts.length > 1 ? (parts[parts.length - 1]?.[0] ?? '') : '';
  return (first + last).toUpperCase();
}

/** Portrait photo, or initials on the pale-yellow circle when there is no photo. */
export function Avatar({ name, uri, size }: AvatarProps) {
  const theme = useTheme();
  const diameter = size ?? theme.sizes.avatar;
  const shape = { width: diameter, height: diameter, borderRadius: diameter / 2 };

  if (uri) {
    return (
      <Image
        source={{ uri }}
        style={[shape, { backgroundColor: theme.colors.surface }]}
        contentFit="cover"
        accessibilityLabel={name}
      />
    );
  }

  return (
    <View
      style={[styles.initials, shape, { backgroundColor: theme.colors.accentSoft }]}
      accessibilityLabel={name}
    >
      <Text
        variant="avatar"
        style={diameter < 48 ? { fontSize: diameter * 0.36, lineHeight: diameter * 0.5 } : null}
      >
        {initialsOf(name)}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  initials: { alignItems: 'center', justifyContent: 'center' },
});
