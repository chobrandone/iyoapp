// Admin · Drivers and verification queue (Figma 2021:3561).
import { Download, ExternalLink } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router';
import type { TFunction } from 'i18next';

import {
  expiringWithin,
  type AdminDocument,
  type AdminDriver,
  type DocumentType,
  type ReviewStatus,
} from '@/data/models';
import { keys, useAction, useDrivers, useNow, useRepo } from '@/data/queries';
import { daysBetween } from '@/data/time';
import { saveFile, toCsv } from '@/ui/download';
import {
  count,
  dayMonth,
  dayMonthCommaTime,
  dayMonthTime,
  longDate,
  phone,
  time,
} from '@/ui/format';
import {
  Async,
  Button,
  Cell2,
  Divider,
  DotStatus,
  Page,
  PageHeading,
  paginate,
  Panel,
  PanelHeading,
  SearchBox,
  Select,
  Table,
  TableFooter,
  TabChips,
  textareaClass,
  Toolbar,
} from '@/ui/kit';
import { Avatar } from '@/ui/shell';
import { useToast } from '@/ui/toast';
import { documentName } from './labels';

const PER_PAGE = 6;
type Tab = 'online' | 'awaiting' | 'expiring';
const PAPERS: DocumentType[] = ['vehicle_registration', 'insurance', 'roadworthiness'];
const REVIEWED: DocumentType[] = ['driving_licence', 'vehicle_registration', 'insurance'];

const awaiting = (d: AdminDriver) => d.status === 'pending' || d.status === 'under_review';

function statusOf(
  t: TFunction,
  d: AdminDriver,
  now: Date,
): { label: string; color: 'ink' | 'ok' | 'bad' } {
  if (awaiting(d)) return { label: t('vsPending'), color: 'ink' };
  if (d.status === 'approved')
    return expiringWithin(d, 7, now)
      ? { label: t('vsExpiring'), color: 'bad' }
      : { label: t('vsApproved'), color: 'ok' };
  if (d.status === 'suspended') return { label: t('vsSuspended'), color: 'bad' };
  return { label: t('vsActionNeeded'), color: 'bad' };
}

export default function DriversScreen() {
  const drivers = useDrivers();
  return <Async query={drivers}>{(all) => <DriversBody all={all} />}</Async>;
}

function DriversBody({ all }: { all: AdminDriver[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const toast = useToast();
  const [params] = useSearchParams();
  const [tab, setTab] = useState<Tab | null>(null);
  const [queue, setQueue] = useState<'queue' | 'all'>('queue');
  const [docStatus, setDocStatus] = useState<ReviewStatus | ''>('');
  const [query, setQuery] = useState(params.get('q') ?? '');
  const [page, setPage] = useState(1);
  const [selectedId, setSelectedId] = useState<string>();

  const inTab = (d: AdminDriver, x: Tab) =>
    x === 'online' ? d.online : x === 'awaiting' ? awaiting(d) : expiringWithin(d, 7, now);
  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    const list = all.filter(
      (d) =>
        (!tab || inTab(d, tab)) &&
        (!docStatus || Object.values(d.documents).some((x) => x?.status === docStatus)) &&
        (!q || [d.reference, d.name, d.plate].some((s) => s?.toLowerCase().includes(q))),
    );
    if (queue === 'queue') {
      // Applications waiting for a decision first, then expiring papers; newest submission first.
      const rank = (d: AdminDriver) => (awaiting(d) ? 0 : expiringWithin(d, 7, now) ? 1 : 2);
      list.sort(
        (a, b) =>
          rank(a) - rank(b) || (b.submittedAt?.getTime() ?? 0) - (a.submittedAt?.getTime() ?? 0),
      );
    }
    return list;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [all, tab, queue, docStatus, query, now]);
  const p = paginate(rows, page, PER_PAGE);
  const selected = all.find((d) => d.id === selectedId) ?? rows[0];
  const n = (x: Tab) => all.filter((d) => inTab(d, x)).length;
  const reset =
    <T,>(set: (v: T) => void) =>
    (v: T) => {
      set(v);
      setPage(1);
    };

  const reviewName = (s: ReviewStatus) =>
    ({ pending: t('inReview'), approved: t('verified'), rejected: t('vsActionNeeded') })[s];

  const exportRows = () => {
    saveFile(
      'iyodriver-drivers.csv',
      toCsv([
        [
          t('colDriver'),
          'ID',
          t('colSubmitted'),
          t('colStatus'),
          t('vehicleLabel'),
          t('plate'),
          t('email'),
        ],
        ...rows.map((d) => [
          d.name,
          d.reference,
          d.submittedAt ? dayMonthTime(d.submittedAt) : '',
          statusOf(t, d, now).label,
          d.vehicle,
          d.plate,
          d.email,
        ]),
      ]),
    );
    toast(t('exported', { n: rows.length }));
  };

  return (
    <Page>
      <PageHeading
        title={t('driversTitle')}
        subtitle={t('driversSubtitle')}
        trailing={
          <Button icon={Download} tone="ghost" onClick={exportRows}>
            {t('exportDrivers')}
          </Button>
        }
      />
      <TabChips
        label={t('driversTitle')}
        value={tab}
        onChange={reset(setTab)}
        items={[
          { value: null, label: t('allDriversN', { n: count(all.length) }) },
          { value: 'online', label: t('onlineN', { n: count(n('online')) }), idle: 'success' },
          {
            value: 'awaiting',
            label: t('awaitingReviewN', { n: count(n('awaiting')) }),
            idle: 'accent',
          },
          {
            value: 'expiring',
            label: t('docsExpiringN', { n: count(n('expiring')) }),
            idle: 'danger',
          },
        ]}
      />
      <Toolbar>
        <SearchBox label={t('searchDrivers')} value={query} onChange={reset(setQuery)} />
        <Select
          label={t('verificationQueue')}
          value={queue}
          onChange={setQueue}
          options={[
            { value: 'queue', label: t('verificationQueue') },
            { value: 'all', label: t('allDrivers') },
          ]}
        />
        <Select
          label={t('allDocStatuses')}
          value={docStatus}
          onChange={reset(setDocStatus)}
          options={[
            { value: '', label: t('allDocStatuses') },
            ...(['pending', 'approved', 'rejected'] as const).map((s) => ({
              value: s,
              label: reviewName(s),
            })),
          ]}
        />
      </Toolbar>
      <div className="flex items-start gap-5">
        <div className="flex min-w-0 flex-1 flex-col gap-[22px]">
          <Table
            caption={t('verificationQueue')}
            columns={[
              { label: t('colDriver'), width: 140 },
              { label: t('colSubmitted'), width: 80 },
              { label: t('colStatus'), width: 90 },
              { label: t('colLicencePapers'), width: 100 },
              { label: t('colDocuments') },
            ]}
            rows={p.shown.map((d) => {
              const s = statusOf(t, d, now);
              return {
                key: d.id,
                selected: d.id === selected?.id,
                label: `${d.reference}, ${d.name}, ${s.label}`,
                onOpen: () => setSelectedId(d.id),
                cells: [
                  <Cell2 key="a" top={d.reference} bottom={d.name} />,
                  <Cell2
                    key="b"
                    top={d.submittedAt ? dayMonth(d.submittedAt) : '—'}
                    bottom={d.submittedAt && time(d.submittedAt)}
                  />,
                  <DotStatus key="c" label={s.label} color={s.color} />,
                  <PapersCell key="d" d={d} />,
                  <DocumentsCell key="e" d={d} now={now} />,
                ],
              };
            })}
            footer={
              <TableFooter
                text={t('showingOf', {
                  from: count(p.from),
                  to: count(p.to),
                  total: count(rows.length),
                  what: t('driversWhat'),
                })}
                page={p.page}
                pages={p.pages}
                onPage={setPage}
              />
            }
          />
          <p className="text-[12px] text-sub">{t('driversNote')}</p>
        </div>
        <div className="w-[478px] shrink-0">
          {selected ? (
            <ReviewPanel key={selected.id} d={selected} />
          ) : (
            <Panel>
              <p className="text-[12px] text-sub">{t('selectDriver')}</p>
            </Panel>
          )}
        </div>
      </div>
    </Page>
  );
}

function PapersCell({ d }: { d: AdminDriver }) {
  const { t } = useTranslation();
  const papers = PAPERS.map((x) => d.documents[x]);
  const bottom = papers.some((x) => x?.status === 'rejected')
    ? t('unreadable')
    : papers.some((x) => !x)
      ? t('papersMissing')
      : papers.every((x) => x?.status === 'approved')
        ? t('papersOk')
        : t('inReview');
  return (
    <Cell2
      top={d.documents.driving_licence?.status === 'approved' ? t('licenceOk') : t('licenceBad')}
      bottom={bottom}
    />
  );
}

function DocumentsCell({ d, now }: { d: AdminDriver; now: Date }) {
  const { t } = useTranslation();
  const docs = Object.values(d.documents).filter(Boolean) as AdminDocument[];
  const rejected = docs.find((x) => x.status === 'rejected');
  if (rejected) return <Cell2 top={documentName(t, rejected.type)} bottom={t('resubmit')} />;
  const pending = docs.find((x) => x.status === 'pending');
  if (pending) return <Cell2 top={documentName(t, pending.type)} bottom={t('inReview')} />;
  const expiring = docs.find((x) => x.expiresOn && daysBetween(now, x.expiresOn) <= 7);
  if (expiring)
    return <Cell2 top={documentName(t, expiring.type)} bottom={dayMonth(expiring.expiresOn!)} />;
  return <Cell2 top={t('allCurrent')} />;
}

function ReviewPanel({ d }: { d: AdminDriver }) {
  const { t } = useTranslation();
  const repo = useRepo();
  const [note, setNote] = useState(d.reviewNotes ?? '');
  const [error, setError] = useState<string>();
  const docs = Object.values(d.documents).filter(Boolean) as AdminDocument[];
  const file = docs.find((x) => x.status !== 'approved' && x.fileName);
  const rejectable = file?.type ?? docs.find((x) => x.status === 'pending')?.type;
  const decide = useAction(
    (r, a: { approve: boolean }) =>
      r.decideDriver(d.id, {
        approve: a.approve,
        note: note.trim() || undefined,
        rejectDocument: a.approve ? undefined : rejectable,
      }),
    {
      invalidate: [keys.drivers, keys.overview],
      success: (a) =>
        a.approve ? t('approvedToast', { name: d.name }) : t('sentBackToast', { name: d.name }),
      errors: { documents_rejected: t('documentsRejectedErr'), note_required: t('noteRequired') },
    },
  );
  const open = async (x: AdminDocument) => {
    if (!x.storagePath) return;
    const url = await repo.documentUrl(x.storagePath);
    if (url) window.open(url, '_blank', 'noopener');
  };
  const docLine = (x?: AdminDocument) => {
    if (!x) return t('docMissing');
    const valid = x.expiresOn && longDate(x.expiresOn);
    if (x.status === 'approved')
      return valid ? t('docVerifiedValid', { date: valid }) : t('verified');
    if (x.status === 'pending')
      return valid ? t('docAwaitingValid', { date: valid }) : t('docAwaiting');
    return t('docRejected', { reason: x.rejectionReason ?? t('unreadable') });
  };

  return (
    <Panel label={t('applicationReview')}>
      <PanelHeading
        title={t('applicationReview')}
        subtitle={
          d.submittedAt
            ? t('submittedAt', { ref: d.reference, when: dayMonthCommaTime(d.submittedAt) })
            : t('notSubmitted', { ref: d.reference })
        }
      />
      <div className="flex items-center gap-3.5">
        <Avatar name={d.name} size={56} />
        <div>
          <h3 className="text-[16px] font-medium">{d.name}</h3>
          <p className="text-[11px] text-sub">{d.email ?? (d.phone && phone(d.phone))}</p>
        </div>
      </div>
      <dl className="flex text-[12px]">
        <dt className="flex-1 text-sub">{t('vehicleLabel')}</dt>
        <dd className="font-medium">{[d.vehicle, d.plate].filter(Boolean).join(' · ')}</dd>
      </dl>
      <Divider />
      <ul className="flex flex-col gap-4">
        {REVIEWED.map((type) => {
          const x = d.documents[type];
          return (
            <li key={type}>
              {x?.storagePath ? (
                <button
                  type="button"
                  onClick={() => void open(x)}
                  className="cursor-pointer text-[13px] leading-6 font-medium hover:underline"
                >
                  {documentName(t, type)} ›
                </button>
              ) : (
                <p className="text-[13px] leading-6 font-medium">{documentName(t, type)}</p>
              )}
              <p className="text-[11px] leading-6 text-sub">{docLine(x)}</p>
            </li>
          );
        })}
      </ul>
      {file && (
        <div className="flex flex-col gap-1.5 rounded-[10px] bg-canvas p-4">
          <p className="text-[11px] font-medium">{file.fileName}</p>
          <p className="flex items-center gap-1 text-[10px] text-sub">
            {t('uploadedAt', {
              when: file.uploadedAt ? dayMonthTime(file.uploadedAt) : '',
            }).replace(/\s*↗$/, '')}
            {file.storagePath && (
              <button
                type="button"
                aria-label={t('uploadedAt', { when: '' })}
                onClick={() => void open(file)}
              >
                <ExternalLink size={11} aria-hidden />
              </button>
            )}
          </p>
        </div>
      )}
      <div className="flex flex-col gap-2">
        <label htmlFor={`note-${d.id}`} className="text-[11px] text-sub">
          {t('reviewNote')}
        </label>
        <textarea
          id={`note-${d.id}`}
          value={note}
          onChange={(e) => {
            setNote(e.target.value);
            setError(undefined);
          }}
          placeholder={t('reviewNoteHint')}
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? `note-${d.id}-err` : undefined}
          className={textareaClass}
        />
        {error && (
          <p id={`note-${d.id}-err`} className="text-[11px] text-bad">
            {error}
          </p>
        )}
      </div>
      <Button
        tone="primary"
        block
        loading={decide.isPending && decide.variables?.approve}
        disabled={d.status === 'approved' || decide.isPending}
        onClick={() => decide.mutate({ approve: true })}
      >
        {t('approveApplication')}
      </Button>
      <Button
        tone="danger"
        block
        disabled={decide.isPending}
        onClick={() => {
          if (!note.trim()) return setError(t('noteRequired'));
          decide.mutate({ approve: false });
        }}
      >
        {t('rejectResubmit')}
      </Button>
    </Panel>
  );
}
