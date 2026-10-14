-- iyodriver · 01 · extensions, enum types and shared helpers
--
-- Conventions used by every migration:
--   * Money is stored as integer FCFA (XAF has no minor unit).
--   * Geography columns are geography(Point, 4326) (lng/lat, metres for distance).
--   * Every table has RLS enabled; clients write through RPCs unless a policy says otherwise.
--   * SECURITY DEFINER functions pin search_path and check the caller's role themselves.

create extension if not exists postgis with schema extensions;
create extension if not exists btree_gist with schema extensions;
create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------------
-- Enums (keep in sync with @iyodriver/core; ride_status is checked by npm run db:check)
-- ---------------------------------------------------------------------------

create type public.app_role as enum ('rider', 'driver', 'admin');
create type public.app_language as enum ('en', 'fr');

create type public.ride_status as enum (
  'requested',
  'searching',
  'driver_assigned',
  'driver_arriving',
  'driver_arrived',
  'in_progress',
  'completed',
  'cancelled_by_rider',
  'cancelled_by_driver',
  'no_drivers_found'
);
create type public.ride_actor as enum ('rider', 'driver', 'server', 'admin');

create type public.verification_status as enum (
  'pending',       -- account created, application not submitted yet
  'under_review',  -- documents submitted, waiting for the iyodriver team
  'action_needed', -- a document was rejected, driver must re-upload
  'approved',
  'rejected',
  'suspended'
);
create type public.document_type as enum (
  'national_id_front',
  'national_id_back',
  'driving_licence',
  'vehicle_registration', -- carte grise
  'insurance',
  'roadworthiness',       -- visite technique
  'profile_photo'
);
create type public.review_status as enum ('pending', 'approved', 'rejected');
create type public.vehicle_status as enum ('pending', 'approved', 'rejected', 'inactive');

create type public.offer_status as enum ('pending', 'accepted', 'declined', 'expired', 'cancelled');

create type public.payment_method_type as enum ('mtn_momo', 'orange_money', 'cash', 'card');
create type public.payment_status as enum (
  'pending', 'processing', 'succeeded', 'failed', 'cancelled', 'refunded'
);
create type public.payment_purpose as enum ('ride_fare', 'rental', 'rental_deposit', 'deposit_release');
create type public.payout_status as enum ('pending', 'processing', 'paid', 'failed');

create type public.transmission_type as enum ('automatic', 'manual');
create type public.fuel_type as enum ('petrol', 'diesel', 'hybrid', 'electric');
create type public.rental_vehicle_status as enum ('available', 'maintenance', 'retired');
create type public.rental_booking_status as enum (
  'pending_payment',
  'confirmed',
  'driver_assigned',
  'active',
  'return_pending',
  'completed',
  'cancelled'
);
create type public.rental_pickup_type as enum ('address', 'airport');
create type public.deposit_status as enum ('not_collected', 'held', 'released', 'partially_held');
create type public.inspection_type as enum ('handover', 'return');

create type public.alert_status as enum ('open', 'acknowledged', 'resolved');
create type public.support_status as enum ('open', 'waiting_on_user', 'closed');

-- ---------------------------------------------------------------------------
-- Generic helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

/** Build a geography point from latitude/longitude (argument order matches how apps think). */
create or replace function public.make_point(p_lat double precision, p_lng double precision)
returns extensions.geography
language sql
immutable
set search_path = ''
as $$
  select extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography;
$$;

/** Round a FCFA amount to the nearest 50 (fare rule 9.4). */
create or replace function public.round_fcfa(p_amount numeric)
returns integer
language sql
immutable
set search_path = ''
as $$
  select (round(p_amount / 50.0) * 50)::integer;
$$;
