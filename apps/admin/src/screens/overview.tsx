// Admin · Overview dashboard (Figma 2021:2956).
import { CalendarDays } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router';

import type { AdminOverview, AdminRental, AdminRide, SafetyCase } from '@/data/models';
import {
  keys,
  useLiveDrivers,
  useNow,
  useOverview,
  useRentals,
  useRides,
  useSafetyCases,
} from '@/data/queries';
import { daysBetween } from '@/data/time';
import { Legend, niceMax, PairedBars } from '@/ui/bars';
import { change, count, dayMonth, dayMonthCommaTime, formatFcfa, percent, time } from '@/ui/format';
import {
  Async,
  Button,
  Chip,
  Divider,
  Page,
  PageHeading,
  Panel,
  PanelHeading,
  TextLink,
  TwoLine,
} from '@/ui/kit';
import { OpsMap } from '@/ui/map';
import { caseTitle, documentName } from './labels';

export default function OverviewScreen() {
  const { t } = useTranslation();
  const now = useNow();
  const client = useQueryClient();
  const overview = useOverview();
  return (
    <Page>
      <PageHeading
        title={t('overviewTitle')}
        subtitle={t('overviewSubtitle')}
        trailing={
          <Button
            icon={CalendarDays}
            tone="ghost"
            onClick={() => {
              void client.invalidateQueries({ queryKey: keys.overview });
              void client.invalidateQueries({ queryKey: keys.cases });
            }}
          >
            {t('todayChip', { date: dayMonth(now) })}
          </Button>
        }
      />
      <Async query={overview}>{(o) => <Body o={o} />}</Async>
    </Page>
  );
}

function Body({ o }: { o: AdminOverview }) {
  const { t } = useTranslation();
  const cases = useSafetyCases().data ?? [];
  const rides = useRides().data ?? [];
  const rentals = useRentals().data ?? [];
  const live = useLiveDrivers().data ?? [];
  const available = Math.max(0, o.driversOnline - o.driversOnTrip);
  return (
    <>
      <div className="grid grid-cols-4 gap-4">
        <Metric
          label={t('ridesToday')}
          value={count(o.ridesToday)}
          delta={change(o.ridesToday, o.ridesYesterday)}
        />
        <Metric
          label={t('activeRentals')}
          value={count(o.activeRentals)}
          note={t('pickupsReturns', { pickups: o.pickupsToday, returns: o.returnsToday })}
        />
        <Metric
          label={t('revenueToday')}
          value={formatFcfa(o.revenueToday)}
          delta={change(o.revenueToday, o.revenueYesterday)}
        />
        <Metric
          label={t('driversOnline')}
          value={count(o.driversOnline)}
          note={t('availableOnTrip', {
            available: count(available),
            onTrip: count(o.driversOnTrip),
          })}
        />
      </div>

      <div className="flex items-start gap-5">
        <JourneyPanel o={o} />
        <div className="w-[340px] shrink-0">
          <AttentionPanel o={o} cases={cases} />
        </div>
      </div>

      <div className="flex items-stretch gap-5">
        <Panel className="w-[500px] shrink-0" label={t('liveOperations')}>
          <PanelHeading
            title={t('liveOperations')}
            trailing={
              <Chip tone="success" upper>
                {t('live')}
              </Chip>
            }
          />
          <div className="flex gap-4">
            <div className="w-[280px] shrink-0">
              <OpsMap
                height={145}
                zoom={12}
                label={t('liveOperations')}
                markers={live.map((d) => ({
                  id: d.id,
                  at: d.at,
                  label: d.name,
                  kind:
                    d.state === 'available'
                      ? 'car_available'
                      : d.state === 'to_pickup'
                        ? 'car_pickup'
                        : 'car',
                }))}
              />
            </div>
            <div className="flex flex-col gap-3.5">
              <p className="text-[22px] leading-8 font-semibold">{count(o.ridesInProgress)}</p>
              <p className="text-[11px] text-sub">{t('ridesInProgress')}</p>
              <TextLink to="/live">{t('openLiveMap')}</TextLink>
            </div>
          </div>
        </Panel>
        <LatestActivity rides={rides} rentals={rentals} />
      </div>
    </>
  );
}

function Metric({
  label,
  value,
  delta,
  note,
}: {
  label: string;
  value: string;
  delta?: number | null;
  note?: string;
}) {
  const { t } = useTranslation();
  const text =
    note ??
    (delta === null || delta === undefined
      ? t('noBaseline')
      : t('vsYesterday', { change: percent(delta) }));
  const color = note || delta == null ? 'text-sub' : delta >= 0 ? 'text-ok' : 'text-bad';
  return (
    <section aria-label={label} className="rounded-2xl border border-line bg-white px-5 pt-5 pb-4">
      <h2 className="text-[12px] leading-[26px] text-sub">{label}</h2>
      <p className="tabular truncate text-[28px] leading-[34px] font-semibold">{value}</p>
      <p className={`text-[11px] leading-[34px] ${color}`}>{text}</p>
    </section>
  );
}

function JourneyPanel({ o }: { o: AdminOverview }) {
  const { t } = useTranslation();
  const days = o.daily;
  const maxA = niceMax(Math.max(0, ...days.map((d) => d.rides)));
  const maxB = niceMax(Math.max(0, ...days.map((d) => d.rentals)));
  const first = days[0];
  const last = days.at(-1);
  return (
    <Panel className="min-w-0 flex-1">
      <PanelHeading
        title={t('journeyActivity')}
        subtitle={t('journeySub')}
        trailing={
          first &&
          last && <Chip>{`${dayMonth(first.day).split(' ')[0]}–${dayMonth(last.day)}`}</Chip>
        }
      />
      <div className="flex flex-col gap-2.5">
        <Legend
          items={[
            ['#191919', t('legendRides')],
            ['#f6c200', t('legendRentals', { max: count(maxB) })],
          ]}
        />
        <PairedBars
          days={days.map((d) => ({ label: dayMonth(d.day), a: d.rides, b: d.rentals }))}
          maxA={maxA}
          maxB={maxB}
          height={188}
          barWidth={30}
          gap={4}
          axis={[count(maxA), count(maxA / 2), '0']}
          caption={t('journeyActivity')}
          names={[t('navRides'), t('navRentals')]}
        />
      </div>
    </Panel>
  );
}

function AttentionPanel({ o, cases }: { o: AdminOverview; cases: SafetyCase[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const open = cases.filter((c) => c.status !== 'resolved');
  const high = open.filter((c) => c.severity === 'high');
  const top = high[0] ?? open[0];
  const doc = o.expiring[0];
  const when = (d: Date) => {
    const n = daysBetween(now, d);
    return n <= 0 ? t('today') : n === 1 ? t('tomorrow') : t('onDate', { date: dayMonth(d) });
  };
  const first = (s?: string) => (s ?? '').split(' ')[0] ?? '';
  return (
    <Panel>
      <PanelHeading
        title={t('needsAttention')}
        subtitle={open.length ? t('openAlerts', { n: open.length }) : t('noOpenAlerts')}
        trailing={
          high.length > 0 && (
            <Chip tone="danger" upper>
              {t('highCount', { n: high.length })}
            </Chip>
          )
        }
      />
      {top && (
        <div className="flex flex-col gap-2 rounded-[10px] bg-bad-soft p-3.5">
          <p className={`text-[12px] font-semibold ${top.severity === 'high' ? 'text-bad' : ''}`}>
            {caseTitle(t, top.category)} · {top.rideRef ?? top.rentalRef ?? top.reference}
          </p>
          <p className="text-[11px]">
            {t('receivedAt', {
              place: top.place?.split(',').at(-1)?.trim() ?? '',
              time: time(top.createdAt),
            })}
          </p>
          <p className="text-[10px] text-sub">
            {top.assigneeName
              ? t('assignedTo', { name: first(top.personName), admin: top.assigneeName })
              : t('unassignedReview', { name: first(top.personName) })}
          </p>
          <TextLinkCentered to={`/safety?case=${top.reference}`}>
            {t('reviewIncident')}
          </TextLinkCentered>
        </div>
      )}
      {doc && (
        <>
          <Divider />
          <TwoLine
            to="/drivers"
            title={t('docExpiring')}
            subtitle={t('docExpiresOn', {
              driver: doc.driverRef,
              doc: documentName(t, doc.type),
              when: when(doc.expiresOn),
            })}
          />
        </>
      )}
      <Divider />
      <TextLink to="/safety">{t('openSafety')}</TextLink>
    </Panel>
  );
}

function TextLinkCentered({ to, children }: { to: string; children: string }) {
  return (
    <Link
      to={to}
      className="flex h-10 items-center justify-center text-[12px] font-semibold text-bad hover:underline"
    >
      {children}
    </Link>
  );
}

function LatestActivity({ rides, rentals }: { rides: AdminRide[]; rentals: AdminRental[] }) {
  const { t } = useTranslation();
  const ride = rides.find((r) => r.status === 'completed');
  const rental = rentals.find((r) => r.status === 'driver_assigned' || r.status === 'confirmed');
  return (
    <Panel className="min-w-0 flex-1">
      <PanelHeading title={t('latestActivity')} subtitle={t('acrossRidesRentals')} />
      {ride && (
        <TwoLine
          to={`/rides/${ride.id}`}
          title={t('rideCompleted', { ref: ride.reference })}
          aside={formatFcfa(ride.fare)}
          subtitle={`${ride.riderName} · ${ride.driverName ?? ''} · ${time(ride.requestedAt)}`}
        />
      )}
      {ride && rental && <Divider />}
      {rental && (
        <TwoLine
          to="/rentals"
          title={t('rentalConfirmedAct', {
            ref: rental.reference,
            kind: rental.airportCode ? t('airportPickup') : t('delivery'),
          })}
          aside={formatFcfa(rental.totalAmount)}
          subtitle={`${rental.airportCode ? `Douala (${rental.airportCode})` : rental.place} · ${dayMonthCommaTime(rental.startsAt)} · ${rental.customer}`}
        />
      )}
    </Panel>
  );
}
