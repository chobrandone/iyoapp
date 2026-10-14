import CarFront from 'lucide-react-native/icons/car-front';
import { StyleSheet, View } from 'react-native';

import { Icon } from '../components/Icon';
import { useTheme } from '../theme';

/** Figma "Car marker": 38 × 28 ink rounded rect (radius 8) with a white 22 px car. */
export function CarGlyph({ heading = 0 }: { heading?: number }) {
  const theme = useTheme();
  return (
    <View
      style={[
        styles.car,
        {
          backgroundColor: theme.colors.ink,
          borderRadius: theme.radii.sm,
          transform: [{ rotate: `${heading}deg` }],
        },
      ]}
    >
      <Icon icon={CarFront} size={theme.sizes.icon} color="white" />
    </View>
  );
}

/** Figma "Pickup marker": 8 px ink dot in a 16 px white ring, optional 42 px yellow halo (22%). */
export function PointGlyph({ halo = false }: { halo?: boolean }) {
  const theme = useTheme();
  return (
    <View style={[styles.pointWrap, halo ? styles.haloSize : styles.dotSize]}>
      {halo ? <View style={[styles.halo, { backgroundColor: theme.colors.primaryHalo }]} /> : null}
      <View style={[styles.ring, { backgroundColor: theme.colors.white }]}>
        <View style={[styles.dot, { backgroundColor: theme.colors.ink }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  car: { width: 38, height: 28, alignItems: 'center', justifyContent: 'center' },
  pointWrap: { alignItems: 'center', justifyContent: 'center' },
  haloSize: { width: 42, height: 42 },
  dotSize: { width: 16, height: 16 },
  halo: { position: 'absolute', width: 42, height: 42, borderRadius: 21 },
  ring: { width: 16, height: 16, borderRadius: 8, alignItems: 'center', justifyContent: 'center' },
  dot: { width: 8, height: 8, borderRadius: 4 },
});
