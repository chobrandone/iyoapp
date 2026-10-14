/**
 * Cameroon (+237) mobile numbers: 9 digits starting with 6 (MTN, Orange, Nexttel, Camtel).
 */
export const CM_COUNTRY_CODE = '237';
const CM_MOBILE_RE = /^6\d{8}$/;

/** Strips spaces/dashes and a leading +237 / 00237 / 237, returning the 9-digit national number. */
export function toNationalNumber(input: string): string {
  const digits = input.replace(/[^\d+]/g, '');
  return digits.replace(/^(\+|00)?237(?=\d{9}$)/, '').replace(/^\+/, '');
}

export function isCameroonMobile(input: string): boolean {
  return CM_MOBILE_RE.test(toNationalNumber(input));
}

/** `"6 71 23 45 67"` → `"+237671234567"`. Returns null if not a valid mobile. */
export function toE164(input: string): string | null {
  const national = toNationalNumber(input);
  return CM_MOBILE_RE.test(national) ? `+${CM_COUNTRY_CODE}${national}` : null;
}

/** Display format: `+237 6 71 23 45 67`. Falls back to the raw input if invalid. */
export function formatPhone(input: string): string {
  const national = toNationalNumber(input);
  if (!CM_MOBILE_RE.test(national)) return input;
  const rest = national.slice(1).match(/.{2}/g) ?? [];
  return `+${CM_COUNTRY_CODE} ${national[0]} ${rest.join(' ')}`;
}
