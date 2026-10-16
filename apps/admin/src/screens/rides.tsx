// Admin · Rides management (Figma 2021:3193).
import { Download } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router';

import type { AdminRide, PaymentStatus, RideStatus } from '@/data/models';
import { useNow, useRides } from '@/data/queries';
import { areaOf, DAY_MS, sameDoualaDay } from '@/data/time';
import { saveFile, toCsv } from '@/ui/download';
import { count, dayMonthTime, formatFcfa, longDate, methodName } from '@/ui/format';
import {
  Async,
  Button,
  Cell2,
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
} from '@/ui/kit';
import { useToast } from '@/ui/toast';
import {
  paymentLabel,
  paymentName,
  rideDot,
  rideGroup,
  rideStatusLabel,
  type RideGroup,
} from './labels';

const PER_PAGE = 8;
type Period = 'today' | 'week' | 'all';

/** The ride opened last, highlighted when coming back to the list. */
let lastViewed: string | null = null;
export const markViewed = (id: string) => {
  lastViewed = id;
};

const STATUS_FILTERS: RideStatus[] = [
  'searching',
  'driver_arriving',
  'driver_arrived',
  'in_progress',
  'completed',
  'cancelled_by_rider',
  'cancelled_by_driver',
  'no_drivers_found',
];
const PAY_FILTERS: PaymentStatus[] = [
  'pending',
  'processing',
  'succeeded',
  'failed',
  'cancelled',
  'refunded',
];

export default function RidesScreen() {
  const rides = useRides();
  return <Async query={rides}>{(all) => <RidesBody all={all} />}</Async>;
}

function RidesBody({ all }: { all: AdminRide[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const toast = useToast();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [group, setGroup] = useState<RideGroup | null>(null);
  const [status, setStatus] = useState<RideStatus | ''>('');
  const [pay, setPay] = useState<PaymentStatus | ''>('');
  const [period, setPeriod] = useState<Period>(params.get('q') ? 'all' : 'today');
  const [query, setQuery] = useState(params.get('q') ?? '');
  const [page, setPage] = useState(1);

  const today = all.filter((r) => sameDoualaDay(r.requestedAt, now));
  const n = (g: RideGroup) => today.filter((r) => rideGroup(r.status) === g).length;

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter(
      (r) =>
        (!group || rideGroup(r.status) === group) &&
        (!status || r.status === status) &&
        (!pay || r.paymentStatus === pay) &&
        (period === 'all' ||
          (period === 'today'
            ? sameDoualaDay(r.requestedAt, now)
            : now.getTime() - r.requestedAt.getTime() < 7 * DAY_MS)) &&
        (!q ||
          [r.reference, r.riderName, r.driverName, r.plate].some((s) =>
            s?.toLowerCase().includes(q),
          )),
    );
  }, [all, group, status, pay, period, query, now]);
  const p = paginate(rows, page, PER_PAGE);
  const reset =
    <T,>(set: (v: T) => void) =>
    (v: T) => {
      set(v);
      setPage(1);
    };

  const exportRows = () => {
    saveFile(
      'iyodriver-rides.csv',
      toCsv([
        [
          t('colRideRequested'),
          t('colRider'),
          t('colDriverVehicle'),
          t('colRoute'),
          t('colStatus'),
          `${t('colFare')} (FCFA)`,
          t('colPayment'),
        ],
        ...rows.map((r) => [
          `${r.reference} ${dayMonthTime(r.requestedAt)}`,
          r.riderName,
          [r.driverName, r.plate].filter(Boolean).join(' · '),
          `${areaOf(r.pickup)} → ${areaOf(r.dropoff)}`,
          rideStatusLabel(t, r.status),
          r.fare,
          `${methodName(r.method)} · ${paymentLabel(t, r)}`,
        ]),
      ]),
    );
    toast(t('exported', { n: rows.length }));
  };

  return (
    <Page>
      <PageHeading
        title={t('ridesTitle')}
        subtitle={t('ridesSubtitle')}
        trailing={
          <Button icon={Download} tone="ghost" onClick={exportRows}>
            {t('exportRides')}
          </Button>
        }
      />
      <TabChips
        label={t('allStatuses')}
        value={group}
        onChange={reset(setGroup)}
        items={[
          { value: null, label: t('allRides', { n: count(today.length) }) },
          { value: 'on_trip', label: t('onTripN', { n: count(n('on_trip')) }), idle: 'success' },
          { value: 'arriving', label: t('arrivingN', { n: count(n('arriving')) }) },
          { value: 'matching', label: t('matchingN', { n: count(n('matching')) }) },
          { value: 'cancelled', label: t('cancelledN', { n: count(n('cancelled')) }) },
        ]}
      />
      <Toolbar>
        <SearchBox label={t('searchRides')} value={query} onChange={reset(setQuery)} />
        <Select
          label={t('periodToday')}
          value={period}
          onChange={reset(setPeriod)}
          options={[
            { value: 'today', label: longDate(now) },
            { value: 'week', label: t('periodWeek') },
            { value: 'all', label: t('periodAll') },
          ]}
        />
        <Select
          label={t('allStatuses')}
          value={status}
          onChange={reset(setStatus)}
          options={[
            { value: '', label: t('allStatuses') },
            ...STATUS_FILTERS.map((s) => ({ value: s, label: rideStatusLabel(t, s) })),
          ]}
        />
        <Select
          label={t('paymentStatus')}
          value={pay}
          onChange={reset(setPay)}
          options={[
            { value: '', label: t('paymentStatus') },
            ...PAY_FILTERS.map((s) => ({ value: s, label: paymentName(t, s) })),
          ]}
        />
      </Toolbar>
      <Table
        caption={t('ridesTitle')}
        columns={[
          { label: t('colRideRequested'), width: 123 },
          { label: t('colRider'), width: 116 },
          { label: t('colDriverVehicle'), width: 134 },
          { label: t('colRoute') },
          { label: t('colStatus'), width: 98 },
          { label: t('colFare'), width: 80 },
          { label: t('colPayment'), width: 130 },
          { label: t('colAction'), width: 48 },
        ]}
        empty={t('noRidesMatch')}
        rows={p.shown.map((r) => ({
          key: r.id,
          selected: r.id === lastViewed,
          label: `${r.reference}, ${r.riderName}, ${rideStatusLabel(t, r.status)}`,
          onOpen: () => navigate(`/rides/${r.id}`),
          cells: [
            <Cell2 key="a" top={r.reference} bottom={dayMonthTime(r.requestedAt)} />,
            <Cell2 key="b" top={r.riderName} />,
            <Cell2 key="c" top={r.driverName ?? t('unassigned')} bottom={r.plate} />,
            <Cell2 key="d" top={`${areaOf(r.pickup)} →`} bottom={areaOf(r.dropoff)} />,
            <DotStatus key="e" label={rideStatusLabel(t, r.status)} color={rideDot(r.status)} />,
            <Cell2 key="f" top={<span className="tabular">{formatFcfa(r.fare)}</span>} />,
            <Cell2 key="g" top={`${methodName(r.method)} · ${paymentLabel(t, r)}`} />,
            <Cell2 key="h" top={t('viewArrow')} />,
          ],
        }))}
        footer={
          <TableFooter
            text={t('showingOf', {
              from: count(p.from),
              to: count(p.to),
              total: count(rows.length),
              what: t('ridesWhat'),
            })}
            page={p.page}
            pages={p.pages}
            onPage={setPage}
          />
        }
      />
      <p className="text-[12px] text-sub">{t('ridesNote')}</p>
    </Page>
  );
}
