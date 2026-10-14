import { z } from 'zod';

import { isCameroonMobile, toE164 } from '../format/phone';

/** Accepts any common way of typing a +237 mobile number and outputs E.164 (`+2376XXXXXXXX`). */
export const cameroonPhoneSchema = z
  .string()
  .trim()
  .refine(isCameroonMobile, { error: 'validation.phoneInvalid' })
  .transform((value) => toE164(value) as string);

export const otpSchema = z.string().regex(/^\d{6}$/, { error: 'validation.otpInvalid' });
export const pinSchema = z.string().regex(/^\d{4}$/, { error: 'validation.pinInvalid' });

export const languageSchema = z.enum(['en', 'fr']);
export type Language = z.infer<typeof languageSchema>;

export const appRoleSchema = z.enum(['rider', 'driver', 'admin']);
export type AppRole = z.infer<typeof appRoleSchema>;
