// Place search for the demo dashboard: OpenStreetMap's Nominatim (the same data as the map
// tiles), limited to Cameroon. Searches run on Enter only, well within Nominatim's 1 request
// per second policy. With Supabase the dashboard uses the places-autocomplete Edge Function.
import type { Place } from './models';

const ENDPOINT = 'https://nominatim.openstreetmap.org/search';

interface NominatimResult {
  lat: string;
  lon: string;
  name?: string;
  display_name: string;
}

export async function searchOsmPlaces(query: string, language: string): Promise<Place[]> {
  const q = query.trim();
  if (q.length < 2) return [];
  const url = new URL(ENDPOINT);
  url.search = new URLSearchParams({
    q,
    format: 'jsonv2',
    countrycodes: 'cm',
    limit: '5',
    'accept-language': language,
  }).toString();
  const res = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!res.ok) return [];
  const rows = (await res.json()) as NominatimResult[];
  return rows.map((r) => ({
    name: r.name || r.display_name.split(',')[0]!.trim(),
    address: r.display_name,
    location: { lat: Number(r.lat), lng: Number(r.lon) },
  }));
}
