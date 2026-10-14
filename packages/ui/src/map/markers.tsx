import { memo, useEffect, useState } from 'react';
import { Marker, Polyline } from 'react-native-maps';

import { useTheme } from '../theme';
import { CarGlyph, PointGlyph } from './MarkerGlyphs';
import type { CarMarkerProps, PointMarkerProps, RoutePolylineProps } from './types';

/**
 * Custom-view markers must track view changes until the view has rendered once
 * (or Android shows a blank marker), then stop to avoid re-rasterising every frame.
 */
function useTracksViewChanges(): boolean {
  const [tracks, setTracks] = useState(true);
  useEffect(() => {
    const id = setTimeout(() => setTracks(false), 500);
    return () => clearTimeout(id);
  }, []);
  return tracks;
}

/** Live car position. Rotation is applied natively via `rotation` so the view isn't re-rendered. */
export const CarMarker = memo(function CarMarker({
  coordinate,
  heading = 0,
  accessibilityLabel,
}: CarMarkerProps) {
  const tracksViewChanges = useTracksViewChanges();
  return (
    <Marker
      coordinate={coordinate}
      rotation={heading}
      flat
      anchor={{ x: 0.5, y: 0.5 }}
      tracksViewChanges={tracksViewChanges}
      accessibilityLabel={accessibilityLabel}
    >
      <CarGlyph />
    </Marker>
  );
});

/** Pickup point: dot with the yellow halo. */
export const PickupMarker = memo(function PickupMarker({
  coordinate,
  accessibilityLabel,
}: PointMarkerProps) {
  const tracksViewChanges = useTracksViewChanges();
  return (
    <Marker
      coordinate={coordinate}
      anchor={{ x: 0.5, y: 0.5 }}
      tracksViewChanges={tracksViewChanges}
      accessibilityLabel={accessibilityLabel}
    >
      <PointGlyph halo />
    </Marker>
  );
});

/** Destination point: same dot, no halo. */
export const DestinationMarker = memo(function DestinationMarker({
  coordinate,
  accessibilityLabel,
}: PointMarkerProps) {
  const tracksViewChanges = useTracksViewChanges();
  return (
    <Marker
      coordinate={coordinate}
      anchor={{ x: 0.5, y: 0.5 }}
      tracksViewChanges={tracksViewChanges}
      accessibilityLabel={accessibilityLabel}
    >
      <PointGlyph />
    </Marker>
  );
});

/** Figma route: 7 px ink outline under a 4 px primary line. */
export const RoutePolyline = memo(function RoutePolyline({ coordinates }: RoutePolylineProps) {
  const theme = useTheme();
  if (coordinates.length < 2) return null;
  const coords = [...coordinates];
  return (
    <>
      <Polyline
        coordinates={coords}
        strokeColor={theme.colors.ink}
        strokeWidth={7}
        lineCap="round"
        lineJoin="round"
        zIndex={1}
      />
      <Polyline
        coordinates={coords}
        strokeColor={theme.colors.accent}
        strokeWidth={4}
        lineCap="round"
        lineJoin="round"
        zIndex={2}
      />
    </>
  );
});
