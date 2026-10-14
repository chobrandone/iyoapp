import type { ReactNode } from 'react';
import type { ViewStyle } from 'react-native';

export type LatLng = { latitude: number; longitude: number };

export type MapCardProps = {
  /** Map centre on first render. */
  center: LatLng;
  /** Approximate visible span in degrees (default ≈ 2 km). */
  delta?: number;
  /** Figma heights: 220 (home), 230–275 (trip screens). */
  height?: number;
  /** Shows the white 36 px recenter button bottom-right. */
  onRecenter?: () => void;
  recenterLabel?: string;
  showsUserLocation?: boolean;
  /** Fit the camera to these points (route bounds) whenever they change. */
  fitTo?: readonly LatLng[];
  style?: ViewStyle;
  children?: ReactNode;
};

export type CarMarkerProps = {
  coordinate: LatLng;
  /** Compass heading in degrees; rotates the marker. */
  heading?: number;
  accessibilityLabel?: string;
};

export type PointMarkerProps = {
  coordinate: LatLng;
  accessibilityLabel?: string;
};

export type RoutePolylineProps = {
  coordinates: readonly LatLng[];
};

/** Douala city centre (Akwa), used as a default when no location is known yet. */
export const DOUALA_CENTER: LatLng = { latitude: 4.0511, longitude: 9.7679 };
/** Yaoundé city centre. */
export const YAOUNDE_CENTER: LatLng = { latitude: 3.848, longitude: 11.5021 };
