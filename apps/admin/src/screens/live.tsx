// Admin · Live operations map (Figma 2021:3074).
import { MapPin, X } from 'lucide-react';
import { useEffect, useRef, useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate, useSearchParams } from 'react-router';

import { isActiveRide, type AdminRide, type LiveDriverState, type Place } from '@/data/models';
import { useLiveDrivers, useNow, useRepo, useRides } from '@/data/queries';
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
  // A new header search starts a fresh search here.
  const [params] = useSearchParams();
  return <Async query={rides}>{(all) => <LiveBody key={params.get('q') ?? ''} all={all} />}</Async>;
}

function LiveBody({ all }: { all: AdminRide[] }) {
  const { t } = useTranslation();
  const now = useNow();
  const navigate = useNavigate();
  const drivers = useLiveDrivers();
  const repo = useRepo();
  const [params] = useSearchParams();
  const [query, setQuery] = useState(params.get('q') ?? '');
  const [places, setPlaces] = useState<Place[]>([]);
  const [place, setPlace] = useState<Place>();
  const [lookup, setLookup] = useState<'idle' | 'searching' | 'none'>('idle');
  const searched = useRef<string>('');
  const [group, setGroup] = useState<RideGroup | ''>('');
  const [state, setState] = useState<LiveDriverState | ''>('');
  const [selectedId, setSelectedId] = useState<string>();

  const q = place || lookup !== 'idle' ? '' : query.trim().toLowerCase();
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
  // A search that matches no active trip is treated as a place: the map moves there.
  const findPlace = async (text: string) => {
    const term = text.trim();
    if (term.length < 2 || searched.current === term) return;
    searched.current = term;
    setLookup('searching');
    try {
      const found = (await repo.searchPlaces(term)).filter((p) => p.location);
      if (searched.current !== term) return;
      setPlaces(found);
      setPlace(found[0]);
      setLookup(found.length ? 'idle' : 'none');
    } catch {
      setLookup('none');
    }
  };
  const tripMatches = (text: string) => {
    const s = text.trim().toLowerCase();
    return all.some(
      (r) =>
        isActiveRide(r) &&
        [r.reference, r.riderName, r.driverName].some((x) => x?.toLowerCase().includes(s)),
    );
  };
  const submit = (e: FormEvent) => {
    e.preventDefault();
    if (query.trim() && !tripMatches(query)) {
      searched.current = '';
      void findPlace(query);
    }
  };
  const clearPlace = () => {
    setPlace(undefined);
    setPlaces([]);
    setLookup('idle');
    setQuery('');
    searched.current = '';
  };
  // Arriving from the header search with ?q=…
  useEffect(() => {
    const initial = params.get('q');
    if (!initial || tripMatches(initial)) return;
    const id = setTimeout(() => void findPlace(initial));
    return () => clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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
        <form role="search" onSubmit={submit} className="flex min-w-0 flex-1">
          <SearchBox
            label={t('findTripOrPlace')}
            value={query}
            onChange={(v) => {
              setQuery(v);
              if (place || lookup !== 'idle') {
                setPlace(undefined);
                setPlaces([]);
                setLookup('idle');
                searched.current = '';
              }
            }}
          />
        </form>
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
      {(place || lookup !== 'idle') && (
        <div role="status" className="-mt-2 flex flex-wrap items-center gap-2 text-[12px]">
          {lookup === 'searching' && <span className="text-sub">{t('searchingPlaces')}</span>}
          {lookup === 'none' && (
            <>
              <span className="text-sub">{t('placeNotFound', { q: query.trim() })}</span>
              <Link
                to={`/rides?q=${encodeURIComponent(query.trim())}`}
                className="font-medium hover:underline"
              >
                {t('searchRidesFor', { q: query.trim() })}
              </Link>
            </>
          )}
          {place && lookup === 'idle' && (
            <>
              <MapPin size={14} aria-hidden />
              <span className="font-medium">{t('placeShowing', { name: place.name })}</span>
              <span className="truncate text-sub">{place.address}</span>
              {places.length > 1 && (
                <span className="flex flex-wrap gap-1.5" aria-label={t('otherPlaces')}>
                  {places
                    .filter((p) => p !== place)
                    .map((p) => (
                      <button
                        key={p.address}
                        type="button"
                        onClick={() => setPlace(p)}
                        className="cursor-pointer rounded-md bg-white px-2 py-0.5 text-[11px] hover:bg-canvas"
                      >
                        {p.name}
                      </button>
                    ))}
                </span>
              )}
              <button
                type="button"
                onClick={clearPlace}
                className="inline-flex cursor-pointer items-center gap-1 rounded-md px-1.5 text-[11px] text-sub hover:text-ink"
              >
                <X size={12} aria-hidden />
                {t('clearPlace')}
              </button>
            </>
          )}
        </div>
      )}
      <div className="flex items-start gap-5">
        <div className="flex min-w-0 flex-1 flex-col gap-3.5">
          <OpsMap
            focus={
              place?.location
                ? { id: 'place', at: place.location, kind: 'place', label: place.name }
                : undefined
            }
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
