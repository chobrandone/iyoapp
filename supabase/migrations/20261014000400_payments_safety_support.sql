-- iyodriver · 04 · payments, payouts, saved places, notifications, safety, support

-- ---------------------------------------------------------------------------
-- Payments
-- ---------------------------------------------------------------------------

-- Cash needs no row. Mobile money stores the wallet number; card stores only provider tokens.
create table public.payment_methods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type public.payment_method_type not null check (type <> 'cash'),
  label text check (char_length(label) <= 60),
  phone text check (phone ~ '^\+237[0-9]{9}$'),
  card_brand text,
  card_last4 text check (card_last4 ~ '^[0-9]{4}$'),
  provider_token text, -- never selectable by clients (column grant revoked below)
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  check ((type in ('mtn_momo', 'orange_money') and phone is not null) or (type = 'card' and card_last4 is not null))
);
create index payment_methods_user_idx on public.payment_methods (user_id);
create unique index payment_methods_one_default on public.payment_methods (user_id) where is_default;

alter table public.rides
  add constraint rides_payment_method_fk
  foreign key (payment_method_id) references public.payment_methods (id) on delete set null;

-- Status only changes through the payment-webhook Edge Function (service role).
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  payer_id uuid not null references public.profiles (id),
  ride_id uuid references public.rides (id),
  rental_booking_id uuid, -- FK added in the rentals migration
  purpose public.payment_purpose not null,
  method public.payment_method_type not null,
  amount integer not null check (amount >= 0),
  currency text not null default 'XAF',
  status public.payment_status not null default 'pending',
  provider text not null default 'mock',
  provider_reference text,
  failure_reason text,
  confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ride_id is not null or rental_booking_id is not null),
  unique (provider, provider_reference)
);
create index payments_payer_idx on public.payments (payer_id, created_at desc);
create index payments_ride_idx on public.payments (ride_id);
create trigger payments_updated_at before update on public.payments
  for each row execute function public.set_updated_at();

create table public.driver_payouts (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.driver_profiles (user_id),
  amount integer not null check (amount > 0),
  currency text not null default 'XAF',
  method public.payment_method_type not null check (method in ('mtn_momo', 'orange_money')),
  phone text not null check (phone ~ '^\+237[0-9]{9}$'),
  period_start date,
  period_end date,
  status public.payout_status not null default 'pending',
  provider text not null default 'mock',
  provider_reference text,
  failure_reason text,
  requested_at timestamptz not null default now(),
  paid_at timestamptz,
  updated_at timestamptz not null default now()
);
create index driver_payouts_driver_idx on public.driver_payouts (driver_id, requested_at desc);
create trigger driver_payouts_updated_at before update on public.driver_payouts
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Rider personal data
-- ---------------------------------------------------------------------------

create table public.saved_places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null default 'other' check (kind in ('home', 'work', 'other')),
  label text not null check (char_length(label) between 1 and 60),
  address text not null,
  place_id text,
  location extensions.geography(Point, 4326) not null,
  lat double precision generated always as (extensions.st_y(location::extensions.geometry)) stored,
  lng double precision generated always as (extensions.st_x(location::extensions.geometry)) stored,
  created_at timestamptz not null default now()
);
create index saved_places_user_idx on public.saved_places (user_id);
create unique index saved_places_one_home_work on public.saved_places (user_id, kind) where kind in ('home', 'work');

create table public.trusted_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  phone text not null check (phone ~ '^\+237[0-9]{9}$'),
  notify_on_alert boolean not null default true,
  created_at timestamptz not null default now(),
  unique (user_id, phone)
);
create index trusted_contacts_user_idx on public.trusted_contacts (user_id);

-- Max 5 trusted contacts (app_config.trusted_contacts_max).
create or replace function public.enforce_trusted_contacts_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_max integer := coalesce((select (value)::integer from public.app_config where key = 'trusted_contacts_max'), 5);
begin
  if (select count(*) from public.trusted_contacts where user_id = new.user_id) >= v_max then
    raise exception 'trusted_contacts_limit_reached' using errcode = 'P0001';
  end if;
  return new;
end;
$$;
create trigger trusted_contacts_limit before insert on public.trusted_contacts
  for each row execute function public.enforce_trusted_contacts_limit();

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null, -- e.g. driver_assigned, ride_request, payout_sent
  title text not null,
  body text not null,
  data jsonb not null default '{}',
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Safety. Snapshots (parties, vehicle, location) are copied at creation so the record
-- stays complete even if the ride or vehicle changes later.
-- ---------------------------------------------------------------------------

create table public.safety_alerts (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid references public.rides (id),
  raised_by uuid not null references public.profiles (id),
  rider_id uuid references public.profiles (id),
  driver_id uuid references public.profiles (id),
  vehicle_id uuid references public.vehicles (id),
  location extensions.geography(Point, 4326),
  reason text,
  note text check (char_length(note) <= 1000),
  snapshot jsonb not null default '{}',
  status public.alert_status not null default 'open',
  contacts_notified_at timestamptz,
  acknowledged_at timestamptz,
  acknowledged_by uuid references auth.users (id) on delete set null,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);
create index safety_alerts_status_idx on public.safety_alerts (status, created_at desc);

create table public.incident_reports (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid references public.rides (id),
  rental_booking_id uuid, -- FK added in the rentals migration
  reported_by uuid not null references public.profiles (id),
  rider_id uuid references public.profiles (id),
  driver_id uuid references public.profiles (id),
  vehicle_id uuid references public.vehicles (id),
  location extensions.geography(Point, 4326),
  category text not null,
  description text check (char_length(description) <= 2000),
  is_urgent boolean not null default false,
  snapshot jsonb not null default '{}',
  status public.alert_status not null default 'open',
  acknowledged_at timestamptz,
  acknowledged_by uuid references auth.users (id) on delete set null,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);
create index incident_reports_status_idx on public.incident_reports (status, created_at desc);

-- ---------------------------------------------------------------------------
-- Support
-- ---------------------------------------------------------------------------

create table public.support_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  ride_id uuid references public.rides (id) on delete set null,
  rental_booking_id uuid, -- FK added in the rentals migration
  subject text not null check (char_length(subject) between 1 and 120),
  status public.support_status not null default 'open',
  assigned_to uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index support_conversations_user_idx on public.support_conversations (user_id, created_at desc);
create trigger support_conversations_updated_at before update on public.support_conversations
  for each row execute function public.set_updated_at();

create table public.support_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.support_conversations (id) on delete cascade,
  sender_id uuid references auth.users (id) on delete set null,
  is_staff boolean not null default false,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index support_messages_conversation_idx on public.support_messages (conversation_id, created_at);

-- ---------------------------------------------------------------------------
-- Server-only helpers for Edge Functions (no client access)
-- ---------------------------------------------------------------------------

create table public.api_rate_limits (
  user_id uuid not null references auth.users (id) on delete cascade,
  bucket text not null,
  window_start timestamptz not null,
  request_count integer not null default 0,
  primary key (user_id, bucket, window_start)
);

create table public.route_cache (
  cache_key text primary key,
  response jsonb not null,
  expires_at timestamptz not null
);
