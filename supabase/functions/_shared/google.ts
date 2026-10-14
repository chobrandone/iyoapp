// Google Places API (New) and Routes API, server-side only. Every request sends a field mask
// so we are billed for the cheapest SKU that returns what the apps need.
import { HttpError, requireEnv } from './http.ts';

export interface LatLng {
  lat: number;
  lng: number;
}

const toGoogle = (p: LatLng) => ({ latitude: p.lat, longitude: p.lng });
const seconds = (duration: string | undefined) => (duration ? Number.parseInt(duration, 10) : 0); // "123s"

async function googleFetch(url: string, init: RequestInit, key: string, fieldMask: string) {
  const res = await fetch(url, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': key,
      'X-Goog-FieldMask': fieldMask,
      ...(init.headers ?? {}),
    },
  });
  if (!res.ok) {
    console.error(`Google ${url} -> ${res.status}: ${await res.text()}`);
    throw new HttpError(502, 'upstream_error');
  }
  return res.json();
}

// ---------------------------------------------------------------------------
// Places (New)
// ---------------------------------------------------------------------------

export interface PlaceSuggestion {
  placeId: string;
  primaryText: string;
  secondaryText: string;
}

export async function placesAutocomplete(params: {
  input: string;
  sessionToken: string;
  language: 'en' | 'fr';
  bias?: LatLng;
}): Promise<PlaceSuggestion[]> {
  const key = requireEnv('GOOGLE_PLACES_API_KEY');
  const body: Record<string, unknown> = {
    input: params.input,
    sessionToken: params.sessionToken,
    includedRegionCodes: ['cm'],
    languageCode: params.language,
  };
  if (params.bias) {
    body.locationBias = { circle: { center: toGoogle(params.bias), radius: 30000 } };
    body.origin = toGoogle(params.bias);
  }
  const data = await googleFetch(
    'https://places.googleapis.com/v1/places:autocomplete',
    { method: 'POST', body: JSON.stringify(body) },
    key,
    'suggestions.placePrediction.placeId,suggestions.placePrediction.structuredFormat',
  );
  type Prediction = {
    placeId: string;
    structuredFormat?: { mainText?: { text?: string }; secondaryText?: { text?: string } };
  };
  return ((data.suggestions ?? []) as { placePrediction?: Prediction }[])
    .map((s) => s.placePrediction)
    .filter((p): p is Prediction => !!p)
    .map((p) => ({
      placeId: p.placeId,
      primaryText: p.structuredFormat?.mainText?.text ?? '',
      secondaryText: p.structuredFormat?.secondaryText?.text ?? '',
    }));
}

export interface PlaceDetails {
  placeId: string;
  name: string;
  address: string;
  location: LatLng;
}

/** Ends the autocomplete session: pass the same sessionToken used for the suggestions. */
export async function placeDetails(params: {
  placeId: string;
  sessionToken: string;
  language: 'en' | 'fr';
}): Promise<PlaceDetails> {
  const key = requireEnv('GOOGLE_PLACES_API_KEY');
  const url = new URL(
    `https://places.googleapis.com/v1/places/${encodeURIComponent(params.placeId)}`,
  );
  url.searchParams.set('sessionToken', params.sessionToken);
  url.searchParams.set('languageCode', params.language);
  url.searchParams.set('regionCode', 'cm');
  const p = await googleFetch(
    url.toString(),
    { method: 'GET' },
    key,
    'id,displayName,formattedAddress,location',
  );
  return {
    placeId: p.id,
    name: p.displayName?.text ?? '',
    address: p.formattedAddress ?? '',
    location: { lat: p.location.latitude, lng: p.location.longitude },
  };
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

export interface RouteResult {
  distanceMeters: number;
  durationSeconds: number;
  polyline: string;
}

export async function computeRoute(origin: LatLng, destination: LatLng): Promise<RouteResult> {
  const key = requireEnv('GOOGLE_ROUTES_API_KEY');
  const data = await googleFetch(
    'https://routes.googleapis.com/directions/v2:computeRoutes',
    {
      method: 'POST',
      body: JSON.stringify({
        origin: { location: { latLng: toGoogle(origin) } },
        destination: { location: { latLng: toGoogle(destination) } },
        travelMode: 'DRIVE',
        routingPreference: 'TRAFFIC_AWARE',
        units: 'METRIC',
        regionCode: 'cm',
      }),
    },
    key,
    'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline',
  );
  const route = data.routes?.[0];
  if (!route) throw new HttpError(422, 'no_route');
  return {
    distanceMeters: route.distanceMeters ?? 0,
    durationSeconds: seconds(route.duration),
    polyline: route.polyline?.encodedPolyline ?? '',
  };
}

/** Driving ETA (seconds) from each origin to one destination; null where no route exists. */
export async function etasTo(origins: LatLng[], destination: LatLng): Promise<(number | null)[]> {
  if (origins.length === 0) return [];
  const key = requireEnv('GOOGLE_ROUTES_API_KEY');
  const rows = (await googleFetch(
    'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix',
    {
      method: 'POST',
      body: JSON.stringify({
        origins: origins.map((o) => ({ waypoint: { location: { latLng: toGoogle(o) } } })),
        destinations: [{ waypoint: { location: { latLng: toGoogle(destination) } } }],
        travelMode: 'DRIVE',
        routingPreference: 'TRAFFIC_AWARE',
      }),
    },
    key,
    'originIndex,duration,condition',
  )) as { originIndex?: number; duration?: string; condition?: string }[];
  const etas: (number | null)[] = origins.map(() => null);
  for (const row of rows) {
    if (row.condition === 'ROUTE_EXISTS') etas[row.originIndex ?? 0] = seconds(row.duration);
  }
  return etas;
}

/** Straight-line distance in metres (fallback when Google is unavailable). */
export function haversineMeters(a: LatLng, b: LatLng): number {
  const R = 6371000;
  const rad = (d: number) => (d * Math.PI) / 180;
  const dLat = rad(b.lat - a.lat);
  const dLng = rad(b.lng - a.lng);
  const h =
    Math.sin(dLat / 2) ** 2 + Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}
