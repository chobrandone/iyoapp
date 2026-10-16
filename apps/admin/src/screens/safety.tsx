// Admin · Safety and security alert centre (Figma 2021:3747).
import { ChevronDown, Phone, User } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router';

import type { AlertStatus, CaseSeverity, SafetyCase } from '@/data/models';
import { keys, useAction, useAdmin, useAdmins, useNow, useSafetyCases } from '@/data/queries';
import { sameDoualaDay } from '@/data/time';
import { dayMonth, dayMonthCommaTime, phone, time } from '@/ui/format';
import {
  Async,
  Button,
  Chip,
  cx,
  Divider,
  Page,
  PageHeading,
  Panel,
  PanelHeading,
  SearchBox,
  Select,
  textareaClass,
  Timeline,
  Toolbar,
} from '@/ui/kit';
import { OpsMap } from '@/ui/map';
import { caseTitle, severityName, severityTone } from './labels';

/** Cameroon police emergency number. */
const EMERGENCY = '117';
type Scope = 'recent' | 'open' | 'all';
const SEVERITY_ORDER: Record<CaseSeverity, number> = { high: 0, medium: 1, low: 2 };

export default function SafetyScreen() {
  const cases = useSafetyCases();
  return <Async query={cases}>{(all) => <SafetyBody all={all} />}</Async>;
}

function SafetyBody({ all }: { all: SafetyCase[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const me = useAdmin();
  const [params, setParams] = useSearchParams();
  const [scope, setScope] = useState<Scope>('recent');
  const [severity, setSeverity] = useState<CaseSeverity | ''>('');
  const [mine, setMine] = useState<'all' | 'mine'>('all');
  const [query, setQuery] = useState('');
  const selectedRef = params.get('case');

  const cases = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all
      .filter(
        (c) =>
          (scope === 'all' ||
            c.status !== 'resolved' ||
            (scope === 'recent' && now.getTime() - c.createdAt.getTime() < 7 * 86_400_000)) &&
          (!severity || c.severity === severity) &&
          (mine === 'all' || c.assigneeId === me?.id) &&
          (!q ||
            [c.reference, c.rideRef, c.rentalRef, c.personName, c.riderName, c.driverName].some(
              (s) => s?.toLowerCase().includes(q),
            )),
      )
      .sort(
        (a, b) =>
          Number(a.status === 'resolved') - Number(b.status === 'resolved') ||
          SEVERITY_ORDER[a.severity] - SEVERITY_ORDER[b.severity] ||
          b.createdAt.getTime() - a.createdAt.getTime(),
      );
  }, [all, scope, severity, mine, query, me, now]);
  const selected = cases.find((c) => c.reference === selectedRef) ?? cases[0];
  const open = all.filter((c) => c.status !== 'resolved');
  const high = open.filter((c) => c.severity === 'high').length;

  return (
    <Page>
      <PageHeading
        title={t('safetyTitle')}
        subtitle={t('safetySubtitle')}
        trailing={
          <Chip tone="danger" upper>
            {t('openHigh', { open: open.length, high })}
          </Chip>
        }
      />
      <Toolbar>
        <SearchBox label={t('searchCases')} value={query} onChange={setQuery} />
        <Select
          label={t('openRecent')}
          value={scope}
          onChange={setScope}
          options={[
            { value: 'recent', label: t('openRecent') },
            { value: 'open', label: t('openOnly') },
            { value: 'all', label: t('allCases') },
          ]}
        />
        <Select
          label={t('allSeverities')}
          value={severity}
          onChange={setSeverity}
          options={[
            { value: '', label: t('allSeverities') },
            ...(['high', 'medium', 'low'] as const).map((s) => ({
              value: s,
              label: severityName(t, s),
            })),
          ]}
        />
        <Select
          label={t('allAssignees')}
          value={mine}
          onChange={setMine}
          options={[
            { value: 'all', label: t('allAssignees') },
            { value: 'mine', label: t('mine') },
          ]}
        />
      </Toolbar>
      <div className="flex items-start gap-5">
        <section aria-labelledby="queue-title" className="flex w-[318px] shrink-0 flex-col gap-4">
          <h2 id="queue-title" className="text-[13px] font-semibold">
            {t('severityQueue')}
          </h2>
          {cases.length === 0 && <p className="text-[12px] text-sub">{t('noCases')}</p>}
          <ul className="flex flex-col gap-4">
            {cases.map((c) => (
              <li key={c.id}>
                <CaseCard
                  c={c}
                  now={now}
                  selected={c === selected}
                  onSelect={() => setParams({ case: c.reference }, { replace: true })}
                />
              </li>
            ))}
          </ul>
          <p className="text-[10px] text-sub">{t('queueNote')}</p>
        </section>
        <div className="min-w-0 flex-1">
          {selected ? (
            <CasePanel
              key={`${selected.id}-${selected.status}-${selected.assigneeId}`}
              c={selected}
            />
          ) : (
            <Panel>
              <p className="text-[12px] text-sub">{t('noCases')}</p>
            </Panel>
          )}
        </div>
      </div>
    </Page>
  );
}

function stateLabel(t: ReturnType<typeof useTranslation>['t'], c: SafetyCase) {
  if (c.status === 'resolved') return t('caseResolved');
  if (c.assigneeName) return t('caseAssigned', { name: c.assigneeName.split(' ')[0] });
  return t('caseUnassigned');
}

function CaseCard({
  c,
  now,
  selected,
  onSelect,
}: {
  c: SafetyCase;
  now: Date;
  selected: boolean;
  onSelect: () => void;
}) {
  const { t } = useTranslation();
  const high = c.severity === 'high' && c.status !== 'resolved';
  return (
    <button
      type="button"
      aria-pressed={selected}
      onClick={onSelect}
      className={cx(
        'flex w-full cursor-pointer flex-col gap-1.5 rounded-2xl border p-4 text-left',
        selected
          ? high
            ? 'border-bad bg-bad-soft'
            : 'border-line bg-accent-soft'
          : 'border-line bg-white hover:bg-canvas/60',
      )}
    >
      <span className="flex items-start">
        <Chip tone={severityTone(c.severity)} upper>
          {severityName(t, c.severity)}
        </Chip>
        <span className="flex-1" />
        <span className="text-[10px] text-sub">{c.reference}</span>
      </span>
      <span className="mt-0.5 text-[13px] font-medium">{caseTitle(t, c.category)}</span>
      <span className="text-[11px]">
        {[c.rideRef ?? c.rentalRef, c.personName].filter(Boolean).join(' · ')}
      </span>
      <span className="text-[10px] text-sub">
        {[
          c.place?.split(',')[0],
          sameDoualaDay(c.createdAt, now) ? time(c.createdAt) : dayMonth(c.createdAt),
          stateLabel(t, c),
        ]
          .filter(Boolean)
          .join(' · ')}
      </span>
    </button>
  );
}

function CasePanel({ c }: { c: SafetyCase }) {
  const { t } = useTranslation();
  const me = useAdmin();
  const admins = useAdmins().data ?? [];
  const [assignee, setAssignee] = useState(c.assigneeId ?? '');
  const [status, setStatus] = useState<AlertStatus>(c.status);
  const [note, setNote] = useState('');
  const [error, setError] = useState<string>();
  const resolved = c.status === 'resolved';
  const update = useAction(
    (repo, u: { assignTo?: string; status?: AlertStatus; note?: string }) =>
      repo.updateSafetyCase(c, u),
    {
      invalidate: [keys.cases, keys.overview, keys.rides],
      success: () => t('caseUpdated', { ref: c.reference }),
      errors: { note_required: t('resolutionNoteRequired') },
    },
  );
  const save = (u: { assignTo?: string; status?: AlertStatus }) => {
    const text = note.trim();
    if (u.status === 'resolved' && !text) return setError(t('resolutionNoteRequired'));
    setError(undefined);
    update.mutate(
      {
        assignTo: u.assignTo ?? (assignee && assignee !== c.assigneeId ? assignee : undefined),
        status: u.status ?? (status !== c.status ? status : undefined),
        note: text || undefined,
      },
      { onSuccess: () => setNote('') },
    );
  };
  const statusName = (s: AlertStatus) =>
    ({ open: t('statusOpen'), acknowledged: t('statusAck'), resolved: t('statusResolved') })[s];
  const state = {
    open: t('awaitingCallback'),
    acknowledged: t('inProgressCase'),
    resolved: t('resolvedCase'),
  }[c.status];
  const person = (name?: string, tel?: string) =>
    name && (
      <p className="text-[11px]">
        {[name.split(' ')[0], tel && phone(tel)].filter(Boolean).join(' · ')}
      </p>
    );

  return (
    <Panel label={`${c.reference} · ${caseTitle(t, c.category)}`}>
      <PanelHeading
        title={`${c.reference} · ${caseTitle(t, c.category)}`}
        subtitle={t('receivedLine', {
          when: dayMonthCommaTime(c.createdAt),
          ref: c.rideRef ?? c.rentalRef ?? '—',
          state,
        })}
        trailing={
          <Chip tone={severityTone(c.severity)} upper>
            {severityName(t, c.severity)}
          </Chip>
        }
      />
      {!resolved && (
        <p role="note" className="rounded-[10px] bg-bad-soft p-3 text-[11px] text-bad">
          {t('noDispatch', { number: EMERGENCY })}
        </p>
      )}
      {c.resolutionNote && (
        <p className="text-[12px]">{t('resolutionLabel', { note: c.resolutionNote })}</p>
      )}
      <div className="flex gap-[18px]">
        <div className="w-[320px] shrink-0">
          <OpsMap
            height={180}
            zoom={14}
            label={t('lastLocation')}
            markers={
              c.location
                ? [{ id: 'loc', at: c.location, kind: 'pickup', label: c.place ?? '' }]
                : []
            }
          />
        </div>
        <div className="flex min-w-0 flex-1 flex-col gap-2">
          <h3 className="text-[12px] font-medium">{t('lastLocation')}</h3>
          <p className="text-[11px]">{c.place ?? '—'}</p>
          <p className="text-[10px] text-sub">
            {t('updatedAt', { time: time(c.events.at(-1)?.at ?? c.createdAt) })}
          </p>
          {person(c.riderName, c.riderPhone)}
          {person(c.driverName, c.driverPhone)}
          <div className="mt-1 flex gap-2">
            {(
              [
                [t('callRider'), c.riderPhone],
                [t('callDriver'), c.driverPhone],
              ] as const
            ).map(([label, tel]) =>
              tel ? (
                <a
                  key={label}
                  href={`tel:${tel}`}
                  className="inline-flex h-10 flex-1 items-center justify-center gap-2 rounded-[10px] bg-canvas text-[12px] font-semibold hover:bg-[#ecece8]"
                >
                  <Phone size={14} aria-hidden />
                  {label}
                </a>
              ) : (
                <Button key={label} className="flex-1" disabled>
                  {label}
                </Button>
              ),
            )}
          </div>
        </div>
      </div>
      <Timeline
        items={c.events.map((e) => ({ title: e.title, detail: e.detail, time: time(e.at) }))}
      />
      <Divider />
      <div className="grid grid-cols-2 gap-3.5">
        <label className="flex flex-col gap-2">
          <span className="text-[11px] text-sub">{t('assignIncident')}</span>
          <span className="relative">
            <User
              size={18}
              aria-hidden
              className="pointer-events-none absolute top-1/2 left-3.5 -translate-y-1/2"
            />
            <select
              value={assignee}
              disabled={resolved}
              onChange={(e) => setAssignee(e.target.value)}
              className="h-[50px] w-full appearance-none rounded-[10px] border border-line bg-white pr-3.5 pl-11 text-[13px] disabled:opacity-60"
            >
              <option value="">{t('caseUnassigned')}</option>
              {admins.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.name}
                </option>
              ))}
            </select>
          </span>
        </label>
        <label className="flex flex-col gap-2">
          <span className="text-[11px] text-sub">{t('resolutionStatus')}</span>
          <span className="relative">
            <ChevronDown
              size={18}
              aria-hidden
              className="pointer-events-none absolute top-1/2 left-3.5 -translate-y-1/2"
            />
            <select
              value={status}
              disabled={resolved}
              onChange={(e) => setStatus(e.target.value as AlertStatus)}
              className="h-[50px] w-full appearance-none rounded-[10px] border border-line bg-white pr-3.5 pl-11 text-[13px] disabled:opacity-60"
            >
              {(['open', 'acknowledged', 'resolved'] as const).map((s) => (
                <option key={s} value={s}>
                  {statusName(s)}
                </option>
              ))}
            </select>
          </span>
        </label>
      </div>
      <div className="flex flex-col gap-1.5">
        <label htmlFor={`notes-${c.id}`} className="sr-only">
          {t('notesHint')}
        </label>
        <textarea
          id={`notes-${c.id}`}
          value={note}
          disabled={resolved}
          onChange={(e) => {
            setNote(e.target.value);
            setError(undefined);
          }}
          placeholder={t('notesHint')}
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? `notes-${c.id}-err` : undefined}
          className={textareaClass}
        />
        {error && (
          <p id={`notes-${c.id}-err`} className="text-[11px] text-bad">
            {error}
          </p>
        )}
      </div>
      <div className="grid grid-cols-3 gap-3">
        <Button
          tone="primary"
          loading={update.isPending}
          disabled={resolved || !me || c.assigneeId === me.id}
          onClick={() => me && save({ assignTo: me.id })}
        >
          {t('assignToMe')}
        </Button>
        <Button disabled={resolved || update.isPending} onClick={() => save({})}>
          {t('saveUpdate')}
        </Button>
        <Button
          disabled={resolved || update.isPending}
          onClick={() => save({ status: 'resolved' })}
        >
          {t('resolveIncident')}
        </Button>
      </div>
    </Panel>
  );
}
