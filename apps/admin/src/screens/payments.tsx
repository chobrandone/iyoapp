// Admin · Payments, refunds and driver payouts (Figma 2021:3878).
import { Download } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router';

import type { AdminTransaction, PaymentsSummary, TransactionKind } from '@/data/models';
import { useNow, usePaymentsSummary, useTransactions } from '@/data/queries';
import { addDays, DAY_MS, doualaDay, doualaParts } from '@/data/time';
import { Legend, niceMax, PairedBars } from '@/ui/bars';
import { saveFile, toCsv } from '@/ui/download';
import {
  count,
  dayMonth,
  dayMonthTime,
  dayRange,
  formatFcfa,
  longDateTime,
  signedFcfa,
} from '@/ui/format';
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
  Panel,
  PanelHeading,
  SearchBox,
  Select,
  Table,
  TableFooter,
  TabChips,
  Toolbar,
} from '@/ui/kit';
import { useToast } from '@/ui/toast';
import { kindName, txStatusName } from './labels';
import { RefundDialog } from './refund-dialog';

const PER_PAGE = 6;
type Tab = 'payments' | 'refunds' | 'payouts' | 'deposits';
const TAB_KINDS: Record<Tab, TransactionKind[]> = {
  payments: ['ride_payment', 'rental_payment'],
  refunds: ['refund'],
  payouts: ['payout'],
  deposits: ['deposit_hold'],
};
const KINDS: TransactionKind[] = [
  'ride_payment',
  'rental_payment',
  'deposit_hold',
  'refund',
  'payout',
];

/** "1.5M", "30k" axis labels. */
const short = (v: number) =>
  v >= 1_000_000
    ? `${+(v / 1_000_000).toFixed(1)}M`
    : v >= 1000
      ? `${Math.round(v / 1000)}k`
      : String(v);

export default function PaymentsScreen() {
  const tx = useTransactions();
  return <Async query={tx}>{(all) => <PaymentsBody all={all} />}</Async>;
}

function PaymentsBody({ all }: { all: AdminTransaction[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const toast = useToast();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const summary = usePaymentsSummary();
  const [tab, setTab] = useState<Tab | null>(null);
  const [kind, setKind] = useState<TransactionKind | ''>('');
  const [status, setStatus] = useState('');
  const [period, setPeriod] = useState<'week' | 'all'>(params.get('q') ? 'all' : 'week');
  const [query, setQuery] = useState(params.get('q') ?? '');
  const [page, setPage] = useState(1);
  const [open, setOpen] = useState<AdminTransaction>();
  const [refund, setRefund] = useState<AdminTransaction>();

  const rows = useMemo(() => {
    const q = query.trim().toLowerCase();
    return all.filter(
      (x) =>
        (!tab || TAB_KINDS[tab].includes(x.kind)) &&
        (!kind || x.kind === kind) &&
        (!status || x.status === status) &&
        (period === 'all' || now.getTime() - x.at.getTime() < 7 * DAY_MS) &&
        (!q || [x.reference, x.bookingRef, x.party].some((s) => s.toLowerCase().includes(q))),
    );
  }, [all, tab, kind, status, period, query, now]);
  const p = paginate(rows, page, PER_PAGE);
  const statuses = [...new Set(all.map((x) => x.status))].sort();
  const week = dayRange(addDays(now, -6), now);
  const reset =
    <T,>(set: (v: T) => void) =>
    (v: T) => {
      set(v);
      setPage(1);
    };

  const action = (x: AdminTransaction) =>
    ({
      refund: t('aViewRefund'),
      deposit_hold: t('aViewHold'),
      payout: t('aStatement'),
      ride_payment: x.refundable ? t('aReviewRefund') : t('viewArrow'),
      rental_payment: x.refundable ? t('aReviewRefund') : t('viewArrow'),
    })[x.kind];
  const openRow = (x: AdminTransaction) => {
    if (x.refundable && x.paymentId) return setRefund(x);
    if (x.kind === 'ride_payment') return navigate(`/rides?q=${encodeURIComponent(x.bookingRef)}`);
    if (x.kind === 'rental_payment')
      return navigate(`/rentals?q=${encodeURIComponent(x.bookingRef)}`);
    setOpen(x);
  };
  const exportRows = () => {
    saveFile(
      'iyodriver-statement.csv',
      toCsv([
        [
          t('colTransaction'),
          t('colTypeRef'),
          'Ref',
          t('colParty'),
          t('colMethod'),
          t('colDateTime'),
          `${t('colAmount')} (FCFA)`,
          t('colStatus'),
        ],
        ...rows.map((x) => [
          x.reference,
          kindName(t, x.kind),
          x.bookingRef,
          x.party,
          x.method,
          dayMonthTime(x.at),
          x.amount,
          txStatusName(t, x.status),
        ]),
      ]),
    );
    toast(t('exported', { n: rows.length }));
  };

  return (
    <Page>
      <PageHeading
        title={t('paymentsTitle')}
        subtitle={t('paymentsSubtitle')}
        trailing={
          <Button icon={Download} tone="ghost" onClick={exportRows}>
            {t('exportStatement')}
          </Button>
        }
      />
      <Async query={summary}>
        {(s) => (
          <div className="flex items-start gap-5">
            <RevenuePanel s={s} />
            <ReconPanel s={s} now={now} />
          </div>
        )}
      </Async>
      <TabChips
        label={t('tabAll')}
        value={tab}
        onChange={reset(setTab)}
        items={[
          { value: null, label: t('tabAll') },
          { value: 'payments', label: t('tabPayments') },
          { value: 'refunds', label: t('tabRefunds') },
          { value: 'payouts', label: t('tabPayouts') },
          { value: 'deposits', label: t('tabDeposits') },
        ]}
      />
      <Toolbar>
        <SearchBox label={t('searchTransactions')} value={query} onChange={reset(setQuery)} />
        <Select
          label={t('periodAll')}
          value={period}
          onChange={reset(setPeriod)}
          options={[
            { value: 'week', label: week },
            { value: 'all', label: t('periodAll') },
          ]}
        />
        <Select
          label={t('allTypes')}
          value={kind}
          onChange={reset(setKind)}
          options={[
            { value: '', label: t('allTypes') },
            ...KINDS.map((k) => ({ value: k, label: kindName(t, k) })),
          ]}
        />
        <Select
          label={t('allStatuses')}
          value={status}
          onChange={reset(setStatus)}
          options={[
            { value: '', label: t('allStatuses') },
            ...statuses.map((s) => ({ value: s, label: txStatusName(t, s) })),
          ]}
        />
      </Toolbar>
      <Table
        caption={t('tabAll')}
        columns={[
          { label: t('colTransaction'), width: 90 },
          { label: t('colTypeRef'), width: 133 },
          { label: t('colParty'), width: 135 },
          { label: t('colMethod'), width: 145 },
          { label: t('colDateTime'), width: 122 },
          { label: t('colAmount'), width: 100 },
          { label: t('colStatus'), width: 103 },
          { label: t('colAction') },
        ]}
        rows={p.shown.map((x) => ({
          key: x.id,
          label: `${x.reference}, ${kindName(t, x.kind)}, ${signedFcfa(x.amount)}`,
          onOpen: () => openRow(x),
          cells: [
            <Cell2 key="a" top={x.reference} />,
            <Cell2 key="b" top={kindName(t, x.kind)} bottom={x.bookingRef} />,
            <Cell2 key="c" top={x.party} />,
            <Cell2 key="d" top={x.method} />,
            <Cell2 key="e" top={dayMonthTime(x.at)} />,
            <Cell2 key="f" top={<span className="tabular">{signedFcfa(x.amount)}</span>} />,
            <DotStatus
              key="g"
              label={txStatusName(t, x.status)}
              color={x.tone === 'success' ? 'ok' : x.tone === 'danger' ? 'bad' : 'ink'}
            />,
            <Cell2 key="h" top={action(x)} />,
          ],
        }))}
        footer={
          <TableFooter
            text={t('showingOf', {
              from: count(p.from),
              to: count(p.to),
              total: count(rows.length),
              what: t('txWhat'),
            })}
            page={p.page}
            pages={p.pages}
            onPage={setPage}
          />
        }
      />
      <Dialog
        open={Boolean(open)}
        onClose={() => setOpen(undefined)}
        title={open ? `${open.reference} · ${kindName(t, open.kind)}` : ''}
        actions={<Button onClick={() => setOpen(undefined)}>{t('close')}</Button>}
      >
        {open && (
          <dl className="flex flex-col gap-2.5">
            <AmountLine label={t('colTypeRef')} value={open.bookingRef} />
            <AmountLine label={t('colParty')} value={open.party} />
            <AmountLine label={t('colMethod')} value={open.method} />
            <AmountLine label={t('colDateTime')} value={longDateTime(open.at)} />
            <AmountLine label={t('colStatus')} value={txStatusName(t, open.status)} />
            <AmountLine label={t('colAmount')} value={signedFcfa(open.amount)} strong />
          </dl>
        )}
      </Dialog>
      {refund?.paymentId && (
        <RefundDialog
          open
          onClose={() => setRefund(undefined)}
          paymentId={refund.paymentId}
          bookingRef={refund.bookingRef}
          max={refund.amount}
        />
      )}
    </Page>
  );
}

function RevenuePanel({ s }: { s: PaymentsSummary }) {
  const { t } = useTranslation();
  const total = s.daily.reduce((n, d) => n + d.rides + d.rentals, 0);
  const max = niceMax(Math.max(0, ...s.daily.flatMap((d) => [d.rides, d.rentals])));
  const first = s.daily[0];
  const last = s.daily.at(-1);
  return (
    <Panel className="min-w-0 flex-1">
      <PanelHeading
        title={t('revenueTotal', { amount: formatFcfa(total) })}
        subtitle={first && last && t('revenueSub', { range: dayRange(first.day, last.day) })}
      />
      <div className="flex flex-col gap-2.5">
        <Legend
          items={[
            ['#191919', t('rideRevenue')],
            ['#f6c200', t('rentalRevenue')],
          ]}
        />
        <PairedBars
          days={s.daily.map((d) => ({ label: dayMonth(d.day), a: d.rides, b: d.rentals }))}
          maxA={max}
          maxB={max}
          height={124}
          barWidth={18}
          gap={6}
          axis={[short(max), short(max / 2), '0']}
          caption={t('revenueTotal', { amount: formatFcfa(total) })}
          names={[t('rideRevenue'), t('rentalRevenue')]}
        />
      </div>
    </Panel>
  );
}

function ReconPanel({ s, now }: { s: PaymentsSummary; now: Date }) {
  const { t } = useTranslation();
  const today = doualaDay(now);
  // Payouts run every Monday.
  const ahead = (8 - doualaParts(today).weekday) % 7 || 7;
  const monday = addDays(today, ahead);
  return (
    <Panel className="w-[412px] shrink-0">
      <PanelHeading title={t('reconciliation')} />
      <dl className="flex flex-col gap-3.5">
        <AmountLine label={t('capturedRevenue')} value={formatFcfa(s.capturedToday)} strong />
        <AmountLine label={t('refundsProcessing')} value={formatFcfa(s.refundsProcessing)} />
        <AmountLine label={t('depositHolds')} value={formatFcfa(s.depositHolds)} />
        <AmountLine
          label={t('nextPayoutRun', { date: dayMonth(monday) })}
          value={formatFcfa(s.nextPayout)}
        />
      </dl>
      <p className="text-[10px] text-sub">{t('reconNote')}</p>
    </Panel>
  );
}
