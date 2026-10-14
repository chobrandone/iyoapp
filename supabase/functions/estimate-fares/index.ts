// POST /estimate-fares  { pickup: {lat,lng,address,placeId?}, dropoff: {...} }
// -> { route, cityCode, options: [{ quoteId, categoryCode, nameEn, nameFr, seats, fareAmount, currency, expiresAt, isPlaceholder }] }
//
// Prices are computed here (public.compute_fare) and stored as fare_quotes. The rider app then
// books with request_ride(quoteId), so the upfront price never comes from the client.
import { rateLimit, requireCaller } from '../_shared/auth.ts';
import type { Json } from '../_shared/database.types.ts';
import { z } from '../_shared/deps.ts';
import { haversineMeters } from '../_shared/google.ts';
import { HttpError, json, readBody, serve } from '../_shared/http.ts';
import { cachedRoute } from '../_shared/routes.ts';
import { placeSchema } from '../_shared/schemas.ts';

const bodySchema = z.object({ pickup: placeSchema, dropoff: placeSchema });

/** A pickup belongs to the nearest active city within this distance of its centre. */
const SERVICE_RADIUS_M = 60_000;

serve(['POST'], async (req) => {
  const caller = await requireCaller(req, ['rider']);
  const { pickup, dropoff } = await readBody(req, bodySchema);
  await rateLimit(caller, 'fares', 20);
  const { admin } = caller;

  const { data: cities, error: citiesError } = await admin
    .from('cities')
    .select('code, center_lat, center_lng')
    .eq('is_active', true);
  if (citiesError) throw citiesError;
  const city = (cities ?? [])
    .map((c) => ({
      code: c.code,
      // center_lat/lng are generated from the NOT NULL center column.
      distance: haversineMeters(pickup, { lat: c.center_lat!, lng: c.center_lng! }),
    }))
    .sort((a, b) => a.distance - b.distance)[0];
  if (!city || city.distance > SERVICE_RADIUS_M) throw new HttpError(422, 'outside_service_area');

  const route = await cachedRoute(admin, pickup, dropoff);

  const { data: categories, error: catError } = await admin
    .from('ride_categories')
    .select('code, name_en, name_fr, seats, sort_order, fare_config!inner(city_code, is_active)')
    .eq('is_active', true)
    .eq('fare_config.city_code', city.code)
    .eq('fare_config.is_active', true)
    .order('sort_order');
  if (catError) throw catError;

  const { data: ttlRow } = await admin
    .from('app_config')
    .select('value')
    .eq('key', 'fare_quote_ttl_minutes')
    .maybeSingle();
  const ttlMinutes = Number(ttlRow?.value ?? 10);
  const expiresAt = new Date(Date.now() + ttlMinutes * 60_000).toISOString();

  const options = [];
  for (const category of categories ?? []) {
    const { data: fare, error } = await admin.rpc('compute_fare', {
      p_city_code: city.code,
      p_category_code: category.code,
      p_distance_m: route.distanceMeters,
      p_duration_s: route.durationSeconds,
    });
    if (error) throw error;
    const f = fare as {
      fare_amount: number;
      commission_rate: number;
      is_placeholder: boolean;
      breakdown: Json;
    };

    const { data: quote, error: quoteError } = await admin
      .from('fare_quotes')
      .insert({
        rider_id: caller.userId,
        city_code: city.code,
        category_code: category.code,
        pickup_location: `SRID=4326;POINT(${pickup.lng} ${pickup.lat})`,
        pickup_address: pickup.address,
        pickup_place_id: pickup.placeId ?? null,
        dropoff_location: `SRID=4326;POINT(${dropoff.lng} ${dropoff.lat})`,
        dropoff_address: dropoff.address,
        dropoff_place_id: dropoff.placeId ?? null,
        distance_m: route.distanceMeters,
        duration_s: route.durationSeconds,
        route_polyline: route.polyline,
        fare_amount: f.fare_amount,
        commission_rate: f.commission_rate,
        breakdown: f.breakdown,
        expires_at: expiresAt,
      })
      .select('id')
      .single();
    if (quoteError) throw quoteError;

    options.push({
      quoteId: quote.id,
      categoryCode: category.code,
      nameEn: category.name_en,
      nameFr: category.name_fr,
      seats: category.seats,
      fareAmount: f.fare_amount,
      currency: 'XAF',
      expiresAt,
      isPlaceholder: f.is_placeholder,
      // TODO(Phase 5): pickup ETA per category from the nearest online driver.
    });
  }

  return json({ cityCode: city.code, route, options });
});
