import { CarGlyph, PointGlyph } from './MarkerGlyphs';
import type { CarMarkerProps, PointMarkerProps, RoutePolylineProps } from './types';

// Web preview: render the glyphs inline inside the MapCard placeholder (no geo-positioning).

export function CarMarker({ heading }: CarMarkerProps) {
  return <CarGlyph heading={heading} />;
}

export function PickupMarker(_props: PointMarkerProps) {
  return <PointGlyph halo />;
}

export function DestinationMarker(_props: PointMarkerProps) {
  return <PointGlyph />;
}

export function RoutePolyline(_props: RoutePolylineProps) {
  return null;
}
