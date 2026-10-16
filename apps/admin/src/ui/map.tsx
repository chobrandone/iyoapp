// A real Douala street map (MapLibre + OpenFreeMap tiles, no API key) with car and pickup markers.
// MapLibre loads on first use so pages without a map stay light; without WebGL the map shows a
// plain placeholder.
import { LocateFixed } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';

import type { GeoPoint } from '@/data/models';

export type MarkerKind = 'car' | 'car_available' | 'car_pickup' | 'pickup' | 'dropoff';

export interface MapMarker {
  id: string;
  at: GeoPoint;
  kind: MarkerKind;
  label: string;
  onClick?: () => void;
}

const STYLE_URL = 'https://tiles.openfreemap.org/styles/positron';
const DOUALA: GeoPoint = { lat: 4.0511, lng: 9.7085 };

const CAR_SVG =
  '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21 8-2 2-1.5-3.7A2 2 0 0 0 15.646 5H8.4a2 2 0 0 0-1.903 1.257L5 10 3 8"/><path d="M7 14h.01"/><path d="M17 14h.01"/><rect width="18" height="8" x="3" y="10" rx="2"/><path d="M5 18v2"/><path d="M19 18v2"/></svg>';

function markerElement(m: MapMarker): HTMLElement {
  const el = document.createElement(m.onClick ? 'button' : 'div');
  el.setAttribute('aria-label', m.label);
  el.title = m.label;
  if (m.kind === 'pickup' || m.kind === 'dropoff') {
    el.className =
      m.kind === 'pickup'
        ? 'flex size-9 items-center justify-center rounded-full bg-[#f6c200]/30'
        : 'flex size-5 items-center justify-center rounded-full bg-white shadow';
    el.innerHTML = '<span class="block size-2.5 rounded-full bg-[#191919]"></span>';
  } else {
    const bg =
      m.kind === 'car_available'
        ? 'bg-[#008031]'
        : m.kind === 'car_pickup'
          ? 'bg-[#f6c200]'
          : 'bg-[#191919]';
    el.className = `flex h-7 w-[38px] items-center justify-center rounded-lg ${bg} shadow-md`;
    el.innerHTML = CAR_SVG;
    if (m.kind === 'car_pickup') el.querySelector('svg')?.setAttribute('stroke', '#191919');
  }
  if (m.onClick) {
    (el as HTMLButtonElement).type = 'button';
    el.style.cursor = 'pointer';
    el.addEventListener('click', (e) => {
      e.stopPropagation();
      m.onClick?.();
    });
  }
  return el;
}

export function OpsMap({
  height,
  markers,
  route,
  label,
  zoom = 13,
}: {
  height: number;
  markers: MapMarker[];
  /** Pickup → drop-off line. */
  route?: [GeoPoint, GeoPoint];
  label: string;
  zoom?: number;
}) {
  const { t } = useTranslation();
  const box = useRef<HTMLDivElement>(null);
  const map = useRef<import('maplibre-gl').Map | null>(null);
  const lib = useRef<typeof import('maplibre-gl') | null>(null);
  const placed = useRef<import('maplibre-gl').Marker[]>([]);
  const [failed, setFailed] = useState(false);
  const [ready, setReady] = useState(false);

  const signature = JSON.stringify([markers.map((x) => [x.id, x.kind, x.at]), route]);

  const fit = () => {
    const m = map.current;
    const points = [...markers.map((x) => x.at), ...(route ?? [])];
    if (!m || !lib.current) return;
    if (points.length < 2) {
      m.jumpTo({ center: points[0] ?? DOUALA, zoom });
      return;
    }
    const b = new lib.current.LngLatBounds();
    for (const p of points) b.extend([p.lng, p.lat]);
    m.fitBounds(b, { padding: 48, maxZoom: 15, duration: 0 });
  };

  // Create the map once.
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        const [maplibre] = await Promise.all([
          import('maplibre-gl'),
          import('maplibre-gl/dist/maplibre-gl.css'),
        ]);
        if (cancelled || !box.current) return;
        lib.current = maplibre;
        const m = new maplibre.Map({
          container: box.current,
          style: STYLE_URL,
          center: [DOUALA.lng, DOUALA.lat],
          zoom,
          attributionControl: { compact: true },
          cooperativeGestures: true,
        });
        m.on('load', () => {
          if (cancelled) return;
          // Keep the credits as the small (i) button so they don't cover small maps.
          box.current
            ?.querySelector('.maplibregl-ctrl-attrib')
            ?.classList.remove('maplibregl-compact-show');
          setReady(true);
        });
        m.on('error', () => undefined);
        map.current = m;
      } catch {
        if (!cancelled) setFailed(true);
      }
    })();
    return () => {
      cancelled = true;
      map.current?.remove();
      map.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Markers and the route follow the data.
  useEffect(() => {
    const m = map.current;
    const maplibre = lib.current;
    if (!m || !maplibre || !ready) return;
    for (const p of placed.current) p.remove();
    placed.current = markers.map((x) =>
      new maplibre.Marker({ element: markerElement(x) }).setLngLat([x.at.lng, x.at.lat]).addTo(m),
    );
    const data = {
      type: 'Feature' as const,
      properties: {},
      geometry: {
        type: 'LineString' as const,
        coordinates: route ? route.map((p) => [p.lng, p.lat]) : [],
      },
    };
    const source = m.getSource('route') as import('maplibre-gl').GeoJSONSource | undefined;
    if (source) source.setData(data);
    else {
      m.addSource('route', { type: 'geojson', data });
      m.addLayer({
        id: 'route-casing',
        type: 'line',
        source: 'route',
        paint: { 'line-color': '#191919', 'line-width': 7 },
        layout: { 'line-cap': 'round', 'line-join': 'round' },
      });
      m.addLayer({
        id: 'route',
        type: 'line',
        source: 'route',
        paint: { 'line-color': '#f6c200', 'line-width': 4 },
        layout: { 'line-cap': 'round', 'line-join': 'round' },
      });
    }
    fit();
    // Re-place only when what is shown changes, so refreshes don't reset the view.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [signature, ready]);

  return (
    <div
      role="region"
      aria-label={label}
      className="relative overflow-hidden rounded-2xl bg-map"
      style={{ height }}
    >
      {/* Inline: MapLibre's stylesheet sets position: relative on the container. */}
      <div ref={box} style={{ position: 'absolute', inset: 0 }} />
      {failed && (
        <p className="absolute inset-0 flex items-center justify-center text-[11px] text-sub">
          {t('mapUnavailable')}
        </p>
      )}
      <button
        type="button"
        onClick={fit}
        aria-label={t('recenter', 'Recenter map')}
        className="absolute top-3 right-3 flex size-9 cursor-pointer items-center justify-center rounded-full bg-white shadow"
      >
        <LocateFixed size={18} aria-hidden />
      </button>
    </div>
  );
}
