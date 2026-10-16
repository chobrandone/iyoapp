// Admin · Ride detail (Figma 2021:3274).
import { Download } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useParams } from 'react-router';

import type { AdminRideDetail, PersonContact } from '@/data/models';
import { useRide } from '@/data/queries';
import { saveFile } from '@/ui/download';
import {
  dayMonthCommaTime,
  dayMonthTime,
  distance,
  formatFcfa,
  longDate,
  longDateTime,
  methodName,
  phone,
  time,
} from '@/ui/format';
import {
  AmountLine,
  Async,
  Button,
  Chip,
  Divider,
  Page,
  PageHeading,
  Panel,
  PanelHeading,
  Timeline,
} from '@/ui/kit';
import { OpsMap, type MapMarker } from '@/ui/map';
import { Avatar } from '@/ui/shell';
import { paymentLabel, rideStatusLabel, rideTone } from './labels';
import { RefundDialog } from './refund-dialog';
import { markViewed } from './rides';

export default function RideDetailScreen() {
  const { id = '' } = useParams();
  const ride = useRide(id);
  useEffect(() => markViewed(id), [id]);
  return <Async query={ride}>{(d) => <Detail d={d} />}</Async>;
}

function Detail({ d }: { d: AdminRideDetail }) {
  const { t } = useTranslation();
  const r = d.ride;
  const receipt = () => {
    const lines = [
      `iyodriver · ${t('rideTitle', { ref: r.reference })}`,
      longDateTime(r.requestedAt),
      `${r.pickup.address} → ${r.dropoff.address}`,
      `${distance(r.distanceMeters)} · ${Math.round(r.durationSeconds / 60)} min`,
      '',
      `${t('baseFare')}: ${formatFcfa(d.baseFare)}`,
      `${t('distanceTime')}: ${formatFcfa(d.distanceTimeFare)}`,
      `${t('adjustments')}: ${formatFcfa(d.adjustments)}`,
      `${t('totalCharged')}: ${formatFcfa(r.fare)}`,
      ...(d.refundedAmount ? [`${t('refundedLine')}: −${formatFcfa(d.refundedAmount)}`] : []),
      `${methodName(r.method)}${d.paymentReference ? ` · ${d.paymentReference}` : ''}`,
      '',
      `${t('colRider')}: ${d.rider.name}`,
      ...(d.driver ? [`${t('colDriver')}: ${d.driver.name} · ${d.driver.detail ?? ''}`] : []),
    ];
    saveFile(`iyodriver-${r.reference}.txt`, `${lines.join('\r\n')}\r\n`, 'text/plain');
  };
  return (
    <Page>
      <PageHeading
        title={t('rideTitle', { ref: r.reference })}
        subtitle={
          <>
            <Link to="/rides" className="hover:underline">
              {t('navRides')}
            </Link>
            {` / ${r.reference} · ${longDate(r.requestedAt)} · Douala`}
          </>
        }
        trailing={
          <div className="flex items-center gap-5">
            <Chip tone={rideTone(r.status)} upper>
              {rideStatusLabel(t, r.status)}
            </Chip>
            <Button
              icon={Download}
              tone="ghost"
              disabled={r.status !== 'completed'}
              onClick={receipt}
            >
              {t('downloadReceipt')}
            </Button>
          </div>
        }
      />
      <div className="flex items-start gap-5">
        <div className="flex min-w-0 flex-1 flex-col gap-5">
          <RoutePanel d={d} />
          <SupportPanel d={d} />
        </div>
        <div className="flex w-[480px] shrink-0 flex-col gap-5">
          <PeoplePanel d={d} />
          <FarePanel d={d} />
        </div>
      </div>
    </Page>
  );
}

function RoutePanel({ d }: { d: AdminRideDetail }) {
  const { t } = useTranslation();
  const r = d.ride;
  const category = r.categoryCode ? r.categoryCode[0]!.toUpperCase() + r.categoryCode.slice(1) : '';
  const markers: MapMarker[] = [];
  if (r.pickup.location)
    markers.push({ id: 'p', at: r.pickup.location, kind: 'pickup', label: r.pickup.name });
  if (r.dropoff.location)
    markers.push({ id: 'd', at: r.dropoff.location, kind: 'dropoff', label: r.dropoff.name });
  return (
    <Panel>
      <PanelHeading
        title={t('routeTimeline')}
        subtitle={t('routeSummary', {
          distance: distance(r.distanceMeters),
          minutes: Math.round(r.durationSeconds / 60),
          category,
        })}
      />
      <OpsMap
        height={230}
        label={t('routeTimeline')}
        markers={markers}
        route={
          r.pickup.location && r.dropoff.location
            ? [r.pickup.location, r.dropoff.location]
            : undefined
        }
      />
      <Timeline
        items={d.timeline.map((e) => ({ title: e.title, detail: e.detail, time: time(e.at) }))}
      />
    </Panel>
  );
}

function SupportPanel({ d }: { d: AdminRideDetail }) {
  const { t } = useTranslation();
  const r = d.ride;
  return (
    <Panel>
      <PanelHeading
        title={t('supportRecord')}
        subtitle={d.incidents ? t('openCasesN', { n: d.incidents }) : t('noOpenCases')}
        trailing={
          <Link
            to="/safety"
            className="inline-flex h-10 items-center rounded-[10px] bg-canvas px-4 text-[12px] font-semibold hover:bg-[#ecece8]"
          >
            {t('createCase')}
          </Link>
        }
      />
      <div className="flex flex-col gap-1.5">
        <h3 className="text-[13px] font-medium">{t('receiptDelivered')}</h3>
        <p className="text-[11px] text-sub">
          {d.receiptAt
            ? t('receiptWhen', { when: dayMonthCommaTime(d.receiptAt) })
            : t('receiptPending')}
        </p>
      </div>
      {d.incidents === 0 && (
        <p className="text-[11px] text-sub">
          {d.riderRatingGiven
            ? t('noIncidentRating', { ref: r.reference, stars: d.riderRatingGiven })
            : t('noIncidentNoRating', { ref: r.reference })}
        </p>
      )}
    </Panel>
  );
}

function Person({
  p,
  line,
  extra,
}: {
  p: PersonContact;
  line: string;
  extra: (string | undefined)[];
}) {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-3.5">
        <Avatar name={p.name} size={56} />
        <div>
          <h3 className="text-[16px] font-medium">{p.name}</h3>
          <p className="text-[11px] text-sub">{line}</p>
        </div>
      </div>
      {extra.filter(Boolean).map((e) =>
        e!.startsWith('+') ? (
          <a key={e} href={`tel:${e!.replace(/\s/g, '')}`} className="text-[11px] hover:underline">
            {e}
          </a>
        ) : e!.includes('@') ? (
          <a key={e} href={`mailto:${e}`} className="text-[11px] text-sub hover:underline">
            {e}
          </a>
        ) : (
          <p key={e} className="text-[11px] text-sub">
            {e}
          </p>
        ),
      )}
    </div>
  );
}

function PeoplePanel({ d }: { d: AdminRideDetail }) {
  const { t } = useTranslation();
  const rating = (v?: number) => (v == null ? '—' : v.toFixed(1));
  return (
    <Panel>
      <PanelHeading title={t('riderDriver')} />
      <Person
        p={d.rider}
        line={t('riderRef', { ref: d.rider.reference, rating: rating(d.rider.rating) })}
        extra={[d.rider.phone && phone(d.rider.phone), d.rider.email]}
      />
      <Divider />
      {d.driver ? (
        <Person
          p={d.driver}
          line={t('driverRefLine', { ref: d.driver.reference, rating: rating(d.driver.rating) })}
          extra={[d.driver.phone && phone(d.driver.phone), d.driver.detail]}
        />
      ) : (
        <p className="text-[12px] text-sub">{t('noDriverYet')}</p>
      )}
    </Panel>
  );
}

function FarePanel({ d }: { d: AdminRideDetail }) {
  const { t } = useTranslation();
  const [refunding, setRefunding] = useState(false);
  const r = d.ride;
  const paid = r.paymentStatus === 'succeeded' || (r.method === 'cash' && r.status === 'completed');
  const remaining = r.fare - d.refundedAmount;
  const canRefund = Boolean(d.paymentId) && r.paymentStatus === 'succeeded' && remaining > 0;
  return (
    <Panel>
      <PanelHeading
        title={t('farePayment')}
        trailing={
          <Chip tone={paid ? 'success' : r.paymentStatus === 'failed' ? 'danger' : 'neutral'} upper>
            {paymentLabel(t, r)}
          </Chip>
        }
      />
      <dl className="flex flex-col gap-3">
        <AmountLine label={t('baseFare')} value={formatFcfa(d.baseFare)} />
        <AmountLine label={t('distanceTime')} value={formatFcfa(d.distanceTimeFare)} />
        <AmountLine label={t('adjustments')} value={formatFcfa(d.adjustments)} />
        <AmountLine label={t('totalCharged')} value={formatFcfa(r.fare)} strong />
        {d.refundedAmount > 0 && (
          <AmountLine label={t('refundedLine')} value={`−${formatFcfa(d.refundedAmount)}`} />
        )}
        <AmountLine label={t('driverNet')} value={formatFcfa(r.driverEarnings)} />
      </dl>
      <div className="flex flex-col gap-1.5">
        <p className="text-[13px] font-medium">{methodName(r.method)}</p>
        <p className="text-[11px] text-sub">
          {r.method === 'cash'
            ? t('cashCollected')
            : d.capturedAt
              ? t('capturedOn', { ref: d.paymentReference ?? '', when: dayMonthTime(d.capturedAt) })
              : t('notCaptured')}
        </p>
      </div>
      <Button block disabled={!canRefund} onClick={() => setRefunding(true)}>
        {t('reviewRefund')}
      </Button>
      <p className="text-[10px] text-sub">
        {d.refundedAmount > 0
          ? t('refundIssued', { amount: formatFcfa(d.refundedAmount) })
          : t('refundNote')}
      </p>
      {d.paymentId && (
        <RefundDialog
          open={refunding}
          onClose={() => setRefunding(false)}
          paymentId={d.paymentId}
          bookingRef={r.reference}
          max={remaining}
          rideId={r.id}
        />
      )}
    </Panel>
  );
}
