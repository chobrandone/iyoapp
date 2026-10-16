// Admin · Live operations map (Figma 2021:3074).
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate } from 'react-router';

import { isActiveRide, type AdminRide, type LiveDriverState } from '@/data/models';
import { useLiveDrivers, useNow, useRides } from '@/data/queries';
import { areaOf } from '@/data/time';
import { count, timeSeconds } from '@/ui/format';
import {
  Async,
  Button,
  Chip,
  cx,
  Page,
  PageHeading,
  Panel,
  PanelHeading,
  SearchBox,
  Select,
  Toolbar,
} from '@/ui/kit';
import { OpsMap, type MapMarker } from '@/ui/map';
import { groupLabel, rideGroup, rideStatusLabel, type RideGroup } from './labels';

export default function LiveScreen() {
  const rides = useRides();
  return <Async query={rides}>{(all) => <LiveBody all={all} />}</Async>;
}

function LiveBody({ all }: { all: AdminRide[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const navigate = useNavigate();
  const drivers = useLiveDrivers();
  const [query, setQuery] = useState('');
  const [group, setGroup] = useState<RideGroup | ''>('');
  const [state, setState] = useState<LiveDriverState | ''>('');
  const [selectedId, setSelectedId] = useState<string>();

  const q = query.trim().toLowerCase();
  const active = all
    .filter(
      (r) =>
        isActiveRide(r) &&
        (!group || rideGroup(r.status) === group) &&
        (!q || [r.reference, r.riderName, r.driverName].some((s) => s?.toLowerCase().includes(q))),
    )
    .sort((a, b) => b.reference.localeCompare(a.reference));
  const selected =
    active.find((r) => r.id === selectedId) ?? active.find((r) => r.hasOpenAlert) ?? active[0];
  const listed = [...(selected ? [selected] : []), ...active.filter((r) => r !== selected)].slice(
    0,
    5,
  );
  const live = drivers.data ?? [];
  const n = (s: LiveDriverState) => live.filter((d) => d.state === s).length;

  const markers: MapMarker[] = (() => {
    const m: MapMarker[] = live
      .filter((d) => !state || d.state === state)
      .map((d) => ({
        id: d.id,
        at: d.at,
        label: d.name,
        kind:
          d.state === 'available'
            ? 'car_available'
            : d.state === 'to_pickup'
              ? 'car_pickup'
              : 'car',
      }));
    if (selected?.pickup.location)
      m.push({
        id: 'pickup',
        at: selected.pickup.location,
        kind: 'pickup',
        label: selected.pickup.name,
      });
    return m;
  })();

  const stateName = (s: LiveDriverState) =>
    ({ available: t('avAvailable'), on_trip: t('stOnTrip'), to_pickup: t('stArriving') })[s];

  return (
    <Page>
      <PageHeading
        title={t('navLive')}
        subtitle={t('liveSubtitle')}
        trailing={
          <Chip tone="success" upper>
            {t('liveUpdated', { time: timeSeconds(now) })}
          </Chip>
        }
      />
      <Toolbar>
        <SearchBox label={t('findTrip')} value={query} onChange={setQuery} />
        <Select
          label={t('cityField')}
          value="DLA"
          onChange={() => {}}
          options={[{ value: 'DLA', label: 'Douala' }]}
        />
        <Select
          label={t('allRideStatuses')}
          value={group}
          onChange={setGroup}
          options={[
            { value: '', label: t('allRideStatuses') },
            ...(['matching', 'arriving', 'on_trip'] as const).map((g) => ({
              value: g,
              label: groupLabel(t, g),
            })),
          ]}
        />
        <Select
          label={t('allDrivers')}
          value={state}
          onChange={setState}
          options={[
            { value: '', label: t('allDrivers') },
            ...(['available', 'on_trip', 'to_pickup'] as const).map((s) => ({
              value: s,
              label: stateName(s),
            })),
          ]}
        />
      </Toolbar>
      <div className="flex items-start gap-5">
        <div className="flex min-w-0 flex-1 flex-col gap-3.5">
          <OpsMap
            height={495}
            label={t('navLive')}
            markers={markers}
            route={
              selected?.pickup.location &&
              selected.dropoff.location &&
              rideGroup(selected.status) === 'on_trip'
                ? [selected.pickup.location, selected.dropoff.location]
                : undefined
            }
          />
          <ul className="flex h-[47px] items-center gap-5 rounded-[10px] bg-white px-4">
            {(
              [
                ['bg-ok', t('availableN', { n: count(n('available')) })],
                ['bg-ink', t('onTripN', { n: count(n('on_trip')) })],
                ['bg-accent', t('pickupN', { n: count(n('to_pickup')) })],
              ] as const
            ).map(([c, label]) => (
              <li key={label} className="flex items-center gap-2 text-[10px]">
                <span aria-hidden className={`size-2 rounded-full ${c}`} />
                {label}
              </li>
            ))}
          </ul>
          {selected && (
            <Panel label={t('selectedTrip', { ref: selected.reference })}>
              <PanelHeading
                title={t('selectedTrip', { ref: selected.reference })}
                trailing={
                  <Chip tone="accent" upper>
                    {selected.status === 'driver_arriving'
                      ? t('driverArriving')
                      : rideStatusLabel(t, selected.status)}
                  </Chip>
                }
              />
              <div className="flex items-center gap-4">
                <div className="min-w-0 flex-1">
                  <p className="text-[13px] font-medium">
                    {selected.pickup.name} → {selected.dropoff.name}
                  </p>
                  <p className="mt-1.5 text-[11px] text-sub">
                    {[
                      selected.riderName,
                      selected.driverName,
                      selected.vehicle && `${selected.vehicle} ${selected.plate ?? ''}`,
                    ]
                      .filter(Boolean)
                      .join(' · ')}
                  </p>
                </div>
                <Button tone="primary" onClick={() => navigate(`/rides/${selected.id}`)}>
                  {t('openTrip')}
                </Button>
              </div>
            </Panel>
          )}
        </div>
        <Panel className="w-[418px] shrink-0">
          <PanelHeading
            title={t('activeTrips')}
            subtitle={t('activeTripsSub', {
              onTrip: count(active.filter((r) => rideGroup(r.status) === 'on_trip').length),
              pickup: count(active.filter((r) => rideGroup(r.status) === 'arriving').length),
            })}
            trailing={
              <Link to="/rides" className="text-[11px] font-medium hover:underline">
                {t('viewAll')}
              </Link>
            }
          />
          {listed.length === 0 && <p className="text-[12px] text-sub">{t('noActiveTrips')}</p>}
          <ul className="flex flex-col gap-4">
            {listed.map((r) => (
              <li key={r.id}>
                <TripCard ride={r} selected={r === selected} onSelect={() => setSelectedId(r.id)} />
              </li>
            ))}
          </ul>
        </Panel>
      </div>
    </Page>
  );
}

function TripCard({
  ride,
  selected,
  onSelect,
}: {
  ride: AdminRide;
  selected: boolean;
  onSelect: () => void;
}) {
  const { t } = useTranslation();
  const g = rideGroup(ride.status);
  const label = rideStatusLabel(t, ride.status);
  return (
    <div className={cx('rounded-[10px] px-3 py-2.5', selected ? 'bg-accent-soft' : 'bg-canvas')}>
      <button
        type="button"
        aria-pressed={selected}
        onClick={onSelect}
        className="block w-full cursor-pointer text-left"
      >
        <span className="flex items-center gap-2">
          <span className="flex-1 text-[12px] leading-6 font-medium">{ride.reference}</span>
          {selected ? (
            <span className="text-[10px] font-medium">{label}</span>
          ) : (
            <Chip tone={g === 'matching' ? 'accent' : 'success'}>{label}</Chip>
          )}
        </span>
        <span className="block text-[10px] leading-6">
          {[ride.riderName, ride.driverName].filter(Boolean).join(' · ')}
        </span>
        <span className="block text-[11px] text-sub">
          {areaOf(ride.pickup)} → {areaOf(ride.dropoff)}
        </span>
      </button>
      {ride.hasOpenAlert && (
        <Link to="/safety" className="mt-1 block text-[10px] leading-6 text-bad hover:underline">
          {t('safetyCallback')}
        </Link>
      )}
    </div>
  );
}
