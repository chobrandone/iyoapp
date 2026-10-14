// POST /compute-route  { origin: {lat,lng}, destination: {lat,lng} }
// -> { route: { distanceMeters, durationSeconds, polyline } }   (cached ~5 min)
import { rateLimit, requireCaller } from '../_shared/auth.ts';
import { z } from '../_shared/deps.ts';
import { json, readBody, serve } from '../_shared/http.ts';
import { cachedRoute } from '../_shared/routes.ts';
import { latLngSchema } from '../_shared/schemas.ts';

const bodySchema = z.object({ origin: latLngSchema, destination: latLngSchema });

serve(['POST'], async (req) => {
  const caller = await requireCaller(req, ['rider', 'driver']);
  const body = await readBody(req, bodySchema);
  await rateLimit(caller, 'routes', 30);
  const route = await cachedRoute(caller.admin, body.origin, body.destination);
  return json({ route });
});
