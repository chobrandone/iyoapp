/**
 * All user-facing dates use Africa/Douala (WAT, UTC+01:00, no daylight saving).
 * The fixed offset is applied manually so output does not depend on the device's
 * time zone or on Intl time-zone support in the JS engine.
 */
export const APP_TIME_ZONE = 'Africa/Douala';
const DOUALA_OFFSET_MS = 60 * 60 * 1000;

const pad = (n: number) => n.toString().padStart(2, '0');

function toDoualaParts(input: Date | string | number) {
  const date = input instanceof Date ? input : new Date(input);
  const shifted = new Date(date.getTime() + DOUALA_OFFSET_MS);
  return {
    day: shifted.getUTCDate(),
    month: shifted.getUTCMonth() + 1,
    year: shifted.getUTCFullYear(),
    hours: shifted.getUTCHours(),
    minutes: shifted.getUTCMinutes(),
  };
}

/** `DD/MM/YYYY` in Africa/Douala. */
export function formatDate(input: Date | string | number): string {
  const p = toDoualaParts(input);
  return `${pad(p.day)}/${pad(p.month)}/${p.year}`;
}

/** 24-hour `HH:mm` in Africa/Douala. */
export function formatTime(input: Date | string | number): string {
  const p = toDoualaParts(input);
  return `${pad(p.hours)}:${pad(p.minutes)}`;
}

/** `DD/MM/YYYY HH:mm` in Africa/Douala. */
export function formatDateTime(input: Date | string | number): string {
  return `${formatDate(input)} ${formatTime(input)}`;
}

/** `mm:ss` countdown/timer label, e.g. wait time `01:24`. */
export function formatDuration(totalSeconds: number): string {
  const s = Math.max(0, Math.floor(totalSeconds));
  return `${pad(Math.floor(s / 60))}:${pad(s % 60)}`;
}

/** Distances are always kilometres: `850 m`, `4.2 km`. */
export function formatDistance(meters: number): string {
  if (meters < 1000) return `${Math.round(meters)} m`;
  return `${(meters / 1000).toFixed(1)} km`;
}
