-- iyodriver · 11 · rental handover PIN, optional protection, rider ↔ handover driver contact
-- (Figma "Rentals · Review and payment", "Driver · Rental handover checklist", "Rentals · Active rental").

-- ---------------------------------------------------------------------------
-- Optional protection, priced per day on the server (PLACEHOLDER amount).
-- ---------------------------------------------------------------------------

insert into public.app_config (key, value, description, is_placeholder) values
  ('rental_protection_daily', '3000', 'Optional rental protection, FCFA per day (placeholder).', true)
on conflict (key) do nothing;

alter table public.rental_bookings
  add column protection_amount integer not null default 0 check (protection_amount >= 0);

drop function public.create_rental_booking(
  uuid, timestamptz, timestamptz, public.rental_pickup_type, public.payment_method_type, uuid,
  text, double precision, double precision, text, text, text, timestamptz, text
);

create or replace function public.create_rental_booking(
  p_vehicle_id uuid,
  p_starts_at timestamptz,
  p_ends_at timestamptz,
  p_pickup_type public.rental_pickup_type,
  p_payment_method public.payment_method_type,
  p_payment_method_id uuid default null,
  p_pickup_address text default null,
  p_pickup_lat double precision default null,
  p_pickup_lng double precision default null,
  p_airport_code text default null,
  p_terminal text default null,
  p_flight_number text default null,
  p_flight_arrival_at timestamptz default null,
  p_return_address text default null,
  p_protection boolean default false
)
returns public.rental_bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('rider');
  v public.rental_vehicles;
  a public.airports;
  v_days integer;
  v_grace integer := coalesce((select (value)::integer from public.app_config where key = 'airport_grace_minutes'), 60);
  v_protection integer := 0;
  v_row public.rental_bookings;
begin
  if p_starts_at < now() or p_ends_at <= p_starts_at then
    raise exception 'invalid_rental_period' using errcode = '22023';
  end if;
  select * into v from public.rental_vehicles where id = p_vehicle_id and status = 'available';
  if not found then
    raise exception 'vehicle_not_found' using errcode = 'P0002';
  end if;
  if p_payment_method <> 'cash' and (p_payment_method_id is null or not exists (
    select 1 from public.payment_methods m
    where m.id = p_payment_method_id and m.user_id = v_uid and m.type = p_payment_method
  )) then
    raise exception 'invalid_payment_method' using errcode = 'P0001';
  end if;

  if p_pickup_type = 'airport' then
    if not v.airport_pickup_available then
      raise exception 'airport_pickup_unavailable' using errcode = 'P0001';
    end if;
    select * into a from public.airports where code = p_airport_code and is_active;
    if not found then
      raise exception 'airport_not_found' using errcode = 'P0002';
    end if;
    p_flight_number := upper(replace(p_flight_number, ' ', ''));
  end if;

  v_days := ceil(extract(epoch from (p_ends_at - p_starts_at)) / 86400.0)::integer;
  if coalesce(p_protection, false) then
    v_protection := v_days * coalesce(
      (select (value)::integer from public.app_config where key = 'rental_protection_daily'), 0
    );
  end if;

  begin
    insert into public.rental_bookings (
      rider_id, vehicle_id, starts_at, ends_at, pickup_type,
      pickup_address, pickup_location, airport_code, terminal, flight_number, flight_arrival_at, grace_minutes,
      return_address, days, daily_rate, rental_amount, airport_fee, protection_amount, deposit_amount,
      total_amount, km_allowance, payment_method, payment_method_id
    ) values (
      v_uid, v.id, p_starts_at, p_ends_at, p_pickup_type,
      case when p_pickup_type = 'airport' then a.name else p_pickup_address end,
      case
        when p_pickup_type = 'airport' then a.location
        when p_pickup_lat is not null and p_pickup_lng is not null then public.make_point(p_pickup_lat, p_pickup_lng)
      end,
      a.code, p_terminal, p_flight_number, p_flight_arrival_at,
      case when p_pickup_type = 'airport' then v_grace end,
      p_return_address, v_days, v.daily_rate, v.daily_rate * v_days,
      coalesce(a.pickup_fee, 0), v_protection, v.deposit_amount,
      v.daily_rate * v_days + coalesce(a.pickup_fee, 0) + v_protection,
      v.km_per_day * v_days,
      p_payment_method, case when p_payment_method = 'cash' then null else p_payment_method_id end
    )
    returning * into v_row;
  exception when exclusion_violation then
    raise exception 'vehicle_unavailable_for_dates' using errcode = 'P0001';
  end;
  return v_row;
end;
$$;

revoke execute on function public.create_rental_booking(
  uuid, timestamptz, timestamptz, public.rental_pickup_type, public.payment_method_type, uuid,
  text, double precision, double precision, text, text, text, timestamptz, text, boolean
) from public, anon;
grant execute on function public.create_rental_booking(
  uuid, timestamptz, timestamptz, public.rental_pickup_type, public.payment_method_type, uuid,
  text, double precision, double precision, text, text, text, timestamptz, text, boolean
) to authenticated;

-- ---------------------------------------------------------------------------
-- Handover PIN: the rider reads it in the app and tells the driver at the car (same model as the
-- ride pickup PIN: kept apart from rental_bookings so the assigned driver never reads it).
-- ---------------------------------------------------------------------------

create table public.rental_handover_pins (
  booking_id uuid primary key references public.rental_bookings (id) on delete cascade,
  pin text not null check (pin ~ '^[0-9]{4}$'),
  failed_attempts smallint not null default 0,
  locked_at timestamptz,
  verified_at timestamptz
);
alter table public.rental_handover_pins enable row level security;

create policy "riders read own handover pin" on public.rental_handover_pins
  for select to authenticated using (
    exists (
      select 1 from public.rental_bookings b
      where b.id = booking_id and b.rider_id = (select auth.uid())
    )
  );
grant select on public.rental_handover_pins to authenticated;

create or replace function public.on_rental_booking_pin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.rental_handover_pins (booking_id, pin)
  values (new.id, lpad((floor(random() * 10000))::integer::text, 4, '0'));
  return new;
end;
$$;

create trigger rental_booking_pin
  after insert on public.rental_bookings
  for each row execute function public.on_rental_booking_pin();

-- Bookings made before this migration get a PIN too.
insert into public.rental_handover_pins (booking_id, pin)
select id, lpad((floor(random() * 10000))::integer::text, 4, '0') from public.rental_bookings
on conflict do nothing;

/** Driver: the rider's PIN at the car confirms the handover (instead of the rider tapping confirm). */
create or replace function public.confirm_rental_handover_pin(p_booking_id uuid, p_pin text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  b public.rental_bookings;
  v_pin public.rental_handover_pins;
  v_max integer := coalesce((select (value)::integer from public.app_config where key = 'pin_max_attempts'), 5);
begin
  select * into b from public.rental_bookings
  where id = p_booking_id and assigned_driver_id = v_uid for update;
  if not found then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;
  if b.status <> 'driver_assigned' then
    raise exception 'handover_not_allowed' using errcode = 'P0001';
  end if;
  if not exists (
    select 1 from public.rental_inspections
    where booking_id = p_booking_id and type = 'handover' and inspector_confirmed_at is not null
  ) then
    raise exception 'inspection_not_ready' using errcode = 'P0001';
  end if;

  select * into v_pin from public.rental_handover_pins where booking_id = p_booking_id for update;
  if v_pin.locked_at is not null then
    return jsonb_build_object('ok', false, 'locked', true, 'attempts_left', 0);
  end if;

  if p_pin is not null and p_pin = v_pin.pin then
    update public.rental_handover_pins set verified_at = now() where booking_id = p_booking_id;
    update public.rental_inspections set rider_confirmed_at = now()
    where booking_id = p_booking_id and type = 'handover';
    update public.rental_bookings set status = 'active', deposit_status = 'held' where id = p_booking_id;
    return jsonb_build_object('ok', true, 'locked', false, 'attempts_left', v_max - v_pin.failed_attempts);
  end if;

  update public.rental_handover_pins set
    failed_attempts = failed_attempts + 1,
    locked_at = case when failed_attempts + 1 >= v_max then now() else null end
  where booking_id = p_booking_id
  returning * into v_pin;

  if v_pin.locked_at is not null then
    insert into public.incident_reports (rental_booking_id, reported_by, rider_id, driver_id, category, description, snapshot)
    values (
      p_booking_id, v_uid, b.rider_id, v_uid, 'handover_pin_locked',
      'Handover PIN locked after ' || v_max || ' wrong attempts.',
      jsonb_build_object('pickup_address', b.pickup_address)
    );
  end if;

  return jsonb_build_object(
    'ok', false,
    'locked', v_pin.locked_at is not null,
    'attempts_left', greatest(v_max - v_pin.failed_attempts, 0)
  );
end;
$$;

/** Rider: the driver handing the car over (name, phone, rating), once one is assigned. */
create or replace function public.get_rental_driver(p_booking_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  b public.rental_bookings;
  p public.profiles;
begin
  select * into b from public.rental_bookings where id = p_booking_id and rider_id = (select auth.uid());
  if not found then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;
  if b.assigned_driver_id is null then
    return null;
  end if;
  select * into p from public.profiles where id = b.assigned_driver_id;
  return jsonb_build_object(
    'id', p.id, 'name', p.full_name, 'phone', p.phone, 'rating', p.rating, 'rating_count', p.rating_count
  );
end;
$$;

revoke execute on function
  public.on_rental_booking_pin(),
  public.confirm_rental_handover_pin(uuid, text),
  public.get_rental_driver(uuid)
from public, anon;
grant execute on function
  public.confirm_rental_handover_pin(uuid, text),
  public.get_rental_driver(uuid)
to authenticated;

-- ---------------------------------------------------------------------------
-- Driver setup (Figma "Driver · Identity and vehicle setup"): date of birth for verification.
-- ---------------------------------------------------------------------------

alter table public.driver_profiles
  add column date_of_birth date check (date_of_birth <= current_date - interval '18 years');
grant update (date_of_birth) on public.driver_profiles to authenticated;
