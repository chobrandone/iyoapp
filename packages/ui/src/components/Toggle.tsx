import { useEffect, useState } from 'react';
import { Animated, Pressable, StyleSheet, View } from 'react-native';

import { useTheme } from '../theme';
import { Text } from './Text';

export type ToggleProps = {
  value: boolean;
  onValueChange: (value: boolean) => void;
  /** Row label; when given the whole row is pressable. */
  label?: string;
  description?: string;
  disabled?: boolean;
  accessibilityLabel?: string;
};

const TRACK_W = 44;
const TRACK_H = 26;
const KNOB = 20;

/** Switch with the primary yellow track when on. No Figma frame shows one; styled to match buttons. */
export function Toggle({
  value,
  onValueChange,
  label,
  description,
  disabled = false,
  accessibilityLabel,
}: ToggleProps) {
  const theme = useTheme();
  const [progress] = useState(() => new Animated.Value(value ? 1 : 0));

  useEffect(() => {
    Animated.timing(progress, {
      toValue: value ? 1 : 0,
      duration: 160,
      useNativeDriver: false,
    }).start();
  }, [progress, value]);

  const trackColor = progress.interpolate({
    inputRange: [0, 1],
    outputRange: [theme.colors.border, theme.colors.accent],
  });
  const translateX = progress.interpolate({
    inputRange: [0, 1],
    outputRange: [3, TRACK_W - KNOB - 3],
  });

  const track = (
    <Animated.View style={[styles.track, { backgroundColor: trackColor }]}>
      <Animated.View
        style={[
          styles.knob,
          { backgroundColor: theme.colors.white, transform: [{ translateX }] },
          theme.shadows.card,
        ]}
      />
    </Animated.View>
  );

  return (
    <Pressable
      accessibilityRole="switch"
      accessibilityLabel={accessibilityLabel ?? label}
      accessibilityState={{ checked: value, disabled }}
      disabled={disabled}
      onPress={() => onValueChange(!value)}
      hitSlop={label ? 0 : 9}
      style={[label ? styles.row : null, { opacity: disabled ? 0.5 : 1, gap: theme.spacing.md }]}
    >
      {label ? (
        <View style={styles.flex}>
          <Text variant="rowTitle">{label}</Text>
          {description ? (
            <Text variant="caption" color="textSecondary">
              {description}
            </Text>
          ) : null}
        </View>
      ) : null}
      {track}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', minHeight: 44 },
  flex: { flex: 1 },
  track: { width: TRACK_W, height: TRACK_H, borderRadius: TRACK_H / 2, justifyContent: 'center' },
  knob: { width: KNOB, height: KNOB, borderRadius: KNOB / 2 },
});
