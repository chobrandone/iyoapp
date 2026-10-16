// Admin · Rental bookings management (Figma 2021:3361).
import { Plus } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSearchParams } from 'react-router';

import type { AdminRental, RentalBookingStatus } from '@/data/models';
import { useNow, useRentals } from '@/data/queries';
import { addDays, sameDoualaDay } from '@/data/time';
import { count, dayMonthTime, dayRange, formatFcfa, time } from '@/ui/format';
import {
  AmountLine,
  Async,
  Button,
  Cell2,
  Dialog,
  DotStatus,
  Page,
  PageHeading,
  paginate,
  SearchBox,
  Select,
  Table,
  TableFooter,
  TabChips,
  Toolbar,
  TwoLine,
} from '@/ui/kit';
import { rentalStatusName } from './labels';

const PER_PAGE = 7;
type Tab = 'active' | 'upcoming' | 'pickup_today' | 'return_today' | 'airport';

const STATUSES: RentalBookingStatus[] = [
  'pending_payment',
  'confirmed',
  'active',
  'return_pending',
  'completed',
  'cancelled',
];

function inTab(r: AdminRental, tab: Tab, now: Date) {
  switch (tab) {
    case 'active':
      return r.status === 'active' || r.status === 'return_pending';
    case 'upcoming':
      return ['pending_payment', 'confirmed', 'driver_assigned'].includes(r.status);
    case 'pickup_today':
      return sameDoualaDay(r.startsAt, now) && r.status !== 'cancelled';
    case 'return_today':
      return sameDoualaDay(r.endsAt, now) && r.status === 'active';
    case 'airport':
      return Boolean(r.airportCode) && r.status !== 'cancelled';
  }
}

export default function RentalsScreen() {
  const rentals = useRentals();
  return <Async query={rentals}>{(all) => <RentalsBody all={all} />}</Async>;
}

function RentalsBody({ all }: { all: AdminRental[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const [params] = useSearchParams();
  const [tab, setTab] = useState<Tab | null>(null);
  const [status, setStatus] = useState<RentalBookingStatus | ''>('');
  const [where, setWhere] = useState<'' | 'airport' | 'address'>('');
  const [period, setPeriod] = useState<'window' | 'all'>(params.get('q') ? 'all' : 'window');
  const [query, setQuery] = useState(params.get('q') ?? '');
  const [page, setPage] = useState(1);
  const [selected, setSelected] = useState<string | undefined>(all[0]?.id);
  const [details, setDetails] = useState<AdminRental>();
  const [info, setInfo] = useState(false);

  const from = addDays(now, -7);
  const to = addDays(now, 7);
  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter(
      (r) =>
        (!tab || inTab(r, tab, now)) &&
        (!status ||
          r.status === status ||
          (status === 'confirmed' && r.status === 'driver_assigned')) &&
        (!where || Boolean(r.airportCode) === (where === 'airport')) &&
        (period === 'all' || (r.endsAt > from && r.startsAt < to)) &&
        (!q ||
          [r.reference, r.customer, r.plate, r.vehicle].some((s) => s.toLowerCase().includes(q))),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [all, tab, status, where, period, query, now]);
  const p = paginate(rows, page, PER_PAGE);
  const n = (x: Tab) => all.filter((r) => inTab(r, x, now)).length;
  const reset =
    <T,>(set: (v: T) => void) =>
    (v: T) => {
      set(v);
      setPage(1);
    };

  const bookingStatus = (r: AdminRental) => {
    if (r.status === 'confirmed' && r.airportCode)
      return { label: t('rsAwaitingFlight'), ok: false };
    if (r.status === 'active' && sameDoualaDay(r.endsAt, now))
      return { label: t('rsReturnToday'), ok: false };
    return {
      label: rentalStatusName(t, r.status),
      ok: ['confirmed', 'driver_assigned', 'active'].includes(r.status),
    };
  };
  const availability = (r: AdminRental) =>
    r.status === 'active' || r.status === 'return_pending'
      ? t('avOnRental')
      : r.status === 'completed' || r.status === 'cancelled'
        ? t('avAvailable')
        : t('avReserved');

  return (
    <Page>
      <PageHeading
        title={t('rentalsTitle')}
        subtitle={t('rentalsSubtitle')}
        trailing={
          <Button icon={Plus} tone="primary" onClick={() => setInfo(true)}>
            {t('createBooking')}
          </Button>
        }
      />
      <TabChips
        label={t('rentalsTitle')}
        value={tab}
        onChange={reset(setTab)}
        items={[
          { value: 'active', label: t('activeN', { n: count(n('active')) }), idle: 'success' },
          { value: 'upcoming', label: t('upcomingN', { n: count(n('upcoming')) }) },
          { value: 'pickup_today', label: t('pickupTodayN', { n: count(n('pickup_today')) }) },
          { value: 'return_today', label: t('returnTodayN', { n: count(n('return_today')) }) },
          { value: 'airport', label: t('airportPickupsN', { n: count(n('airport')) }) },
        ]}
      />
      <Toolbar>
        <SearchBox label={t('searchRentals')} value={query} onChange={reset(setQuery)} />
        <Select
          label={t('periodAll')}
          value={period}
          onChange={reset(setPeriod)}
          options={[
            { value: 'window', label: dayRange(from, to) },
            { value: 'all', label: t('periodAll') },
          ]}
        />
        <Select
          label={t('allStatuses')}
          value={status}
          onChange={reset(setStatus)}
          options={[
            { value: '', label: t('allStatuses') },
            ...STATUSES.map((s) => ({ value: s, label: rentalStatusName(t, s) })),
          ]}
        />
        <Select
          label={t('pickupLocation')}
          value={where}
          onChange={reset(setWhere)}
          options={[
            { value: '', label: t('pickupLocation') },
            { value: 'airport', label: t('airportOnly') },
            { value: 'address', label: t('addressOnly') },
          ]}
        />
      </Toolbar>
      <Table
        caption={t('rentalsTitle')}
        columns={[
          { label: t('colBooking'), width: 83 },
          { label: t('colCustomer'), width: 114 },
          { label: t('colVehicle'), width: 118 },
          { label: t('colPickupReturn'), width: 122 },
          { label: t('colLocation'), width: 150 },
          { label: t('colBookingStatus'), width: 132 },
          { label: t('colAvailability') },
          { label: t('colCharges'), width: 92 },
        ]}
        rows={p.shown.map((r) => {
          const s = bookingStatus(r);
          return {
            key: r.id,
            selected: r.id === selected,
            label: `${r.reference}, ${r.customer}`,
            onOpen: () => {
              setSelected(r.id);
              setDetails(r);
            },
            cells: [
              <Cell2 key="a" top={r.reference} />,
              <Cell2 key="b" top={r.customer} />,
              <Cell2 key="c" top={r.vehicle} bottom={r.plate} />,
              <Cell2
                key="d"
                top={dayRange(r.startsAt, r.endsAt)}
                bottom={`${time(r.startsAt)} / ${time(r.endsAt)}`}
              />,
              <Cell2
                key="e"
                top={r.airportCode ? `Douala (${r.airportCode})` : r.place.split(',')[0]}
                bottom={
                  r.airportCode
                    ? t('airportTerminal', { terminal: r.terminal ?? '' })
                    : t('noAirport')
                }
              />,
              <DotStatus key="f" label={s.label} color={s.ok ? 'ok' : 'ink'} />,
              <Cell2 key="g" top={availability(r)} bottom={r.assignedDriver ?? t('unassigned')} />,
              <Cell2
                key="h"
                top={
                  <span className="tabular">
                    {r.refunded ? t('refundedShort') : formatFcfa(r.totalAmount)}
                  </span>
                }
              />,
            ],
          };
        })}
        footer={
          <TableFooter
            text={t('showingOf', {
              from: count(p.from),
              to: count(p.to),
              total: count(rows.length),
              what: t('rentalsWhat'),
            })}
            page={p.page}
            pages={p.pages}
            onPage={setPage}
          />
        }
      />
      <p className="rounded-[10px] bg-accent-soft px-4 py-3.5 text-[12px]">{t('rentalsNote')}</p>

      <Dialog
        open={Boolean(details)}
        onClose={() => setDetails(undefined)}
        title={details ? t('bookingDetails', { ref: details.reference }) : ''}
        actions={<Button onClick={() => setDetails(undefined)}>{t('close')}</Button>}
      >
        {details && (
          <>
            <TwoLine title={details.customer} subtitle={`${details.vehicle} · ${details.plate}`} />
            <TwoLine
              title={`${dayMonthTime(details.startsAt)} → ${dayMonthTime(details.endsAt)}`}
              subtitle={details.place}
            />
            {details.flightNumber && details.flightArrivalAt && (
              <p className="text-[12px]">
                {t('flightLine', {
                  flight: details.flightNumber,
                  time: time(details.flightArrivalAt),
                })}
              </p>
            )}
            <dl className="flex flex-col gap-2.5 border-t border-line pt-3.5">
              <AmountLine
                label={t('colCharges')}
                value={details.refunded ? t('refundedShort') : formatFcfa(details.totalAmount)}
                strong
              />
              <AmountLine label={t('deposit')} value={formatFcfa(details.depositAmount)} />
              <AmountLine
                label={t('colAssignedDriver')}
                value={details.assignedDriver ?? t('unassigned')}
              />
            </dl>
          </>
        )}
      </Dialog>
      <Dialog
        open={info}
        onClose={() => setInfo(false)}
        title={t('createBooking')}
        actions={<Button onClick={() => setInfo(false)}>{t('close')}</Button>}
      >
        <p className="text-[13px]">{t('createBookingInfo')}</p>
      </Dialog>
    </Page>
  );
}
