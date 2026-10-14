// POST /place-details  { placeId, sessionToken, language? } -> { place: { placeId, name, address, location } }
import { rateLimit, requireCaller } from '../_shared/auth.ts';
import { z } from '../_shared/deps.ts';
import { placeDetails } from '../_shared/google.ts';
import { json, readBody, serve } from '../_shared/http.ts';
import { languageSchema, sessionTokenSchema } from '../_shared/schemas.ts';

const bodySchema = z.object({
  placeId: z.string().min(1).max(300),
  sessionToken: sessionTokenSchema,
  language: languageSchema,
});

serve(['POST'], async (req) => {
  const caller = await requireCaller(req, ['rider', 'driver']);
  const body = await readBody(req, bodySchema);
  await rateLimit(caller, 'places', 60);
  const place = await placeDetails(body);
  return json({ place });
});
