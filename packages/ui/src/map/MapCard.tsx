import Constants, { ExecutionEnvironment } from 'expo-constants';
import LocateFixed from 'lucide-react-native/icons/locate-fixed';
import { useEffect, useRef } from 'react';
import { Platform, StyleSheet, View } from 'react-native';
import MapView, { PROVIDER_DEFAULT, PROVIDER_GOOGLE } from 'react-native-maps';

import { IconButton } from '../components/IconButton';
import { useTheme } from '../theme';
import { iyoMapStyle } from './mapStyle';
import type { MapCardProps } from './types';

// Expo Go on iOS ships without the Google Maps SDK, so fall back to Apple Maps there.
const isExpoGo = Constants.executionEnvironment === ExecutionEnvironment.StoreClient;
const provider = Platform.OS === 'android' || !isExpoGo ? PROVIDER_GOOGLE : PROVIDER_DEFAULT;

/** Figma "Live map": rounded (16) map with an optional white recenter button. */
export function MapCard({
  center,
  delta = 0.018,
  height = 220,
  onRecenter,
  recenterLabel = 'Recenter map',
  showsUserLocation = false,
  fitTo,
  style,
  children,
}: MapCardProps) {
  const theme = useTheme();
  const mapRef = useRef<MapView>(null);

  useEffect(() => {
    if (!fitTo || fitTo.length < 2) return;
    mapRef.current?.fitToCoordinates([...fitTo], {
      edgePadding: { top: 40, right: 40, bottom: 56, left: 40 },
      animated: true,
    });
  }, [fitTo]);

  return (
    <View
      style={[
        styles.card,
        { height, borderRadius: theme.radii.lg, backgroundColor: theme.colors.mapBackground },
        style,
      ]}
    >
      <MapView
        ref={mapRef}
        provider={provider}
        style={StyleSheet.absoluteFill}
        initialRegion={{ ...center, latitudeDelta: delta, longitudeDelta: delta }}
        customMapStyle={provider === PROVIDER_GOOGLE ? iyoMapStyle : undefined}
        showsUserLocation={showsUserLocation}
        showsMyLocationButton={false}
        showsCompass={false}
        showsPointsOfInterests={false}
        toolbarEnabled={false}
        pitchEnabled={false}
        rotateEnabled={false}
        loadingEnabled
        loadingBackgroundColor={theme.colors.mapBackground}
        loadingIndicatorColor={theme.colors.ink}
      >
        {children}
      </MapView>
      {onRecenter ? (
        <IconButton
          icon={LocateFixed}
          tone="white"
          size={theme.sizes.mapRecenter}
          iconSize={theme.sizes.iconSmall}
          accessibilityLabel={recenterLabel}
          onPress={() => {
            mapRef.current?.animateToRegion({
              ...center,
              latitudeDelta: delta,
              longitudeDelta: delta,
            });
            onRecenter();
          }}
          style={styles.recenter}
        />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  card: { overflow: 'hidden', alignSelf: 'stretch' },
  recenter: { position: 'absolute', right: 12, bottom: 12 },
});
