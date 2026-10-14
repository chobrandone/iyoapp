// Route lookup with a short-lived cache (public.route_cache) so repeated quotes for the same
// trip don't hit the Routes API again.
import type { DbClient } from './auth.ts';
import { computeRoute, type LatLng, type RouteResult } from './google.ts';

const TTL_SECONDS = 5 * 60;

// ~11 m precision: nearby pickups share a cache entry.
const keyFor = (o: LatLng, d: LatLng) =>
  `route:${o.lat.toFixed(4)},${o.lng.toFixed(4)}>${d.lat.toFixed(4)},${d.lng.toFixed(4)}`;

export async function cachedRoute(
  admin: DbClient,
  origin: LatLng,
  destination: LatLng,
): Promise<RouteResult> {
  const cacheKey = keyFor(origin, destination);
  const { data: hit } = await admin
    .from('route_cache')
    .select('response')
    .eq('cache_key', cacheKey)
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();
  if (hit) return hit.response as unknown as RouteResult;

  const route = await computeRoute(origin, destination);
  await admin.from('route_cache').upsert({
    cache_key: cacheKey,
    response: { ...route },
    expires_at: new Date(Date.now() + TTL_SECONDS * 1000).toISOString(),
  });
  return route;
}
