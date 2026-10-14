-- iyodriver · 02 · cities, remote config, profiles, drivers, vehicles, driver locations

-- ---------------------------------------------------------------------------
-- Cities and ride categories (data-driven so moto-taxi / Eco can be added later)
-- ---------------------------------------------------------------------------

create table public.cities (
  code text primary key check (code ~ '^[a-z_]+$'),
  name text not null,
  country_code text not null default 'CM',
  timezone text not null default 'Africa/Douala',
  center extensions.geography(Point, 4326) not null,
  center_lat double precision generated always as (extensions.st_y(center::extensions.geometry)) stored,
  center_lng double precision generated always as (extensions.st_x(center::extensions.geometry)) stored,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.ride_categories (
  code text primary key check (code ~ '^[a-z_]+$'),
  name_en text not null,
  name_fr text not null,
  description_en text,
  description_fr text,
  seats smallint not null check (seats between 1 and 20),
  sort_order smallint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Remote configuration (read-only for both apps)
-- ---------------------------------------------------------------------------

create table public.app_config (
  key text primary key,
  value jsonb not null,
  description text,
  is_placeholder boolean not null default false, -- true = business value still to be set by the owner
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null
);
create trigger app_config_updated_at before update on public.app_config
  for each row execute function public.set_updated_at();

create table public.fare_config (
  id uuid primary key default gen_random_uuid(),
  city_code text not null references public.cities (code),
  category_code text not null references public.ride_categories (code),
  base_fare integer not null check (base_fare >= 0),
  per_km integer not null check (per_km >= 0),
  per_min integer not null check (per_min >= 0),
  minimum_fare integer not null check (minimum_fare >= 0),
  category_multiplier numeric(4, 2) not null default 1.00 check (category_multiplier > 0),
  commission_rate numeric(4, 3) not null check (commission_rate >= 0 and commission_rate < 1),
  currency text not null default 'XAF' check (currency = 'XAF'),
  is_placeholder boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null,
  unique (city_code, category_code)
);
create trigger fare_config_updated_at before update on public.fare_config
  for each row execute function public.set_updated_at();

create table public.airports (
  code text primary key check (code ~ '^[A-Z]{3}$'), -- IATA
  name text not null,
  city_code text not null references public.cities (code),
  location extensions.geography(Point, 4326) not null,
  lat double precision generated always as (extensions.st_y(location::extensions.geometry)) stored,
  lng double precision generated always as (extensions.st_x(location::extensions.geometry)) stored,
  terminals text[] not null default '{}',
  pickup_fee integer not null default 0 check (pickup_fee >= 0),
  is_placeholder boolean not null default true,
  is_active boolean not null default true
);

-- ---------------------------------------------------------------------------
-- Profiles (one per auth user). Role is fixed at sign-up by the app that created it.
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.app_role not null,
  full_name text not null default '' check (char_length(full_name) <= 120),
  phone text unique check (phone ~ '^\+237[0-9]{9}$'),
  avatar_url text,
  language public.app_language not null default 'fr',
  rating numeric(2, 1) check (rating between 1 and 5), -- average of the last 100 ratings received
  rating_count integer not null default 0,
  is_blocked boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index profiles_role_idx on public.profiles (role);
create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

create table public.driver_profiles (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  verification_status public.verification_status not null default 'pending',
  city_code text references public.cities (code),
  licence_number text check (char_length(licence_number) <= 40),
  licence_expiry date,
  national_id_number text check (char_length(national_id_number) <= 40),
  payout_method public.payment_method_type check (payout_method in ('mtn_momo', 'orange_money')),
  payout_phone text check (payout_phone ~ '^\+237[0-9]{9}$'),
  submitted_at timestamptz,
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users (id) on delete set null,
  approved_at timestamptz,
  review_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index driver_profiles_status_idx on public.driver_profiles (verification_status);
create trigger driver_profiles_updated_at before update on public.driver_profiles
  for each row execute function public.set_updated_at();

create table public.driver_documents (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.driver_profiles (user_id) on delete cascade,
  type public.document_type not null,
  storage_path text not null, -- driver-documents bucket, "<driver_id>/<file>"
  mime_type text,
  status public.review_status not null default 'pending',
  rejection_reason text,
  expires_on date,
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (driver_id, type)
);
create trigger driver_documents_updated_at before update on public.driver_documents
  for each row execute function public.set_updated_at();

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.driver_profiles (user_id) on delete cascade,
  category_code text not null references public.ride_categories (code),
  make text not null,
  model text not null,
  year smallint check (year between 1990 and 2100),
  color text not null,
  plate text not null unique check (plate ~ '^[A-Z]{2} ?[0-9]{3,4} ?[A-Z]{1,2}$'), -- e.g. LT 123 AB
  seats smallint not null default 4 check (seats between 1 and 20),
  status public.vehicle_status not null default 'pending',
  is_active boolean not null default false, -- the vehicle the driver is currently driving
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index vehicles_driver_idx on public.vehicles (driver_id);
create unique index vehicles_one_active_per_driver on public.vehicles (driver_id) where is_active;
create trigger vehicles_updated_at before update on public.vehicles
  for each row execute function public.set_updated_at();

-- One row per driver, updated in place every few seconds while online.
create table public.driver_locations (
  driver_id uuid primary key references public.driver_profiles (user_id) on delete cascade,
  location extensions.geography(Point, 4326) not null,
  lat double precision generated always as (extensions.st_y(location::extensions.geometry)) stored,
  lng double precision generated always as (extensions.st_x(location::extensions.geometry)) stored,
  heading real check (heading >= 0 and heading < 360),
  speed_mps real check (speed_mps >= 0),
  accuracy_m real check (accuracy_m >= 0),
  is_online boolean not null default false,
  vehicle_id uuid references public.vehicles (id) on delete set null,
  went_online_at timestamptz,
  updated_at timestamptz not null default now()
);
create index driver_locations_location_gix on public.driver_locations using gist (location);
create index driver_locations_online_idx on public.driver_locations (is_online) where is_online;

-- Expo push tokens, one row per device and app.
create table public.push_tokens (
  token text primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  app public.app_role not null check (app in ('rider', 'driver')),
  platform text not null check (platform in ('ios', 'android')),
  updated_at timestamptz not null default now()
);
create index push_tokens_user_idx on public.push_tokens (user_id);

-- ---------------------------------------------------------------------------
-- Role helpers used by RLS and RPCs
-- ---------------------------------------------------------------------------

create or replace function public.current_app_role()
returns public.app_role
language sql
stable
security definer
set search_path = ''
as $$
  select p.role from public.profiles p where p.id = (select auth.uid());
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select p.role = 'admin' from public.profiles p where p.id = (select auth.uid())), false);
$$;

create or replace function public.is_approved_driver(p_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    join public.driver_profiles d on d.user_id = p.id
    where p.id = p_user_id and p.role = 'driver' and not p.is_blocked
      and d.verification_status = 'approved'
  );
$$;

/** Raise unless the caller is signed in with the expected role. Used at the top of every RPC. */
create or replace function public.require_role(p_role public.app_role)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_role public.app_role;
  v_blocked boolean;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  select role, is_blocked into v_role, v_blocked from public.profiles where id = v_uid;
  if v_role is distinct from p_role then
    raise exception 'wrong_role: % required', p_role using errcode = '42501';
  end if;
  if v_blocked then
    raise exception 'account_blocked' using errcode = '42501';
  end if;
  return v_uid;
end;
$$;

-- ---------------------------------------------------------------------------
-- New auth user -> profile. The app passes its role in user metadata on sign-up
-- (options.data.app_role = 'rider' | 'driver'). Admins are only created by hand.
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role public.app_role;
  v_lang public.app_language;
  v_phone text;
begin
  v_role := case new.raw_user_meta_data ->> 'app_role'
    when 'driver' then 'driver'::public.app_role
    else 'rider'::public.app_role
  end;
  v_lang := case new.raw_user_meta_data ->> 'language'
    when 'en' then 'en'::public.app_language
    else 'fr'::public.app_language
  end;
  -- GoTrue stores phones without the leading "+".
  v_phone := case
    when new.phone is null or new.phone = '' then null
    when left(new.phone, 1) = '+' then new.phone
    else '+' || new.phone
  end;

  insert into public.profiles (id, role, full_name, phone, language)
  values (
    new.id,
    v_role,
    coalesce(left(trim(new.raw_user_meta_data ->> 'full_name'), 120), ''),
    v_phone,
    v_lang
  );

  if v_role = 'driver' then
    insert into public.driver_profiles (user_id) values (new.id);
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

-- Keep profiles.phone in sync when the user changes number.
create or replace function public.handle_auth_user_phone_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles
  set phone = case
    when new.phone is null or new.phone = '' then null
    when left(new.phone, 1) = '+' then new.phone
    else '+' || new.phone
  end
  where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_phone_changed
  after update of phone on auth.users
  for each row when (old.phone is distinct from new.phone)
  execute function public.handle_auth_user_phone_change();
