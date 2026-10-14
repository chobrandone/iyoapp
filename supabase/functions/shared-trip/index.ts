// GET /shared-trip?token=…  (public, verify_jwt = false)
// Live view of a shared trip: status, addresses, driver first name, vehicle and live position.
// Nothing is returned once the link is expired or revoked.
import { getAdminClient } from '../_shared/auth.ts';
import { HttpError, json, serve } from '../_shared/http.ts';

const ACTIVE = ['driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress'];

serve(['GET'], async (req) => {
  const token = new URL(req.url).searchParams.get('token') ?? '';
  if (!/^[0-9a-f]{36}$/.test(token)) throw new HttpError(404, 'share_not_found');
  const admin = getAdminClient();

  const { data: share } = await admin
    .from('trip_shares')
    .select('ride_id, expires_at, revoked_at')
    .eq('token', token)
    .maybeSingle();
  if (!share || share.revoked_at || new Date(share.expires_at) < new Date()) {
    throw new HttpError(404, 'share_not_found');
  }

  const { data: ride, error } = await admin
    .from('rides')
    .select(
      'status, pickup_address, dropoff_address, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, route_polyline, driver_id, vehicles(make, model, color, plate)',
    )
    .eq('id', share.ride_id)
    .single();
  if (error) throw error;

  let driver = null;
  let position = null;
  if (ride.driver_id) {
    const { data: p } = await admin
      .from('profiles')
      .select('full_name')
      .eq('id', ride.driver_id)
      .single();
    driver = { firstName: (p?.full_name ?? '').split(' ')[0] };
    if (ACTIVE.includes(ride.status)) {
      const { data: loc } = await admin
        .from('driver_locations')
        .select('lat, lng, heading, updated_at')
        .eq('driver_id', ride.driver_id)
        .maybeSingle();
      position = loc;
    }
  }

  return json(
    {
      status: ride.status,
      pickup: { address: ride.pickup_address, lat: ride.pickup_lat, lng: ride.pickup_lng },
      dropoff: { address: ride.dropoff_address, lat: ride.dropoff_lat, lng: ride.dropoff_lng },
      polyline: ride.route_polyline,
      driver,
      vehicle: ride.vehicles,
      position,
      expiresAt: share.expires_at,
    },
    200,
    { 'Cache-Control': 'no-store' },
  );
});
