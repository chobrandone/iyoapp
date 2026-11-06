import { z } from './deps.ts';

// Africa's bounding box — rejects obviously wrong coordinates early. Whether a pickup is in a
// served city is decided by estimate-fares.
export const latLngSchema = z.object({
  lat: z.number().min(-35).max(38),
  lng: z.number().min(-26).max(52),
});

export const languageSchema = z.enum(['en', 'fr']).default('fr');

// Places session tokens are client-generated UUIDs, reused from first keystroke to place-details.
export const sessionTokenSchema = z.uuid();

export const placeSchema = latLngSchema.extend({
  address: z.string().trim().min(1).max(300),
  placeId: z.string().max(300).optional(),
});
