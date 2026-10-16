// POST /places-autocomplete  { input, sessionToken, language?, bias?: {lat,lng} }
// -> { suggestions: [{ placeId, primaryText, secondaryText }] }
// Apps debounce keystrokes (300 ms) and reuse one sessionToken until place-details is called.
import { rateLimit, requireCaller } from '../_shared/auth.ts';
import { z } from '../_shared/deps.ts';
import { placesAutocomplete } from '../_shared/google.ts';
import { json, readBody, serve } from '../_shared/http.ts';
import { languageSchema, latLngSchema, sessionTokenSchema } from '../_shared/schemas.ts';

const bodySchema = z.object({
  input: z.string().trim().min(2).max(120),
  sessionToken: sessionTokenSchema,
  language: languageSchema,
  bias: latLngSchema.optional(),
});

serve(['POST'], async (req) => {
  const caller = await requireCaller(req, ['rider', 'driver', 'admin']);
  const body = await readBody(req, bodySchema);
  await rateLimit(caller, 'places', 60);
  const suggestions = await placesAutocomplete(body);
  return json({ suggestions });
});
