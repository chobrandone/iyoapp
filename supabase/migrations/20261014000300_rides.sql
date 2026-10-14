-- iyodriver · 03 · fare quotes, rides, lifecycle events, offers, PIN, ratings, chat, trip sharing

-- Upfront prices computed by the estimate-fares Edge Function. A ride can only be created
-- from an unexpired quote, so the price never comes from the client.
create table public.fare_quotes (
  id uuid primary key default gen_random_uuid(),
  rider_id uuid not null references public.profiles (id) on delete cascade,
  city_code text not null references public.cities (code),
  category_code text not null references public.ride_categories (code),
  pickup_location extensions.geography(Point, 4326) not null,
  pickup_address text not null,
  pickup_place_id text,
  pickup_lat double precision generated always as (extensions.st_y(pickup_location::extensions.geometry)) stored,
  pickup_lng double precision generated always as (extensions.st_x(pickup_location::extensions.geometry)) stored,
  dropoff_location extensions.geography(Point, 4326) not null,
  dropoff_address text not null,
  dropoff_place_id text,
  dropoff_lat double precision generated always as (extensions.st_y(dropoff_location::extensions.geometry)) stored,
  dropoff_lng double precision generated always as (extensions.st_x(dropoff_location::extensions.geometry)) stored,
  distance_m integer not null check (distance_m >= 0),
  duration_s integer not null check (duration_s >= 0),
  route_polyline text,
  fare_amount integer not null check (fare_amount >= 0),
  commission_rate numeric(4, 3) not null,
  breakdown jsonb not null default '{}',
  expires_at timestamptz not null default now() + interval '10 minutes',
  used_at timestamptz,
  created_at timestamptz not null default now()
);
create index fare_quotes_rider_idx on public.fare_quotes (rider_id, created_at desc);

create table public.rides (
  id uuid primary key default gen_random_uuid(),
  rider_id uuid not null references public.profiles (id),
  driver_id uuid references public.driver_profiles (user_id),
  vehicle_id uuid references public.vehicles (id),
  quote_id uuid unique references public.fare_quotes (id),
  city_code text not null references public.cities (code),
  category_code text not null references public.ride_categories (code),
  status public.ride_status not null default 'requested',

  pickup_location extensions.geography(Point, 4326) not null,
  pickup_address text not null,
  pickup_place_id text,
  pickup_lat double precision generated always as (extensions.st_y(pickup_location::extensions.geometry)) stored,
  pickup_lng double precision generated always as (extensions.st_x(pickup_location::extensions.geometry)) stored,
  dropoff_location extensions.geography(Point, 4326) not null,
  dropoff_address text not null,
  dropoff_place_id text,
  dropoff_lat double precision generated always as (extensions.st_y(dropoff_location::extensions.geometry)) stored,
  dropoff_lng double precision generated always as (extensions.st_x(dropoff_location::extensions.geometry)) stored,
  route_polyline text,
  distance_m integer not null,
  duration_s integer not null,

  fare_amount integer not null check (fare_amount >= 0), -- upfront price, FCFA
  currency text not null default 'XAF',
  commission_rate numeric(4, 3) not null,
  driver_earnings integer generated always as
    (fare_amount - round(fare_amount * commission_rate)::integer) stored,
  payment_method public.payment_method_type not null,
  payment_method_id uuid, -- FK added in the payments migration

  search_radius_m integer,
  requested_at timestamptz not null default now(),
  assigned_at timestamptz,
  arriving_at timestamptz,
  arrived_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  ended_at timestamptz, -- set for every terminal status; chat closes 1 h after
  cancel_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index rides_status_idx on public.rides (status);
create index rides_rider_idx on public.rides (rider_id, created_at desc);
create index rides_driver_idx on public.rides (driver_id, created_at desc);
-- A rider has at most one open ride, a driver at most one assigned ride.
create unique index rides_one_open_per_rider on public.rides (rider_id)
  where status in ('requested', 'searching', 'driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress');
create unique index rides_one_active_per_driver on public.rides (driver_id)
  where status in ('driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress');
create trigger rides_updated_at before update on public.rides
  for each row execute function public.set_updated_at();

-- Audit log of every status change.
create table public.ride_events (
  id bigint generated always as identity primary key,
  ride_id uuid not null references public.rides (id) on delete cascade,
  from_status public.ride_status,
  to_status public.ride_status not null,
  actor public.ride_actor not null,
  actor_id uuid references auth.users (id) on delete set null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index ride_events_ride_idx on public.ride_events (ride_id, created_at);

-- Allowed transitions; mirrors RIDE_TRANSITIONS in @iyodriver/core (checked by npm run db:check).
create table public.ride_status_transitions (
  from_status public.ride_status not null,
  to_status public.ride_status not null,
  actor public.ride_actor not null,
  primary key (from_status, to_status, actor)
);
insert into public.ride_status_transitions (from_status, to_status, actor) values
  ('requested', 'searching', 'server'),
  ('requested', 'cancelled_by_rider', 'rider'),
  ('searching', 'driver_assigned', 'driver'),
  ('searching', 'no_drivers_found', 'server'),
  ('searching', 'cancelled_by_rider', 'rider'),
  ('driver_assigned', 'driver_arriving', 'driver'),
  ('driver_assigned', 'cancelled_by_rider', 'rider'),
  ('driver_assigned', 'cancelled_by_driver', 'driver'),
  ('driver_arriving', 'driver_arrived', 'driver'),
  ('driver_arriving', 'cancelled_by_rider', 'rider'),
  ('driver_arriving', 'cancelled_by_driver', 'driver'),
  ('driver_arrived', 'in_progress', 'driver'),
  ('driver_arrived', 'cancelled_by_rider', 'rider'),
  ('driver_arrived', 'cancelled_by_driver', 'driver'),
  ('in_progress', 'completed', 'driver');

-- Pickup PIN lives apart from rides so drivers (who can read their rides) never see it.
create table public.ride_pins (
  ride_id uuid primary key references public.rides (id) on delete cascade,
  pin text not null check (pin ~ '^[0-9]{4}$'),
  failed_attempts smallint not null default 0,
  locked_at timestamptz,
  verified_at timestamptz
);

-- One driver at a time, 15 s accept window.
create table public.ride_offers (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null references public.rides (id) on delete cascade,
  driver_id uuid not null references public.driver_profiles (user_id) on delete cascade,
  status public.offer_status not null default 'pending',
  search_radius_m integer not null,
  distance_m integer,          -- straight-line distance at offer time
  eta_seconds integer,         -- Routes API ETA to pickup, null if unavailable
  offered_at timestamptz not null default now(),
  expires_at timestamptz not null,
  responded_at timestamptz,
  unique (ride_id, driver_id)
);
create index ride_offers_driver_idx on public.ride_offers (driver_id, status);
create unique index ride_offers_one_pending_per_ride on public.ride_offers (ride_id) where status = 'pending';
create unique index ride_offers_one_pending_per_driver on public.ride_offers (driver_id) where status = 'pending';

create table public.ratings (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null references public.rides (id) on delete cascade,
  rater_id uuid not null references public.profiles (id) on delete cascade,
  ratee_id uuid not null references public.profiles (id) on delete cascade,
  rater_role public.app_role not null check (rater_role in ('rider', 'driver')),
  stars smallint not null check (stars between 1 and 5),
  tags text[] not null default '{}',
  comment text check (char_length(comment) <= 500),
  tip_amount integer not null default 0 check (tip_amount >= 0),
  created_at timestamptz not null default now(),
  unique (ride_id, rater_id)
);
create index ratings_ratee_idx on public.ratings (ratee_id, created_at desc);

-- Trip chat, scoped to one ride.
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null references public.rides (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index messages_ride_idx on public.messages (ride_id, created_at);

-- Tokenised, expiring public "share live trip" links.
create table public.trip_shares (
  token text primary key default encode(extensions.gen_random_bytes(18), 'hex'),
  ride_id uuid not null references public.rides (id) on delete cascade,
  created_by uuid not null references public.profiles (id) on delete cascade,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);
create index trip_shares_ride_idx on public.trip_shares (ride_id);
