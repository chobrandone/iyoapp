// POST /match-ride  { rideId }
// -> { status, state: 'offered' | 'waiting' | 'no_drivers' | 'done', offerExpiresAt? }
//
// Offers a ride to one driver at a time (15 s window), searching 2 km -> 5 km -> 8 km and ranking
// candidates by Routes API ETA (straight-line distance if Google is unavailable). When nobody is
// left to ask within the largest radius, the ride ends as no_drivers_found.
//
// Idempotent: call it again whenever the current offer was declined or expired. Callers:
//   * the rider app right after request_ride, and on its matching screen while status = searching;
//   * TODO(Phase 8): a pg_cron + pg_net job every few seconds for searching rides (service role).
// The offered driver also gets a push, for when the app is in the background.
import { getAdminClient, isServiceRequest, requireCaller } from '../_shared/auth.ts';
import { z } from '../_shared/deps.ts';
import { etasTo } from '../_shared/google.ts';
import { HttpError, json, readBody, serve } from '../_shared/http.ts';
import { sendPush } from '../_shared/push.ts';

const bodySchema = z.object({ rideId: z.uuid() });

interface Candidate {
  driver_id: string;
  vehicle_id: string;
  distance_m: number;
  lat: number;
  lng: number;
}

serve(['POST'], async (req) => {
  const { rideId } = await readBody(req, bodySchema);
  const admin = getAdminClient();

  if (!isServiceRequest(req)) {
    const caller = await requireCaller(req, ['rider']);
    const { data: own } = await admin
      .from('rides')
      .select('id')
      .eq('id', rideId)
      .eq('rider_id', caller.userId)
      .maybeSingle();
    if (!own) throw new HttpError(404, 'ride_not_found');
  }

  await admin.rpc('expire_ride_offers');

  const { data: ride, error } = await admin
    .from('rides')
    .select('id, status, pickup_lat, pickup_lng, search_radius_m')
    .eq('id', rideId)
    .single();
  if (error) throw error;

  let status: string = ride.status;
  if (status === 'requested') {
    const { error: e } = await admin.rpc('server_transition_ride', {
      p_ride_id: rideId,
      p_to: 'searching',
    });
    if (e) throw e;
    status = 'searching';
  }
  if (status !== 'searching') return json({ status, state: 'done' });

  const { data: pending } = await admin
    .from('ride_offers')
    .select('expires_at')
    .eq('ride_id', rideId)
    .eq('status', 'pending')
    .maybeSingle();
  if (pending) return json({ status, state: 'waiting', offerExpiresAt: pending.expires_at });

  const { data: radiiRow } = await admin
    .from('app_config')
    .select('value')
    .eq('key', 'matching_radii_m')
    .single();
  const radii = (radiiRow?.value as number[] | undefined) ?? [2000, 5000, 8000];
  // Never shrink the search once it has grown.
  const startAt = Math.max(
    0,
    radii.findIndex((r) => r >= (ride.search_radius_m ?? 0)),
  );

  for (const radius of radii.slice(startAt)) {
    const { data, error: findError } = await admin.rpc('find_candidate_drivers', {
      p_ride_id: rideId,
      p_radius_m: radius,
      p_limit: 5,
    });
    if (findError) throw findError;
    const candidates = (data ?? []) as Candidate[];
    if (candidates.length === 0) continue;

    let etas: (number | null)[] = candidates.map(() => null);
    try {
      etas = await etasTo(candidates, { lat: ride.pickup_lat!, lng: ride.pickup_lng! });
    } catch (e) {
      console.warn('ETA lookup failed, ranking by distance', e);
    }
    const ranked = candidates
      .map((c, i) => ({ ...c, eta: etas[i] ?? null }))
      .sort((a, b) => (a.eta ?? a.distance_m / 8) - (b.eta ?? b.distance_m / 8)); // ~30 km/h fallback

    const best = ranked[0]!;
    const { data: offer, error: offerError } = await admin.rpc('create_ride_offer', {
      p_ride_id: rideId,
      p_driver_id: best.driver_id,
      p_search_radius_m: radius,
      p_distance_m: best.distance_m,
      p_eta_seconds: best.eta ?? undefined,
    });
    if (offerError) {
      // Another invocation won the race for this ride or this driver; let the caller retry.
      if (offerError.code === '23505') return json({ status, state: 'waiting' });
      throw offerError;
    }
    const { id: offerId, expires_at: offerExpiresAt } = offer as { id: string; expires_at: string };
    const { data: driver } = await admin
      .from('profiles')
      .select('language')
      .eq('id', best.driver_id)
      .maybeSingle();
    const english = driver?.language === 'en';
    await sendPush(admin, best.driver_id, 'driver', {
      title: english ? 'New ride request' : 'Nouvelle course',
      body: english ? 'Open iyodriver to accept it.' : 'Ouvrez iyodriver pour l’accepter.',
      data: { type: 'ride_offer', rideId, offerId },
      channelId: 'ride_offers',
      ttlSeconds: 15,
    });
    return json({ status, state: 'offered', offerExpiresAt });
  }

  const { error: e } = await admin.rpc('server_transition_ride', {
    p_ride_id: rideId,
    p_to: 'no_drivers_found',
    p_metadata: { radii },
  });
  if (e) throw e;
  return json({ status: 'no_drivers_found', state: 'no_drivers' });
});
