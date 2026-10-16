// Admin · Fleet and vehicle inventory (Figma 2021:3656).
import { Plus } from 'lucide-react';
import { useMemo, useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router';

import type {
  AdminFleetVehicle,
  FleetAvailability,
  FuelType,
  RentalVehicleStatus,
  TransmissionType,
} from '@/data/models';
import { keys, useAction, useFleet, useNow } from '@/data/queries';
import { daysBetween } from '@/data/time';
import { count, dayMonthTime, dayRange, longDate, time } from '@/ui/format';
import {
  AmountLine,
  Async,
  Button,
  Cell2,
  Chip,
  Dialog,
  DotStatus,
  Field,
  inputClass,
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
import { availabilityDot, availabilityName, categoryName } from './labels';

const PER_PAGE = 6;
const AVAILABILITY: FleetAvailability[] = [
  'available',
  'reserved',
  'on_rental',
  'return_today',
  'maintenance',
  'retired',
];

export default function FleetScreen() {
  const fleet = useFleet();
  return <Async query={fleet}>{(all) => <FleetBody all={all} />}</Async>;
}

function FleetBody({ all }: { all: AdminFleetVehicle[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const [params] = useSearchParams();
  const [tab, setTab] = useState<FleetAvailability | null>(null);
  const [location, setLocation] = useState('');
  const [query, setQuery] = useState(params.get('q') ?? '');
  const [page, setPage] = useState(1);
  const [acting, setActing] = useState<AdminFleetVehicle>();
  const [adding, setAdding] = useState(false);

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter(
      (v) =>
        (!tab ||
          v.availability === tab ||
          (tab === 'on_rental' && v.availability === 'return_today')) &&
        (!location || v.location === location) &&
        (!q ||
          [v.plate, `${v.make} ${v.model}`, v.assignedDriver].some((s) =>
            s?.toLowerCase().includes(q),
          )),
    );
  }, [all, tab, location, query]);
  const p = paginate(rows, page, PER_PAGE);
  const n = (a: FleetAvailability) => all.filter((v) => v.availability === a).length;
  const locations = [...new Set(all.map((v) => v.location).filter(Boolean) as string[])].sort();
  const next = all
    .filter((v) => v.availability === 'reserved' && v.bookingStart)
    .sort((a, b) => a.bookingStart!.getTime() - b.bookingStart!.getTime())[0];
  const blocked = all.find((v) => v.availability === 'maintenance');
  const reset =
    <T,>(set: (v: T) => void) =>
    (v: T) => {
      set(v);
      setPage(1);
    };

  const setStatus = useAction(
    (repo, a: { id: string; status: RentalVehicleStatus; note?: string }) =>
      repo.setVehicleStatus(a.id, a.status, a.note),
    {
      invalidate: [keys.fleet],
      success: () => t('saved'),
      errors: { note_required: t('fieldsRequired') },
    },
  );

  return (
    <Page>
      <PageHeading
        title={t('fleetTitle')}
        subtitle={t('fleetSubtitle')}
        trailing={
          <Button icon={Plus} tone="primary" onClick={() => setAdding(true)}>
            {t('addVehicle')}
          </Button>
        }
      />
      <TabChips
        label={t('fleetTitle')}
        value={tab}
        onChange={reset(setTab)}
        items={[
          {
            value: null,
            label: t('totalVehiclesN', {
              n: count(all.filter((v) => v.availability !== 'retired').length),
            }),
          },
          {
            value: 'available',
            label: t('availableN', { n: count(n('available')) }),
            idle: 'success',
          },
          {
            value: 'on_rental',
            label: t('onRentalN', { n: count(n('on_rental') + n('return_today')) }),
          },
          { value: 'reserved', label: t('reservedN', { n: count(n('reserved')) }), idle: 'accent' },
          {
            value: 'maintenance',
            label: t('maintenanceN', { n: count(n('maintenance')) }),
            idle: 'danger',
          },
        ]}
      />
      <Toolbar>
        <SearchBox label={t('searchFleet')} value={query} onChange={reset(setQuery)} />
        <Select
          label={t('colService')}
          value="rental"
          onChange={() => {}}
          options={[{ value: 'rental', label: t('rentalService') }]}
        />
        <Select
          label={t('allAvailability')}
          value={tab ?? ''}
          onChange={(v) => reset(setTab)(v || null)}
          options={[
            { value: '', label: t('allAvailability') },
            ...AVAILABILITY.map((a) => ({ value: a, label: availabilityName(t, a) })),
          ]}
        />
        <Select
          label={t('allLocations')}
          value={location}
          onChange={reset(setLocation)}
          options={[
            { value: '', label: t('allLocations') },
            ...locations.map((l) => ({ value: l, label: l })),
          ]}
        />
      </Toolbar>
      <Table
        caption={t('fleetTitle')}
        columns={[
          { label: t('colRegistration'), width: 100 },
          { label: t('colVehicle'), width: 140 },
          { label: t('colService'), width: 80 },
          { label: t('colAvailability').split(' /')[0]!, width: 130 },
          { label: t('colAssignedDriver'), width: 122 },
          { label: t('colCurrentLocation'), width: 130 },
          { label: t('colRentalAllocation') },
          { label: t('colCompliance'), width: 110 },
        ]}
        rows={p.shown.map((v) => ({
          key: v.id,
          label: `${v.plate}, ${v.make} ${v.model}, ${availabilityName(t, v.availability)}`,
          onOpen: () => setActing(v),
          cells: [
            <Cell2 key="a" top={v.plate} />,
            <Cell2
              key="b"
              top={`${v.make} ${v.model}`}
              bottom={[categoryName(t, v.category), v.year].filter(Boolean).join(' · ')}
            />,
            <Cell2 key="c" top={t('rentalService')} />,
            <DotStatus
              key="d"
              label={availabilityName(t, v.availability)}
              color={availabilityDot(v.availability)}
            />,
            <Cell2 key="e" top={v.assignedDriver ?? t('unassigned')} />,
            <Cell2 key="f" top={v.location ?? '—'} />,
            v.availability === 'maintenance' ? (
              <Cell2 key="g" top={t('blocked')} bottom={v.maintenanceNote} />
            ) : v.bookingRef && v.bookingStart && v.bookingEnd ? (
              <Cell2 key="g" top={dayRange(v.bookingStart, v.bookingEnd)} bottom={v.bookingRef} />
            ) : (
              <Cell2 key="g" top="—" />
            ),
            <Cell2
              key="h"
              top={
                !v.complianceDue
                  ? '—'
                  : daysBetween(now, v.complianceDue) <= 7
                    ? t('dueInspection')
                    : longDate(v.complianceDue)
              }
            />,
          ],
        }))}
        footer={
          <TableFooter
            text={t('showingOf', {
              from: count(p.from),
              to: count(p.to),
              total: count(rows.length),
              what: t('fleetWhat', { time: time(now) }),
            })}
            page={p.page}
            pages={p.pages}
            onPage={setPage}
          />
        }
      />
      <div className="grid grid-cols-2 gap-5">
        <Panel>
          <PanelHeading
            title={t('upcomingAllocation')}
            subtitle={next && `${next.make} ${next.model} · ${next.plate}`}
          />
          {next ? (
            <>
              <dl>
                <AmountLine
                  label={t('reservedRental')}
                  value={`${next.bookingRef} · ${dayRange(next.bookingStart!, next.bookingEnd!)}`}
                />
              </dl>
              <p className="text-[11px] text-sub">
                {t('prepareBefore', {
                  place: next.location ?? '',
                  when: dayMonthTime(next.bookingStart!),
                })}
              </p>
            </>
          ) : (
            <p className="text-[12px] text-sub">{t('noUpcoming')}</p>
          )}
        </Panel>
        <Panel>
          <PanelHeading
            title={t('maintenanceBlock')}
            subtitle={blocked && `${blocked.make} ${blocked.model} · ${blocked.plate}`}
            trailing={
              blocked && (
                <Chip tone="danger" upper>
                  {t('unavailable')}
                </Chip>
              )
            }
          />
          {blocked ? (
            <>
              <p className="text-[12px]">
                {[blocked.maintenanceNote, blocked.location].filter(Boolean).join(' · ')}
              </p>
              <div className="flex items-center gap-3">
                <p className="flex-1 text-[11px] text-sub">{t('releaseAfterCheck')}</p>
                <Button
                  loading={setStatus.isPending}
                  onClick={() => setStatus.mutate({ id: blocked.id, status: 'available' })}
                >
                  {t('markAvailable')}
                </Button>
              </div>
            </>
          ) : (
            <p className="text-[12px] text-sub">{t('noMaintenance')}</p>
          )}
        </Panel>
      </div>
      {acting && (
        <VehicleDialog
          v={acting}
          onClose={() => setActing(undefined)}
          onSet={(status, note) =>
            setStatus.mutate(
              { id: acting.id, status, note },
              { onSuccess: () => setActing(undefined) },
            )
          }
          busy={setStatus.isPending}
        />
      )}
      <AddVehicleDialog open={adding} onClose={() => setAdding(false)} />
    </Page>
  );
}

function VehicleDialog({
  v,
  onClose,
  onSet,
  busy,
}: {
  v: AdminFleetVehicle;
  onClose: () => void;
  onSet: (s: RentalVehicleStatus, note?: string) => void;
  busy: boolean;
}) {
  const { t } = useTranslation();
  const [reason, setReason] = useState(v.maintenanceNote ?? '');
  const [error, setError] = useState<string>();
  const out = v.availability === 'maintenance' || v.availability === 'retired';
  return (
    <Dialog
      open
      onClose={onClose}
      title={t('vehicleActions', { plate: v.plate, name: `${v.make} ${v.model}` })}
      actions={
        <>
          <Button onClick={onClose}>{t('cancel')}</Button>
          {out ? (
            <Button tone="primary" loading={busy} onClick={() => onSet('available')}>
              {t('markAvailable')}
            </Button>
          ) : (
            <Button
              tone="primary"
              loading={busy}
              onClick={() =>
                reason.trim() ? onSet('maintenance', reason.trim()) : setError(t('fieldsRequired'))
              }
            >
              {t('sendToMaintenance')}
            </Button>
          )}
          {v.availability !== 'retired' && (
            <Button tone="danger" disabled={busy} onClick={() => onSet('retired')}>
              {t('retireVehicle')}
            </Button>
          )}
        </>
      }
    >
      <p className="text-[12px] font-semibold">{availabilityName(t, v.availability)}</p>
      {!out && (
        <Field label={t('maintenanceReason')} error={error}>
          {(p) => (
            <textarea
              {...p}
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              className={textareaClass}
            />
          )}
        </Field>
      )}
    </Dialog>
  );
}

const EMPTY = {
  make: '',
  model: '',
  year: '',
  plate: '',
  colour: '',
  seats: '5',
  rate: '',
  deposit: '100000',
  km: '200',
  home: '',
  category: 'sedan',
  gearbox: 'automatic' as TransmissionType,
  fuel: 'petrol' as FuelType,
  airport: true,
};

function AddVehicleDialog({ open, onClose }: { open: boolean; onClose: () => void }) {
  const { t } = useTranslation();
  const [f, setF] = useState(EMPTY);
  const [error, setError] = useState<string>();
  const set = (k: keyof typeof EMPTY) => (v: string | boolean) => setF((x) => ({ ...x, [k]: v }));
  const add = useAction((repo, v: Parameters<typeof repo.addVehicle>[0]) => repo.addVehicle(v), {
    invalidate: [keys.fleet],
    success: (v) => t('vehicleAdded', { plate: v.plate.toUpperCase() }),
    errors: { plate_taken: t('plateTaken') },
  });
  const num = (s: string) =>
    /^\d+$/.test(s.replace(/\s/g, '')) ? Number(s.replace(/\s/g, '')) : NaN;
  const submit = (e: FormEvent) => {
    e.preventDefault();
    const nums = [num(f.year), num(f.seats), num(f.rate), num(f.deposit), num(f.km)];
    if ([f.make, f.model, f.plate, f.colour].some((s) => !s.trim()) || nums.some(Number.isNaN)) {
      setError(t('fieldsRequired'));
      return;
    }
    setError(undefined);
    const [year, seats, dailyRate, deposit, kmPerDay] = nums as [
      number,
      number,
      number,
      number,
      number,
    ];
    add.mutate(
      {
        cityCode: 'DLA',
        make: f.make.trim(),
        model: f.model.trim(),
        year,
        category: f.category,
        transmission: f.gearbox,
        seats,
        fuel: f.fuel,
        plate: f.plate.trim().toUpperCase(),
        color: f.colour.trim(),
        dailyRate,
        deposit,
        kmPerDay,
        airportPickup: f.airport,
        homeLocation: f.home.trim() || undefined,
      },
      {
        onSuccess: () => {
          setF(EMPTY);
          onClose();
        },
      },
    );
  };
  const text = (k: keyof typeof EMPTY, label: string, numeric = false) => (
    <Field label={label}>
      {(p) => (
        <input
          {...p}
          inputMode={numeric ? 'numeric' : undefined}
          value={f[k] as string}
          onChange={(e) => set(k)(e.target.value)}
          className={inputClass}
        />
      )}
    </Field>
  );
  const pick = (k: keyof typeof EMPTY, label: string, options: [string, string][]) => (
    <Field label={label}>
      {(p) => (
        <select
          {...p}
          value={f[k] as string}
          onChange={(e) => set(k)(e.target.value)}
          className={inputClass}
        >
          {options.map(([v, l]) => (
            <option key={v} value={v}>
              {l}
            </option>
          ))}
        </select>
      )}
    </Field>
  );
  return (
    <Dialog
      open={open}
      onClose={onClose}
      title={t('addVehicle')}
      width={560}
      actions={
        <>
          <Button onClick={onClose}>{t('cancel')}</Button>
          <Button tone="primary" type="submit" form="add-vehicle" loading={add.isPending}>
            {t('addVehicle')}
          </Button>
        </>
      }
    >
      <form id="add-vehicle" onSubmit={submit} className="grid grid-cols-2 gap-3">
        {text('make', t('make'))}
        {text('model', t('model'))}
        {text('year', t('year'), true)}
        {text('plate', t('plate'))}
        {text('colour', t('colour'))}
        {text('seats', t('seats'), true)}
        {pick('category', t('category'), [
          ['economy', t('catEconomy')],
          ['sedan', t('catSedan')],
          ['suv', t('catSuv')],
          ['pickup', t('catPickup')],
        ])}
        {pick('gearbox', t('gearbox'), [
          ['automatic', t('automatic')],
          ['manual', t('manual')],
        ])}
        {pick('fuel', t('fuel'), [
          ['petrol', t('petrol')],
          ['diesel', t('diesel')],
          ['hybrid', t('hybrid')],
          ['electric', t('electric')],
        ])}
        {text('rate', t('dailyRate'), true)}
        {text('deposit', t('deposit'), true)}
        {text('km', t('kmPerDay'), true)}
        <div className="col-span-2">{text('home', t('homeLocation'))}</div>
        <label className="col-span-2 flex items-center gap-2 text-[12px]">
          <input
            type="checkbox"
            checked={f.airport}
            onChange={(e) => set('airport')(e.target.checked)}
          />
          {t('airportPickupAllowed')}
        </label>
        {error && (
          <p role="alert" className="col-span-2 text-[12px] text-bad">
            {error}
          </p>
        )}
      </form>
    </Dialog>
  );
}
