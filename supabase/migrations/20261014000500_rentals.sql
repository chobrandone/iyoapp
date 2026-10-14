-- iyodriver · 05 · rental fleet, bookings (no overlaps), handover / return inspections

create table public.rental_vehicles (
  id uuid primary key default gen_random_uuid(),
  city_code text not null references public.cities (code),
  make text not null,
  model text not null,
  year smallint check (year between 1990 and 2100),
  category text not null, -- display grouping: economy, sedan, suv, van...
  transmission public.transmission_type not null,
  seats smallint not null check (seats between 1 and 20),
  fuel_type public.fuel_type not null,
  plate text not null unique check (plate ~ '^[A-Z]{2} ?[0-9]{3,4} ?[A-Z]{1,2}$'),
  color text,
  daily_rate integer not null check (daily_rate > 0),
  deposit_amount integer not null check (deposit_amount >= 0),
  km_per_day integer not null check (km_per_day > 0),
  extra_km_rate integer not null default 0 check (extra_km_rate >= 0),
  image_paths text[] not null default '{}', -- rental-vehicle-images bucket
  features text[] not null default '{}',
  airport_pickup_available boolean not null default false,
  status public.rental_vehicle_status not null default 'available',
  is_placeholder_pricing boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index rental_vehicles_city_idx on public.rental_vehicles (city_code, status);
create trigger rental_vehicles_updated_at before update on public.rental_vehicles
  for each row execute function public.set_updated_at();

create table public.rental_bookings (
  id uuid primary key default gen_random_uuid(),
  reference text not null unique default upper(encode(extensions.gen_random_bytes(4), 'hex')),
  rider_id uuid not null references public.profiles (id),
  vehicle_id uuid not null references public.rental_vehicles (id),
  assigned_driver_id uuid references public.driver_profiles (user_id),
  status public.rental_booking_status not null default 'pending_payment',

  starts_at timestamptz not null,
  ends_at timestamptz not null,
  period tstzrange generated always as (tstzrange(starts_at, ends_at, '[)')) stored,

  pickup_type public.rental_pickup_type not null,
  pickup_address text,
  pickup_location extensions.geography(Point, 4326),
  pickup_lat double precision generated always as (extensions.st_y(pickup_location::extensions.geometry)) stored,
  pickup_lng double precision generated always as (extensions.st_x(pickup_location::extensions.geometry)) stored,
  airport_code text references public.airports (code),
  terminal text,
  flight_number text check (flight_number ~ '^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$'), -- e.g. AF900, QC1234
  flight_arrival_at timestamptz,
  grace_minutes integer,
  return_address text,

  days integer not null check (days > 0),
  daily_rate integer not null,
  rental_amount integer not null,
  airport_fee integer not null default 0,
  deposit_amount integer not null,
  total_amount integer not null, -- charged now (rental + airport fee); deposit is held separately
  km_allowance integer not null,
  deposit_status public.deposit_status not null default 'not_collected',
  deposit_held_amount integer not null default 0,

  payment_method public.payment_method_type not null,
  payment_method_id uuid references public.payment_methods (id) on delete set null,
  cancelled_at timestamptz,
  cancel_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  check (ends_at > starts_at),
  check (
    pickup_type = 'address' and pickup_address is not null
    or pickup_type = 'airport' and airport_code is not null and flight_number is not null and flight_arrival_at is not null
  ),
  -- No two live bookings of the same car may overlap.
  constraint rental_bookings_no_overlap exclude using gist (
    vehicle_id with =,
    period with &&
  ) where (status <> 'cancelled')
);
create index rental_bookings_rider_idx on public.rental_bookings (rider_id, starts_at desc);
create index rental_bookings_driver_idx on public.rental_bookings (assigned_driver_id, starts_at);
create trigger rental_bookings_updated_at before update on public.rental_bookings
  for each row execute function public.set_updated_at();

create table public.rental_inspections (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.rental_bookings (id) on delete cascade,
  type public.inspection_type not null,
  inspector_id uuid not null references public.profiles (id),
  fuel_level smallint not null check (fuel_level between 0 and 8), -- eighths of a tank
  odometer_km integer not null check (odometer_km >= 0),
  -- inspection-photos bucket paths: {"front": "...", "back": "...", "left": "...", "right": "...", "interior": "..."}
  photo_paths jsonb not null default '{}',
  damage_notes text check (char_length(damage_notes) <= 2000),
  checklist jsonb not null default '{}',
  deposit_hold_amount integer not null default 0 check (deposit_hold_amount >= 0),
  inspector_confirmed_at timestamptz,
  rider_confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (booking_id, type)
);
create trigger rental_inspections_updated_at before update on public.rental_inspections
  for each row execute function public.set_updated_at();

alter table public.payments
  add constraint payments_rental_booking_fk foreign key (rental_booking_id) references public.rental_bookings (id);
alter table public.incident_reports
  add constraint incident_reports_rental_booking_fk foreign key (rental_booking_id) references public.rental_bookings (id);
alter table public.support_conversations
  add constraint support_conversations_rental_booking_fk
  foreign key (rental_booking_id) references public.rental_bookings (id) on delete set null;
