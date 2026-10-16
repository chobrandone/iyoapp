import { formatFcfa, formatNumberGrouped } from '@iyodriver/core/src/format/currency';
import i18next, { t } from 'i18next';

import type { PaymentMethod } from '@/data/models';
import { doualaParts } from '@/data/time';

export { formatFcfa };

const MONTHS = {
  en: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  fr: [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ],
};

const month = (m: number) => (i18next.language === 'fr' ? MONTHS.fr : MONTHS.en)[m - 1]!;
const pad = (n: number) => String(n).padStart(2, '0');

/** "09:41" in Douala. */
export function time(d: Date) {
  const p = doualaParts(d);
  return `${pad(p.hours)}:${pad(p.minutes)}`;
}

/** "09:41:08" in Douala. */
export function timeSeconds(d: Date) {
  return `${time(d)}:${pad(doualaParts(d).seconds)}`;
}

/** "16 Oct" */
export function dayMonth(d: Date) {
  const p = doualaParts(d);
  return `${p.day} ${month(p.month)}`;
}

/** "16 Oct · 09:38" */
export const dayMonthTime = (d: Date) => `${dayMonth(d)} · ${time(d)}`;

/** "16 Oct, 09:38" */
export const dayMonthCommaTime = (d: Date) => `${dayMonth(d)}, ${time(d)}`;

/** "16 Oct 2026" */
export const longDate = (d: Date) => `${dayMonth(d)} ${doualaParts(d).year}`;

/** "16 Oct 2026 · 09:41" */
export const longDateTime = (d: Date) => `${longDate(d)} · ${time(d)}`;

/** "17–20 Oct" between two instants. */
export function dayRange(a: Date, b: Date) {
  const x = doualaParts(a);
  const y = doualaParts(b);
  return x.month === y.month && x.year === y.year
    ? `${x.day}–${y.day} ${month(y.month)}`
    : `${dayMonth(a)} – ${dayMonth(b)}`;
}

/** 1 284, grouped like FCFA amounts. */
export const count = (n: number) => formatNumberGrouped(n);

/** "+8.2%" */
export const percent = (v: number) => `${v >= 0 ? '+' : '−'}${Math.abs(v).toFixed(1)}%`;

/** −55 000 FCFA for money going out. */
export const signedFcfa = (v: number) => (v < 0 ? `−${formatFcfa(-v)}` : formatFcfa(v));

/** "3.8 km" */
export const distance = (m: number) => (m < 1000 ? `${m} m` : `${(m / 1000).toFixed(1)} km`);

/** "+237 6 71 23 45 67" */
export function phone(p: string) {
  const digits = p.replace(/\D/g, '');
  const local = digits.startsWith('237') ? digits.slice(3) : digits;
  if (local.length !== 9) return p;
  return `+237 ${local[0]} ${local.slice(1, 3)} ${local.slice(3, 5)} ${local.slice(5, 7)} ${local.slice(7)}`;
}

export function methodName(m: PaymentMethod) {
  return {
    mtn_momo: 'MTN MoMo',
    orange_money: 'Orange Money',
    cash: t('cash'),
    card: t('card'),
  }[m];
}

/** Percentage change against yesterday; null without a baseline. */
export const change = (today: number, yesterday: number) =>
  yesterday === 0 ? null : ((today - yesterday) * 100) / yesterday;
