// Free OpenStreetMap search and routing, used while no Google key is set. Photon allows
// search-as-you-type (Nominatim does not). The public OSRM server has no uptime promise, so a
// failed route falls back to a straight-line estimate; use Google or a paid host at scale.
import type { LatLng, PlaceDetails, PlaceSuggestion, RouteResult } from './google.ts';
import { HttpError } from './http.ts';

/** Africa, so a search never returns a same-named place on another continent. */
const AFRICA_BBOX = '-26,-35,52,38';
const BANGUI: LatLng = { lat: 4.3733, lng: 18.5628 };
const HEADERS = { 'User-Agent': 'iyodriver-server' };

/** Streets wind: road distance is about 1.3 × the straight line. */
const ROAD_FACTOR = 1.3;
const CITY_SPEED_MPS = 7; // ~25 km/h

interface PhotonFeature {
  geometry: { coordinates: [number, number] };
  properties: {
    name?: string;
    street?: string;
    district?: string;
    city?: string;
    state?: string;
    country?: string;
  };
}

// The coordinates travel inside the place id, so place-details needs no second lookup.
const PREFIX = 'osm|';
const encodeId = (p: LatLng, name: string, address: string) =>
  `${PREFIX}${p.lat}|${p.lng}|${name.slice(0, 90).replaceAll('|', ' ')}|${address
    .slice(0, 160)
    .replaceAll('|', ' ')}`;

export async function osmSearch(
  input: string,
  language: 'en' | 'fr',
  bias?: LatLng,
): Promise<PlaceSuggestion[]> {
  const near = bias ?? BANGUI;
  const url = new URL('https://photon.komoot.io/api/');
  url.search = new URLSearchParams({
    q: input,
    limit: '6',
    lang: language,
    lat: String(near.lat),
    lon: String(near.lng),
    bbox: AFRICA_BBOX,
  }).toString();
  const res = await fetch(url, { headers: HEADERS });
  if (!res.ok) {
    console.error(`Photon -> ${res.status}: ${await res.text()}`);
    throw new HttpError(502, 'upstream_error');
  }
  const { features } = (await res.json()) as { features: PhotonFeature[] };
  return features.flatMap((f) => {
    const { name, street, district, city, state, country } = f.properties;
    const primary = name ?? street;
    if (!primary) return [];
    const [lng, lat] = f.geometry.coordinates;
    const secondary = [...new Set([district, city, state, country])]
      .filter((part) => part && part !== primary)
      .join(', ');
    return [
      {
        placeId: encodeId({ lat, lng }, primary, secondary),
        primaryText: primary,
        secondaryText: secondary,
      },
    ];
  });
}

/** The place behind an id from [osmSearch]; null for a Google place id. */
export function osmPlaceDetails(placeId: string): PlaceDetails | null {
  if (!placeId.startsWith(PREFIX)) return null;
  const [, lat, lng, name, address] = placeId.split('|');
  const location = { lat: Number(lat), lng: Number(lng) };
  if (!Number.isFinite(location.lat) || !Number.isFinite(location.lng)) {
    throw new HttpError(400, 'invalid_request');
  }
  return { placeId, name: name ?? '', address: address ?? '', location };
}

function straightLine(origin: LatLng, destination: LatLng): RouteResult {
  const rad = (d: number) => (d * Math.PI) / 180;
  const h =
    Math.sin(rad(destination.lat - origin.lat) / 2) ** 2 +
    Math.cos(rad(origin.lat)) *
      Math.cos(rad(destination.lat)) *
      Math.sin(rad(destination.lng - origin.lng) / 2) ** 2;
  const distanceMeters = Math.round(2 * 6371000 * Math.asin(Math.sqrt(h)) * ROAD_FACTOR);
  return {
    distanceMeters,
    durationSeconds: Math.round(distanceMeters / CITY_SPEED_MPS),
    polyline: '',
  };
}

export async function osmRoute(origin: LatLng, destination: LatLng): Promise<RouteResult> {
  const path = `${origin.lng},${origin.lat};${destination.lng},${destination.lat}`;
  try {
    const res = await fetch(
      `https://router.project-osrm.org/route/v1/driving/${path}?overview=full&geometries=polyline`,
      { headers: HEADERS, signal: AbortSignal.timeout(5000) },
    );
    if (res.ok) {
      const data = (await res.json()) as {
        routes?: { distance: number; duration: number; geometry: string }[];
      };
      const route = data.routes?.[0];
      if (route) {
        return {
          distanceMeters: Math.round(route.distance),
          durationSeconds: Math.round(route.duration),
          polyline: route.geometry,
        };
      }
    }
    console.warn(`OSRM -> ${res.status}, using a straight-line estimate`);
  } catch (e) {
    console.warn('OSRM failed, using a straight-line estimate', e);
  }
  return straightLine(origin, destination);
}
