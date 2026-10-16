// Building blocks from the admin frames: page, panels, chips, buttons, tables and dialogs.
import { ChevronDown, Search } from 'lucide-react';
import {
  useEffect,
  useId,
  useRef,
  type ButtonHTMLAttributes,
  type ComponentType,
  type ReactNode,
} from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router';

import { useRepo } from '@/data/queries';

const cx = (...c: (string | false | null | undefined)[]) => c.filter(Boolean).join(' ');

// ---------------------------------------------------------------------------
// Page and panels
// ---------------------------------------------------------------------------

/** Page content: 28 top / 32 sides, blocks 22 apart, the data note at the end. */
export function Page({ children }: { children: ReactNode }) {
  const { t } = useTranslation();
  const repo = useRepo();
  return (
    <div className="flex flex-col gap-[22px] px-8 pt-7 pb-5">
      {children}
      <p className="text-[10px] text-sub">{repo.isDemo ? t('footerNote') : t('footerNoteLive')}</p>
    </div>
  );
}

export function PageHeading({
  title,
  subtitle,
  trailing,
}: {
  title: string;
  subtitle?: ReactNode;
  trailing?: ReactNode;
}) {
  return (
    <header className="flex items-center gap-4">
      <div className="min-w-0 flex-1">
        <h1 className="text-[28px] leading-[42px] font-semibold">{title}</h1>
        {subtitle && <p className="-mt-[7px] text-[12px] leading-[18px] text-sub">{subtitle}</p>}
      </div>
      {trailing}
    </header>
  );
}

export function Panel({
  children,
  className,
  as: Tag = 'section',
  label,
}: {
  children: ReactNode;
  className?: string;
  as?: 'section' | 'div' | 'aside';
  label?: string;
}) {
  return (
    <Tag
      aria-label={label}
      className={cx('flex flex-col gap-4 rounded-2xl border border-line bg-white p-5', className)}
    >
      {children}
    </Tag>
  );
}

export function PanelHeading({
  title,
  subtitle,
  trailing,
  level = 2,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  trailing?: ReactNode;
  level?: 2 | 3;
}) {
  const H = level === 2 ? 'h2' : 'h3';
  return (
    <div className="flex items-start gap-3">
      <div className="min-w-0 flex-1">
        <H className="text-[16px] leading-6 font-semibold">{title}</H>
        {subtitle && <p className="text-[11px] leading-[18px] text-sub">{subtitle}</p>}
      </div>
      {trailing}
    </div>
  );
}

export const Divider = () => <hr className="h-px border-0 bg-line" />;

// ---------------------------------------------------------------------------
// Chips, buttons, links
// ---------------------------------------------------------------------------

export type Tone = 'accent' | 'success' | 'neutral' | 'danger' | 'plain';

const TONES: Record<Tone, string> = {
  accent: 'bg-accent-soft text-ink',
  success: 'bg-ok-soft text-ok',
  neutral: 'bg-canvas text-ink',
  danger: 'bg-bad-soft text-bad',
  plain: 'bg-transparent text-ink',
};

/** 10 px Medium pill; [upper] for status badges ("COMPLETED"). */
export function Chip({
  children,
  tone = 'neutral',
  upper,
}: {
  children: ReactNode;
  tone?: Tone;
  upper?: boolean;
}) {
  return (
    <span
      className={cx(
        'inline-flex shrink-0 items-center rounded-md px-2.5 py-[5px] text-[10px] leading-[15px] font-medium whitespace-nowrap',
        TONES[tone],
        upper && 'uppercase',
      )}
    >
      {children}
    </span>
  );
}

/** Filter tabs above tables ("All rides · 12"). */
export function TabChips<T extends string>({
  label,
  items,
  value,
  onChange,
}: {
  label: string;
  items: { value: T | null; label: string; idle?: Tone }[];
  value: T | null;
  onChange: (v: T | null) => void;
}) {
  return (
    <div role="group" aria-label={label} className="flex flex-wrap gap-2">
      {items.map((it) => {
        const on = it.value === value;
        return (
          <button
            key={it.value ?? 'all'}
            type="button"
            aria-pressed={on}
            onClick={() => onChange(on && it.value !== null ? null : it.value)}
            className={cx(
              'cursor-pointer rounded-md px-2.5 py-[5px] text-[10px] leading-[15px] font-medium',
              on ? TONES.accent : TONES[it.idle ?? 'plain'],
              !on && 'hover:bg-white',
            )}
          >
            {it.label}
          </button>
        );
      })}
    </div>
  );
}

type ButtonTone = 'primary' | 'surface' | 'danger' | 'ghost' | 'white';
const BUTTON: Record<ButtonTone, string> = {
  primary: 'bg-accent text-ink hover:brightness-95',
  surface: 'bg-canvas text-ink hover:bg-[#ecece8]',
  danger: 'bg-bad-soft text-bad hover:bg-[#ffe3e3]',
  ghost: 'bg-transparent text-ink hover:bg-white/70',
  white: 'bg-white text-ink border border-line hover:bg-canvas',
};

export function Button({
  children,
  icon: Icon,
  tone = 'surface',
  size = 40,
  block,
  loading,
  className,
  ...rest
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  icon?: ComponentType<{ size?: number; 'aria-hidden'?: boolean }>;
  tone?: ButtonTone;
  size?: 40 | 46;
  block?: boolean;
  loading?: boolean;
}) {
  return (
    <button
      type="button"
      {...rest}
      disabled={rest.disabled || loading}
      aria-busy={loading || undefined}
      className={cx(
        'inline-flex cursor-pointer items-center justify-center gap-2 rounded-[10px] px-4 font-semibold whitespace-nowrap transition disabled:cursor-not-allowed disabled:opacity-50',
        size === 46 ? 'h-[46px] text-[13px]' : 'h-10 text-[12px]',
        block && 'w-full',
        BUTTON[tone],
        className,
      )}
    >
      {loading ? (
        <span
          aria-hidden
          className="size-4 animate-spin rounded-full border-2 border-current border-t-transparent"
        />
      ) : (
        Icon && <Icon size={18} aria-hidden />
      )}
      {children}
    </button>
  );
}

/** "Open live map →" style text link. */
export function TextLink({
  to,
  children,
  onClick,
}: {
  to?: string;
  children: ReactNode;
  onClick?: () => void;
}) {
  const cls = 'cursor-pointer text-[11px] font-medium text-ink hover:underline';
  return to ? (
    <Link to={to} className={cls}>
      {children}
    </Link>
  ) : (
    <button type="button" onClick={onClick} className={cx(cls, 'text-left')}>
      {children}
    </button>
  );
}

// ---------------------------------------------------------------------------
// Text rows
// ---------------------------------------------------------------------------

/** 13 Medium title (optional bold aside) over an 11 px grey line, both 24 px tall. */
export function TwoLine({
  title,
  subtitle,
  aside,
  to,
  onClick,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  aside?: ReactNode;
  to?: string;
  onClick?: () => void;
}) {
  const body = (
    <>
      <span className="block text-[13px] leading-6 font-medium">
        {title}
        {aside && <span className="ml-4 text-[12px] font-semibold">{aside}</span>}
      </span>
      {subtitle && <span className="block text-[11px] leading-6 text-sub">{subtitle}</span>}
    </>
  );
  if (to)
    return (
      <Link to={to} className="block rounded-md hover:bg-canvas/60">
        {body}
      </Link>
    );
  if (onClick)
    return (
      <button type="button" onClick={onClick} className="block w-full cursor-pointer text-left">
        {body}
      </button>
    );
  return <div>{body}</div>;
}

/** Label left, value right (fare breakdowns, reconciliation). */
export function AmountLine({
  label,
  value,
  strong,
}: {
  label: ReactNode;
  value: ReactNode;
  strong?: boolean;
}) {
  return (
    <div className="flex items-baseline gap-3 text-[12px] leading-[18px]">
      <dt className={cx('flex-1', strong ? 'font-semibold text-ink' : 'text-sub')}>{label}</dt>
      <dd className="tabular font-semibold">{value}</dd>
    </div>
  );
}

/** "● On trip" */
export function DotStatus({
  label,
  color = 'ink',
}: {
  label: string;
  color?: 'ink' | 'ok' | 'bad';
}) {
  const c = { ink: 'text-ink bg-ink', ok: 'text-ok bg-ok', bad: 'text-bad bg-bad' }[color];
  return (
    <span
      className={cx('inline-flex items-center gap-[5px] text-[11px] font-medium', c.split(' ')[0])}
    >
      <span aria-hidden className={cx('size-[7px] shrink-0 rounded-full', c.split(' ')[1])} />
      {label}
    </span>
  );
}

export function Timeline({
  items,
}: {
  items: { title: string; detail?: string; time?: string }[];
}) {
  return (
    <ol className="flex flex-col gap-[27px]">
      {items.map((e, i) => (
        <li key={i}>
          <p className="flex items-center gap-2 text-[12px] font-medium">
            <span aria-hidden className="size-[9px] rounded-full bg-ink" />
            {e.title}
          </p>
          <p className="mt-1 flex gap-3 text-[11px] text-sub">
            <span className="flex-1">{e.detail}</span>
            {e.time && <time className="text-[10px]">{e.time}</time>}
          </p>
        </li>
      ))}
    </ol>
  );
}

// ---------------------------------------------------------------------------
// Search and filters
// ---------------------------------------------------------------------------

export function SearchBox({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <label className="relative block min-w-0 flex-1">
      <span className="sr-only">{label}</span>
      <Search
        size={17}
        aria-hidden
        className="pointer-events-none absolute top-1/2 left-3.5 -translate-y-1/2 text-sub"
      />
      <input
        type="search"
        value={value}
        placeholder={label}
        onChange={(e) => onChange(e.target.value)}
        className="h-[42px] w-full rounded-[10px] border border-line bg-white pr-3.5 pl-10 text-[12px] placeholder:text-sub focus:border-accent focus:outline-none"
      />
    </label>
  );
}

/** White "All statuses ⌄" select. */
export function Select<T extends string>({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: T;
  options: { value: T; label: string }[];
  onChange: (v: T) => void;
}) {
  return (
    <label className="relative block shrink-0">
      <span className="sr-only">{label}</span>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value as T)}
        className="h-[42px] cursor-pointer appearance-none rounded-[10px] border border-line bg-white pr-9 pl-3.5 text-[12px] focus:border-accent focus:outline-none"
      >
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
      <ChevronDown
        size={14}
        aria-hidden
        className="pointer-events-none absolute top-1/2 right-3.5 -translate-y-1/2"
      />
    </label>
  );
}

export function Toolbar({ children }: { children: ReactNode }) {
  return <div className="flex items-center gap-3">{children}</div>;
}

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

export interface Column {
  label: string;
  /** Fixed width in px; flexible when absent. */
  width?: number;
}

/** Two 32 px lines in a cell, 11 px. */
export function Cell2({
  top,
  bottom,
  strong,
}: {
  top: ReactNode;
  bottom?: ReactNode;
  strong?: boolean;
}) {
  return (
    <>
      <span className={cx('block truncate leading-8', strong && 'font-medium')}>{top}</span>
      <span className="block truncate leading-8">{bottom ?? ' '}</span>
    </>
  );
}

export function Table({
  caption,
  columns,
  rows,
  empty,
  footer,
}: {
  caption: string;
  columns: Column[];
  rows: {
    key: string;
    cells: ReactNode[];
    selected?: boolean;
    onOpen?: () => void;
    label?: string;
  }[];
  empty?: string;
  footer?: ReactNode;
}) {
  return (
    <div className="overflow-hidden rounded-2xl border border-line bg-white">
      <table className="w-full table-fixed border-collapse text-left text-[11px]">
        <caption className="sr-only">{caption}</caption>
        <colgroup>
          {columns.map((c, i) => (
            <col
              key={i}
              // Widths are the Figma content widths; add each cell's padding.
              style={
                c.width
                  ? { width: c.width + (i === 0 ? 20 : 12) + (i === columns.length - 1 ? 20 : 0) }
                  : undefined
              }
            />
          ))}
        </colgroup>
        <thead className="bg-canvas">
          <tr className="h-[46px]">
            {columns.map((c, i) => (
              <th
                key={i}
                scope="col"
                className={cx(
                  'text-[10px] font-medium text-sub',
                  i === 0 ? 'pl-5' : 'pl-3',
                  i === columns.length - 1 && 'pr-5',
                )}
              >
                {c.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 && empty && (
            <tr>
              <td colSpan={columns.length} className="px-5 py-6 text-[12px] text-sub">
                {empty}
              </td>
            </tr>
          )}
          {rows.map((r) => (
            <tr
              key={r.key}
              aria-selected={r.selected || undefined}
              onClick={r.onOpen}
              onKeyDown={(e) => {
                if (
                  r.onOpen &&
                  (e.key === 'Enter' || e.key === ' ') &&
                  e.target === e.currentTarget
                ) {
                  e.preventDefault();
                  r.onOpen();
                }
              }}
              tabIndex={r.onOpen ? 0 : undefined}
              aria-label={r.label}
              className={cx(
                'h-16 border-b border-line align-middle',
                r.selected ? 'bg-accent-soft' : 'bg-white',
                r.onOpen && 'cursor-pointer hover:bg-canvas/70 focus-visible:bg-canvas',
              )}
            >
              {r.cells.map((c, i) => (
                <td
                  key={i}
                  className={cx(
                    'overflow-hidden',
                    i === 0 ? 'pl-5' : 'pl-3',
                    i === r.cells.length - 1 && 'pr-5',
                  )}
                >
                  {c}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {footer}
    </div>
  );
}

/** "Showing 1–8 of 12 rides …" and ‹ 1 2 3 … › */
export function TableFooter({
  text,
  page,
  pages,
  onPage,
}: {
  text: string;
  page: number;
  pages: number;
  onPage: (p: number) => void;
}) {
  const { t } = useTranslation();
  const shown = Array.from({ length: Math.min(pages, 3) }, (_, i) => i + 1);
  const link = (label: string, to: number | null, current = false, aria?: string) => (
    <button
      type="button"
      aria-label={aria}
      aria-current={current ? 'page' : undefined}
      disabled={to === null}
      onClick={() => to !== null && onPage(to)}
      className={cx(
        'px-1.5 text-[12px] disabled:cursor-default',
        current ? 'font-bold' : 'font-medium',
        to === null && !current ? 'text-muted' : 'cursor-pointer',
      )}
    >
      {label}
    </button>
  );
  return (
    <nav aria-label={text} className="flex items-center px-5 py-3.5">
      <p className="flex-1 text-[10px] text-sub">{text}</p>
      {link('‹', page > 1 ? page - 1 : null, false, t('previousPage', 'Previous page'))}
      {shown.map((p) => link(String(p), p === page ? null : p, p === page))}
      {pages > 3 && link('…', null)}
      {link('›', page < pages ? page + 1 : null, false, t('nextPage', 'Next page'))}
    </nav>
  );
}

/** Pages a filtered list. */
export function paginate<T>(rows: T[], page: number, perPage: number) {
  const pages = Math.max(1, Math.ceil(rows.length / perPage));
  const current = Math.min(Math.max(1, page), pages);
  const start = (current - 1) * perPage;
  const shown = rows.slice(start, start + perPage);
  return {
    pages,
    page: current,
    shown,
    from: rows.length ? start + 1 : 0,
    to: start + shown.length,
  };
}

// ---------------------------------------------------------------------------
// Dialogs and fields
// ---------------------------------------------------------------------------

/** Native modal dialog: focus trap, Escape and backdrop come from the browser. */
export function Dialog({
  open,
  title,
  onClose,
  children,
  actions,
  width = 460,
}: {
  open: boolean;
  title: string;
  onClose: () => void;
  children: ReactNode;
  actions?: ReactNode;
  width?: number;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (open && !d.open) {
      if (typeof d.showModal === 'function') d.showModal();
      else d.setAttribute('open', '');
    }
    if (!open && d.open) {
      if (typeof d.close === 'function') d.close();
      else d.removeAttribute('open');
    }
  }, [open]);
  if (!open) return null;
  return (
    <dialog
      ref={ref}
      aria-labelledby={titleId}
      onCancel={(e) => {
        e.preventDefault();
        onClose();
      }}
      style={{ width }}
      className="m-auto max-w-[calc(100vw-32px)] rounded-2xl border border-line bg-white p-6 text-ink backdrop:bg-ink/45"
    >
      <h2 id={titleId} className="mb-4 text-[18px] font-semibold">
        {title}
      </h2>
      <div className="flex flex-col gap-3.5">{children}</div>
      {actions && <div className="mt-6 flex justify-end gap-3">{actions}</div>}
    </dialog>
  );
}

export function Field({
  label,
  hint,
  error,
  children,
}: {
  label: string;
  hint?: string;
  error?: string;
  children: (props: {
    id: string;
    'aria-describedby'?: string;
    'aria-invalid'?: boolean;
  }) => ReactNode;
}) {
  const id = useId();
  const describedBy = error || hint ? `${id}-note` : undefined;
  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor={id} className="text-[11px] font-medium text-ink">
        {label}
      </label>
      {children({ id, 'aria-describedby': describedBy, 'aria-invalid': error ? true : undefined })}
      {(error || hint) && (
        <p id={describedBy} className={cx('text-[11px]', error ? 'text-bad' : 'text-sub')}>
          {error ?? hint}
        </p>
      )}
    </div>
  );
}

export const inputClass =
  'h-11 w-full rounded-[10px] border border-line bg-white px-3.5 text-[13px] placeholder:text-sub focus:border-accent focus:outline-none aria-[invalid=true]:border-bad';
export const textareaClass =
  'min-h-[60px] w-full rounded-[10px] border border-line bg-white px-3.5 py-3 text-[12px] placeholder:text-sub focus:border-accent focus:outline-none aria-[invalid=true]:border-bad';

// ---------------------------------------------------------------------------
// Loading and errors
// ---------------------------------------------------------------------------

export function Loading() {
  return (
    <div role="status" className="flex justify-center p-12">
      <span className="size-8 animate-spin rounded-full border-[3px] border-accent border-t-transparent" />
      <span className="sr-only">Loading</span>
    </div>
  );
}

export function LoadError({ onRetry }: { onRetry: () => void }) {
  const { t } = useTranslation();
  return (
    <div role="alert" className="flex flex-col items-center gap-3 p-12 text-[12px] text-sub">
      {t('loadFailed')}
      <Button onClick={onRetry}>{t('retry')}</Button>
    </div>
  );
}

/** Loading / error / data for one query. */
export function Async<T>({
  query,
  children,
}: {
  query: { data: T | undefined; isError: boolean; refetch: () => unknown };
  children: (data: T) => ReactNode;
}) {
  if (query.data !== undefined) return <>{children(query.data)}</>;
  if (query.isError) return <LoadError onRetry={() => void query.refetch()} />;
  return <Loading />;
}

export { cx };
