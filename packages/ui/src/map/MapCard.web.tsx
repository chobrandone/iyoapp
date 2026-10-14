import LocateFixed from 'lucide-react-native/icons/locate-fixed';
import MapPinned from 'lucide-react-native/icons/map-pinned';
import { StyleSheet, View } from 'react-native';

import { Icon } from '../components/Icon';
import { IconButton } from '../components/IconButton';
import { Text } from '../components/Text';
import { useTheme } from '../theme';
import type { MapCardProps } from './types';

/**
 * Web has no react-native-maps. This placeholder keeps layout and chrome identical
 * so screens and the component gallery can be reviewed in a browser.
 */
export function MapCard({
  center,
  height = 220,
  onRecenter,
  recenterLabel = 'Recenter map',
  style,
  children,
}: MapCardProps) {
  const theme = useTheme();
  return (
    <View
      style={[
        styles.card,
        { height, borderRadius: theme.radii.lg, backgroundColor: theme.colors.mapBackground },
        style,
      ]}
    >
      <View style={styles.center}>
        <Icon icon={MapPinned} color="textSecondary" />
        <Text variant="micro" color="textSecondary">
          {center.latitude.toFixed(4)}, {center.longitude.toFixed(4)}
        </Text>
      </View>
      <View style={styles.overlay} pointerEvents="none">
        {children}
      </View>
      {onRecenter ? (
        <IconButton
          icon={LocateFixed}
          tone="white"
          size={theme.sizes.mapRecenter}
          iconSize={theme.sizes.iconSmall}
          accessibilityLabel={recenterLabel}
          onPress={onRecenter}
          style={styles.recenter}
        />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  card: { overflow: 'hidden', alignSelf: 'stretch' },
  center: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 4,
  },
  overlay: {
    ...StyleSheet.absoluteFill,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-evenly',
  },
  recenter: { position: 'absolute', right: 12, bottom: 12 },
});
