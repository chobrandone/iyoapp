// Douala is UTC+1 all year (no daylight saving), so calendar days are computed with a fixed offset.
const OFFSET_MS = 60 * 60 * 1000;
export const DAY_MS = 86_400_000;

/** Douala wall-clock parts of an instant. */
export function doualaParts(d: Date) {
  const x = new Date(d.getTime() + OFFSET_MS);
  return {
    year: x.getUTCFullYear(),
    month: x.getUTCMonth() + 1,
    day: x.getUTCDate(),
    hours: x.getUTCHours(),
    minutes: x.getUTCMinutes(),
    seconds: x.getUTCSeconds(),
    weekday: x.getUTCDay(),
  };
}

/** Midnight in Douala of the day that contains [d]. */
export function doualaDay(d: Date): Date {
  const p = doualaParts(d);
  return new Date(Date.UTC(p.year, p.month - 1, p.day) - OFFSET_MS);
}

export const sameDoualaDay = (a: Date, b: Date) =>
  doualaDay(a).getTime() === doualaDay(b).getTime();

/** [d] shifted by whole days. */
export const addDays = (d: Date, days: number) => new Date(d.getTime() + days * DAY_MS);

/** Whole Douala calendar days from [from] to [to] (negative when [to] is earlier). */
export const daysBetween = (from: Date, to: Date) =>
  Math.round((doualaDay(to).getTime() - doualaDay(from).getTime()) / DAY_MS);

/** "2026-10-14" for the Douala day of [d]. */
export function isoDay(d: Date): string {
  const p = doualaParts(d);
  return `${p.year}-${String(p.month).padStart(2, '0')}-${String(p.day).padStart(2, '0')}`;
}

/** A calendar date from the database ("2026-10-14") as Douala midnight. */
export const fromIsoDay = (s: string) => new Date(`${s}T00:00:00+01:00`);

/** Short area from an address ("Akwa" from "12 Rue Joss, Akwa, Douala"). */
export function areaOf(p: { name: string; address: string }): string {
  const parts = p.address
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  if (parts.length >= 3) return parts[parts.length - 2]!;
  if (parts.length === 2) return parts[0] === p.name ? parts[1]! : parts[0]!;
  return p.name;
}
