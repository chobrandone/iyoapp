import { z } from './deps.ts';

// Cameroon bounding box (with margin) — rejects obviously wrong coordinates early.
export const latLngSchema = z.object({
  lat: z.number().min(1.5).max(13.5),
  lng: z.number().min(8).max(16.5),
});

export const languageSchema = z.enum(['en', 'fr']).default('fr');

// Places session tokens are client-generated UUIDs, reused from first keystroke to place-details.
export const sessionTokenSchema = z.uuid();

export const placeSchema = latLngSchema.extend({
  address: z.string().trim().min(1).max(300),
  placeId: z.string().max(300).optional(),
});
