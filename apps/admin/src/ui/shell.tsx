// 224 px sidebar, 76 px header and the scrolling page (Figma "Admin · …" frames). Below 1280 px
// the whole workspace scrolls sideways rather than squeezing the tables.
import { Bell, ChevronDown, ExternalLink, Search } from 'lucide-react';
import { useEffect, useRef, useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router';

import type { AdminProfile } from '@/data/models';
import { useNow, useOpenCases, useRepo } from '@/data/queries';
import { setLanguage } from '@/i18n';
import { cx } from './kit';
import { longDateTime } from './format';

export const SECTIONS = [
  ['/overview', 'navOverview'],
  ['/live', 'navLive'],
  ['/rides', 'navRides'],
  ['/rentals', 'navRentals'],
  ['/drivers', 'navDrivers'],
  ['/fleet', 'navFleet'],
  ['/safety', 'navSafety'],
  ['/payments', 'navPayments'],
] as const;

export function initials(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  return (
    (parts[0]?.[0] ?? '') + (parts.length > 1 ? (parts.at(-1)?.[0] ?? '') : '')
  ).toUpperCase();
}

export function Avatar({ name, size }: { name: string; size: number }) {
  return (
    <span
      aria-hidden
      className="flex shrink-0 items-center justify-center rounded-full bg-accent-soft font-semibold"
      style={{ width: size, height: size, fontSize: size * 0.36 }}
    >
      {initials(name)}
    </span>
  );
}

/** Where a reference typed in the header search belongs. */
export function searchTarget(q: string): string {
  const s = q.trim();
  const enc = encodeURIComponent(s);
  if (/^SA-\d+$/i.test(s)) return `/safety?case=${s.toUpperCase()}`;
  if (/^RN-/i.test(s)) return `/rentals?q=${enc}`;
  if (/^DR-/i.test(s)) return `/drivers?q=${enc}`;
  if (/^(TX|RF|PO|DH)-/i.test(s)) return `/payments?q=${enc}`;
  if (/^LT\s?\d/i.test(s)) return `/fleet?q=${enc}`;
  if (/^RD-/i.test(s)) return `/rides?q=${enc}`;
  // Names and places: active trips first, otherwise the live map moves to the place.
  return `/live?q=${enc}`;
}

export function Shell({ admin }: { admin: AdminProfile }) {
  const { pathname } = useLocation();
  const main = useRef<HTMLElement>(null);
  // Each section starts at the top.
  useEffect(() => {
    main.current?.scrollTo?.({ top: 0 });
  }, [pathname]);
  return (
    <div className="h-full overflow-x-auto">
      <div className="flex h-full min-w-[1280px]">
        <Sidebar admin={admin} />
        <div className="flex min-w-0 flex-1 flex-col">
          <Header admin={admin} />
          <main ref={main} className="flex-1 overflow-y-auto" tabIndex={-1}>
            <Outlet />
          </main>
        </div>
      </div>
    </div>
  );
}

function Sidebar({ admin }: { admin: AdminProfile }) {
  const { t } = useTranslation();
  const open = useOpenCases();
  return (
    <aside className="flex w-56 shrink-0 flex-col border-r border-line bg-white px-[18px] pt-7 pb-6">
      <p className="text-[25px] leading-[37px] font-bold">iyodriver</p>
      <p className="-mt-1.5 text-[10px] text-sub">{t('workspace')}</p>
      <p className="mt-[26px] flex items-center gap-3 text-[12px] leading-[50px] font-medium">
        {t('cityLabel')}
        <ChevronDown size={14} aria-hidden />
      </p>
      <nav aria-label="Sections" className="mt-[23px] flex flex-col">
        {SECTIONS.map(([to, key]) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) =>
              cx(
                'my-[3.5px] flex h-[46px] items-center rounded-[10px] pl-4 text-[12px]',
                isActive ? 'bg-accent font-semibold' : 'hover:bg-canvas',
              )
            }
          >
            {to === '/safety' && open > 0 ? t('navSafetyCount', { n: open }) : t(key)}
          </NavLink>
        ))}
      </nav>
      <div className="flex-1" />
      <a
        href="mailto:support@iyodriver.cm"
        className="flex items-center gap-1 text-[11px] font-medium text-sub hover:text-ink"
      >
        {t('supportCentre').replace(/\s*↗\s*$/, '')}
        <ExternalLink size={11} aria-hidden />
      </a>
      <UserMenu admin={admin} />
    </aside>
  );
}

function UserMenu({ admin }: { admin: AdminProfile }) {
  const { t, i18n } = useTranslation();
  const repo = useRepo();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const close = (e: MouseEvent) => !ref.current?.contains(e.target as Node) && setOpen(false);
    const esc = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false);
    document.addEventListener('mousedown', close);
    document.addEventListener('keydown', esc);
    return () => {
      document.removeEventListener('mousedown', close);
      document.removeEventListener('keydown', esc);
    };
  }, [open]);
  return (
    <div ref={ref} className="relative mt-6">
      <button
        type="button"
        aria-expanded={open}
        aria-haspopup="menu"
        onClick={() => setOpen((o) => !o)}
        className="flex w-full cursor-pointer items-center gap-2.5 rounded-[10px] text-left"
      >
        <Avatar name={admin.name} size={34} />
        <span className="min-w-0 flex-1">
          <span className="block truncate text-[12px] font-medium">{admin.name}</span>
          <span className="block text-[10px] text-sub">{t('adminRole')}</span>
        </span>
        <ChevronDown size={14} aria-hidden />
      </button>
      {open && (
        <div
          role="menu"
          className="absolute bottom-12 left-0 w-full rounded-[10px] border border-line bg-white p-1 shadow-lg"
        >
          <button
            role="menuitem"
            type="button"
            className="block w-full cursor-pointer rounded-md px-3 py-2 text-left text-[12px] hover:bg-canvas"
            onClick={() => {
              setLanguage(i18n.language === 'fr' ? 'en' : 'fr');
              setOpen(false);
            }}
          >
            {t('language')}
          </button>
          <button
            role="menuitem"
            type="button"
            className="block w-full cursor-pointer rounded-md px-3 py-2 text-left text-[12px] hover:bg-canvas"
            onClick={() => void repo.signOut()}
          >
            {t('signOut')}
          </button>
        </div>
      )}
    </div>
  );
}

function Header({ admin }: { admin: AdminProfile }) {
  const { t } = useTranslation();
  const now = useNow();
  const navigate = useNavigate();
  const [q, setQ] = useState('');
  const submit = (e: FormEvent) => {
    e.preventDefault();
    if (!q.trim()) return;
    navigate(searchTarget(q));
    setQ('');
  };
  return (
    <header className="flex h-[76px] shrink-0 items-center border-b border-line bg-white px-8">
      <form role="search" onSubmit={submit} className="relative w-[380px]">
        <label htmlFor="global-search" className="sr-only">
          {t('searchEverythingPlaces')}
        </label>
        <Search
          size={14}
          aria-hidden
          className="pointer-events-none absolute top-1/2 left-4 -translate-y-1/2 text-sub"
        />
        <input
          id="global-search"
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder={t('searchEverythingPlaces')}
          className="h-10 w-full rounded-[10px] bg-canvas pr-4 pl-10 text-[12px] placeholder:text-sub focus:outline-2 focus:outline-accent"
        />
      </form>
      <div className="flex-1" />
      <p className="text-[11px] text-sub">
        {t('cityTimezone')}
        <span aria-hidden className="mx-3">
          |
        </span>
        <time dateTime={now.toISOString()}>{longDateTime(now)}</time>
      </p>
      <Bell size={20} aria-hidden className="ml-6" />
      <span className="ml-6">
        <Avatar name={admin.name} size={32} />
      </span>
    </header>
  );
}
