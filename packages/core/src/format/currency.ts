/**
 * FCFA (XAF) has no minor unit in practice. Amounts are integers, grouped by thousands
 * with a non-breaking space so "2 500 FCFA" never wraps mid-number.
 */
const NBSP = ' ';

export function formatNumberGrouped(value: number): string {
  const rounded = Math.round(value);
  const sign = rounded < 0 ? '-' : '';
  const digits = Math.abs(rounded).toString();
  return sign + digits.replace(/\B(?=(\d{3})+(?!\d))/g, NBSP);
}

/** `formatFcfa(2500)` → `"2 500 FCFA"`. */
export function formatFcfa(amount: number): string {
  return `${formatNumberGrouped(amount)}${NBSP}FCFA`;
}

/** Rounds to the nearest 50 FCFA, the fare granularity used by pricing. */
export function roundToNearest50(amount: number): number {
  return Math.round(amount / 50) * 50;
}
