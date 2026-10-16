-- iyodriver · 12 · operations dashboard (Figma "Admin · …" frames): human references, safety case
-- handling, refunds, fleet locations, and admin-only RPCs. Admins already read every table
-- ("admins read all" policies); every admin write goes through a function below.

-- ---------------------------------------------------------------------------
-- References people quote on the phone: RD-1042, DR-018, SA-091, TX-8801, PO-071, RN-2048, RF-0214.
-- ---------------------------------------------------------------------------

create sequence public.ride_ref_seq start 1001;
create sequence public.driver_ref_seq start 1;
create sequence public.safety_ref_seq start 1;
create sequence public.payment_ref_seq start 8001;
create sequence public.payout_ref_seq start 1;
create sequence public.rental_ref_seq start 2001;
create sequence public.refund_ref_seq start 201;

alter table public.rides
  add column reference text not null unique default ('RD-' || nextval('public.ride_ref_seq'));
alter table public.driver_profiles
  add column reference text not null unique
    default ('DR-' || lpad(nextval('public.driver_ref_seq')::text, 3, '0'));
alter table public.safety_alerts
  add column reference text not null unique
    default ('SA-' || lpad(nextval('public.safety_ref_seq')::text, 3, '0'));
alter table public.incident_reports
  add column reference text not null unique
    default ('SA-' || lpad(nextval('public.safety_ref_seq')::text, 3, '0'));
alter table public.payments
  add column reference text not null unique default ('TX-' || nextval('public.payment_ref_seq'));
alter table public.driver_payouts
  add column reference text not null unique
    default ('PO-' || lpad(nextval('public.payout_ref_seq')::text, 3, '0'));
alter table public.rental_bookings
  alter column reference set default ('RN-' || nextval('public.rental_ref_seq'));

-- ---------------------------------------------------------------------------
-- Safety cases: assignee, resolution note and a history of what the team did.
-- ---------------------------------------------------------------------------

alter table public.safety_alerts
  add column assigned_to uuid references public.profiles (id) on delete set null,
  add column resolution_note text check (char_length(resolution_note) <= 2000);
alter table public.incident_reports
  add column assigned_to uuid references public.profiles (id) on delete set null,
  add column resolution_note text check (char_length(resolution_note) <= 2000);

create table public.safety_case_events (
  id uuid primary key default gen_random_uuid(),
  alert_id uuid references public.safety_alerts (id) on delete cascade,
  incident_id uuid references public.incident_reports (id) on delete cascade,
  actor_id uuid references public.profiles (id) on delete set null,
  kind text not null check (kind in ('assigned', 'status', 'note')),
  status public.alert_status,
  note text check (char_length(note) <= 2000),
  created_at timestamptz not null default now(),
  check ((alert_id is null) <> (incident_id is null))
);
create index safety_case_events_alert_idx on public.safety_case_events (alert_id, created_at);
create index safety_case_events_incident_idx on public.safety_case_events (incident_id, created_at);
alter table public.safety_case_events enable row level security;
create policy "admins read safety case events" on public.safety_case_events
  for select to authenticated using ((select public.is_admin()));
grant select on public.safety_case_events to authenticated;

/** high / medium / low, as the safety queue sorts them. */
create or replace function public.safety_severity(p_kind text, p_category text, p_urgent boolean)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p_kind = 'alert' then 'high'
    when p_urgent or p_category in ('accident', 'theft_or_aggression', 'pickup_pin_locked', 'handover_pin_locked') then 'high'
    when p_category in ('lost_item', 'payment') then 'low'
    else 'medium'
  end;
$$;

-- ---------------------------------------------------------------------------
-- Refunds: requested by an admin, executed by the payment provider later.
-- ---------------------------------------------------------------------------

create table public.refunds (
  id uuid primary key default gen_random_uuid(),
  reference text not null unique default ('RF-' || lpad(nextval('public.refund_ref_seq')::text, 4, '0')),
  payment_id uuid not null references public.payments (id),
  amount integer not null check (amount > 0),
  reason text not null check (char_length(reason) between 3 and 500),
  status text not null default 'requested' check (status in ('requested', 'processing', 'refunded', 'rejected')),
  requested_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index refunds_payment_idx on public.refunds (payment_id);
create trigger refunds_updated_at before update on public.refunds
  for each row execute function public.set_updated_at();
alter table public.refunds enable row level security;
create policy "admins read refunds" on public.refunds
  for select to authenticated using ((select public.is_admin()));
create policy "payers read own refunds" on public.refunds
  for select to authenticated using (
    exists (select 1 from public.payments p where p.id = payment_id and p.payer_id = (select auth.uid()))
  );
grant select on public.refunds to authenticated;

-- ---------------------------------------------------------------------------
-- Fleet: where each rental car lives between bookings (hub, depot, workshop).
-- ---------------------------------------------------------------------------

alter table public.rental_vehicles
  add column home_location text check (char_length(home_location) <= 80),
  add column compliance_due date,
  add column maintenance_note text check (char_length(maintenance_note) <= 500);

-- ---------------------------------------------------------------------------
-- Admin writes
-- ---------------------------------------------------------------------------

create or replace function public._require_admin()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'wrong_role: admin required' using errcode = '42501';
  end if;
  return auth.uid();
end;
$$;

/** Approve a driver application, or send it back with a note (optionally rejecting one document). */
create or replace function public.admin_decide_driver(
  p_driver_id uuid,
  p_approve boolean,
  p_note text default null,
  p_reject_document public.document_type default null
)
returns public.driver_profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  d public.driver_profiles;
begin
  select * into d from public.driver_profiles where user_id = p_driver_id for update;
  if not found then
    raise exception 'driver_not_found' using errcode = 'P0002';
  end if;

  if p_approve then
    if exists (
      select 1 from public.driver_documents where driver_id = p_driver_id and status = 'rejected'
    ) then
      raise exception 'documents_rejected' using errcode = 'P0001';
    end if;
    update public.driver_documents set status = 'approved', reviewed_at = now(), reviewed_by = v_admin
    where driver_id = p_driver_id and status = 'pending';
    update public.vehicles set status = 'approved', is_active = true, reviewed_at = now(), reviewed_by = v_admin
    where driver_id = p_driver_id and status = 'pending';
    update public.driver_profiles set
      verification_status = 'approved', approved_at = now(), reviewed_at = now(),
      reviewed_by = v_admin, review_notes = nullif(trim(p_note), '')
    where user_id = p_driver_id returning * into d;
  else
    if coalesce(trim(p_note), '') = '' then
      raise exception 'note_required' using errcode = 'P0001';
    end if;
    if p_reject_document is not null then
      update public.driver_documents set
        status = 'rejected', rejection_reason = left(p_note, 300), reviewed_at = now(), reviewed_by = v_admin
      where driver_id = p_driver_id and type = p_reject_document;
    end if;
    update public.driver_profiles set
      verification_status = 'action_needed', reviewed_at = now(), reviewed_by = v_admin,
      review_notes = left(p_note, 1000)
    where user_id = p_driver_id returning * into d;
  end if;
  return d;
end;
$$;

/** Assign, change the status of, or add a note to a safety alert or incident report. */
create or replace function public.admin_update_safety_case(
  p_kind text,
  p_id uuid,
  p_assign_to uuid default null,
  p_status public.alert_status default null,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  v_alert uuid := case when p_kind = 'alert' then p_id end;
  v_incident uuid := case when p_kind = 'incident' then p_id end;
  v_status public.alert_status;
begin
  if p_kind not in ('alert', 'incident') then
    raise exception 'invalid_request' using errcode = '22023';
  end if;
  if p_assign_to is not null and not exists (
    select 1 from public.profiles where id = p_assign_to and role = 'admin'
  ) then
    raise exception 'invalid_request: assignee must be an admin' using errcode = '22023';
  end if;
  if p_status = 'resolved' and coalesce(trim(p_note), '') = '' then
    raise exception 'note_required' using errcode = 'P0001';
  end if;

  if p_kind = 'alert' then
    update public.safety_alerts set
      assigned_to = coalesce(p_assign_to, assigned_to),
      status = coalesce(p_status, case when p_assign_to is not null and status = 'open' then 'acknowledged'::public.alert_status else status end),
      acknowledged_at = case when acknowledged_at is null and (p_assign_to is not null or p_status is not null) then now() else acknowledged_at end,
      acknowledged_by = case when acknowledged_by is null and (p_assign_to is not null or p_status is not null) then v_admin else acknowledged_by end,
      resolved_at = case when p_status = 'resolved' then now() else resolved_at end,
      resolution_note = case when p_status = 'resolved' then p_note else resolution_note end
    where id = p_id returning status into v_status;
  else
    update public.incident_reports set
      assigned_to = coalesce(p_assign_to, assigned_to),
      status = coalesce(p_status, case when p_assign_to is not null and status = 'open' then 'acknowledged'::public.alert_status else status end),
      acknowledged_at = case when acknowledged_at is null and (p_assign_to is not null or p_status is not null) then now() else acknowledged_at end,
      acknowledged_by = case when acknowledged_by is null and (p_assign_to is not null or p_status is not null) then v_admin else acknowledged_by end,
      resolved_at = case when p_status = 'resolved' then now() else resolved_at end,
      resolution_note = case when p_status = 'resolved' then p_note else resolution_note end
    where id = p_id returning status into v_status;
  end if;
  if v_status is null then
    raise exception 'case_not_found' using errcode = 'P0002';
  end if;

  if p_assign_to is not null then
    insert into public.safety_case_events (alert_id, incident_id, actor_id, kind, note)
    values (v_alert, v_incident, v_admin, 'assigned', (select full_name from public.profiles where id = p_assign_to));
  end if;
  if p_status is not null then
    insert into public.safety_case_events (alert_id, incident_id, actor_id, kind, status, note)
    values (v_alert, v_incident, v_admin, 'status', p_status, left(p_note, 2000));
  elsif coalesce(trim(p_note), '') <> '' then
    insert into public.safety_case_events (alert_id, incident_id, actor_id, kind, note)
    values (v_alert, v_incident, v_admin, 'note', left(p_note, 2000));
  end if;
  return jsonb_build_object('status', v_status);
end;
$$;

/** Ask for a refund; the payments worker sends it to the provider (TODO(payments)). */
create or replace function public.admin_request_refund(p_payment_id uuid, p_amount integer, p_reason text)
returns public.refunds
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  p public.payments;
  v_refunded integer;
  v_row public.refunds;
begin
  select * into p from public.payments where id = p_payment_id for update;
  if not found then
    raise exception 'payment_not_found' using errcode = 'P0002';
  end if;
  if p.status <> 'succeeded' then
    raise exception 'payment_not_refundable' using errcode = 'P0001';
  end if;
  select coalesce(sum(amount), 0) into v_refunded from public.refunds
  where payment_id = p_payment_id and status <> 'rejected';
  if p_amount is null or p_amount <= 0 or p_amount > p.amount - v_refunded then
    raise exception 'invalid_refund_amount' using errcode = 'P0001';
  end if;
  insert into public.refunds (payment_id, amount, reason, requested_by)
  values (p_payment_id, p_amount, trim(p_reason), v_admin)
  returning * into v_row;
  return v_row;
end;
$$;

/** Fleet: available ↔ maintenance (with a note) ↔ retired. */
create or replace function public.admin_set_rental_vehicle_status(
  p_vehicle_id uuid,
  p_status public.rental_vehicle_status,
  p_note text default null
)
returns public.rental_vehicles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  v public.rental_vehicles;
begin
  update public.rental_vehicles set
    status = p_status,
    maintenance_note = case when p_status = 'maintenance' then left(p_note, 500) else null end
  where id = p_vehicle_id returning * into v;
  if not found then
    raise exception 'vehicle_not_found' using errcode = 'P0002';
  end if;
  return v;
end;
$$;

/** Fleet: add a rental car (prices are placeholders until the owner sets them). */
create or replace function public.admin_add_rental_vehicle(
  p_city_code text,
  p_make text,
  p_model text,
  p_year smallint,
  p_category text,
  p_transmission public.transmission_type,
  p_seats smallint,
  p_fuel_type public.fuel_type,
  p_plate text,
  p_color text,
  p_daily_rate integer,
  p_deposit_amount integer,
  p_km_per_day integer,
  p_airport_pickup boolean default false,
  p_home_location text default null
)
returns public.rental_vehicles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  v public.rental_vehicles;
begin
  insert into public.rental_vehicles (
    city_code, make, model, year, category, transmission, seats, fuel_type, plate, color,
    daily_rate, deposit_amount, km_per_day, airport_pickup_available, home_location
  ) values (
    p_city_code, trim(p_make), trim(p_model), p_year, p_category, p_transmission, p_seats, p_fuel_type,
    upper(trim(p_plate)), p_color, p_daily_rate, p_deposit_amount, p_km_per_day, p_airport_pickup,
    p_home_location
  ) returning * into v;
  return v;
exception when unique_violation then
  raise exception 'plate_taken' using errcode = 'P0001';
end;
$$;

-- ---------------------------------------------------------------------------
-- Admin reads that need aggregation (lists are plain selects under "admins read all").
-- ---------------------------------------------------------------------------

/** Overview cards, the 7-day activity chart and "needs attention". */
create or replace function public.admin_overview(p_city_code text default null, p_now timestamptz default now())
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
  v_today timestamptz := date_trunc('day', p_now at time zone 'Africa/Douala') at time zone 'Africa/Douala';
  v_yesterday timestamptz := v_today - interval '1 day';
begin
  return jsonb_build_object(
    'rides_today', (select count(*) from public.rides where requested_at >= v_today and (p_city_code is null or city_code = p_city_code)),
    'rides_yesterday', (select count(*) from public.rides where requested_at >= v_yesterday and requested_at < v_yesterday + (p_now - v_today) and (p_city_code is null or city_code = p_city_code)),
    'active_rentals', (select count(*) from public.rental_bookings where status in ('active', 'return_pending')),
    'pickups_today', (select count(*) from public.rental_bookings where starts_at >= v_today and starts_at < v_today + interval '1 day' and status not in ('cancelled')),
    'returns_today', (select count(*) from public.rental_bookings where ends_at >= v_today and ends_at < v_today + interval '1 day' and status not in ('cancelled')),
    'revenue_today', (select coalesce(sum(amount), 0) from public.payments where status = 'succeeded' and purpose in ('ride_fare', 'rental') and confirmed_at >= v_today),
    'revenue_yesterday', (select coalesce(sum(amount), 0) from public.payments where status = 'succeeded' and purpose in ('ride_fare', 'rental') and confirmed_at >= v_yesterday and confirmed_at < v_yesterday + (p_now - v_today)),
    'drivers_online', (select count(*) from public.driver_locations where is_online),
    'drivers_on_trip', (select count(distinct driver_id) from public.rides where status in ('driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress')),
    'rides_in_progress', (select count(*) from public.rides where status = 'in_progress'),
    'daily', (
      select jsonb_agg(jsonb_build_object(
        'day', d::date,
        'rides', (select count(*) from public.rides r where r.requested_at >= d at time zone 'Africa/Douala' and r.requested_at < (d + interval '1 day') at time zone 'Africa/Douala'),
        'rentals', (select count(*) from public.rental_bookings b where b.created_at >= d at time zone 'Africa/Douala' and b.created_at < (d + interval '1 day') at time zone 'Africa/Douala')
      ) order by d)
      from generate_series((v_today at time zone 'Africa/Douala') - interval '6 days', v_today at time zone 'Africa/Douala', interval '1 day') d
    ),
    'open_alerts', (select count(*) from public.safety_alerts where status <> 'resolved')
      + (select count(*) from public.incident_reports where status <> 'resolved'),
    'documents_expiring', (
      select coalesce(jsonb_agg(jsonb_build_object('driver_ref', p.reference, 'type', d.type, 'expires_on', d.expires_on) order by d.expires_on), '[]')
      from public.driver_documents d join public.driver_profiles p on p.user_id = d.driver_id
      where d.expires_on is not null and d.expires_on <= (p_now at time zone 'Africa/Douala')::date + 14
    )
  );
end;
$$;

/** Revenue by day (rides vs rentals) and today's reconciliation. */
create or replace function public.admin_payments_summary(p_from date, p_to date)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_admin uuid := public._require_admin();
begin
  return jsonb_build_object(
    'daily', (
      select jsonb_agg(jsonb_build_object(
        'day', d::date,
        'rides', (select coalesce(sum(amount), 0) from public.payments p where p.status = 'succeeded' and p.purpose = 'ride_fare' and (p.confirmed_at at time zone 'Africa/Douala')::date = d::date),
        'rentals', (select coalesce(sum(amount), 0) from public.payments p where p.status = 'succeeded' and p.purpose = 'rental' and (p.confirmed_at at time zone 'Africa/Douala')::date = d::date)
      ) order by d)
      from generate_series(p_from::timestamp, p_to::timestamp, interval '1 day') d
    ),
    'captured_today', (select coalesce(sum(amount), 0) from public.payments where status = 'succeeded' and purpose in ('ride_fare', 'rental') and (confirmed_at at time zone 'Africa/Douala')::date = p_to),
    'refunds_processing', (select coalesce(sum(amount), 0) from public.refunds where status in ('requested', 'processing')),
    'deposit_holds', (select coalesce(sum(deposit_amount), 0) from public.rental_bookings where deposit_status = 'held'),
    'next_payout', (
      select coalesce(sum(r.driver_earnings), 0) from public.rides r
      where r.status = 'completed'
        and r.completed_at >= date_trunc('week', now() at time zone 'Africa/Douala') at time zone 'Africa/Douala'
    )
  );
end;
$$;

revoke execute on function
  public._require_admin(),
  public.admin_decide_driver(uuid, boolean, text, public.document_type),
  public.admin_update_safety_case(text, uuid, uuid, public.alert_status, text),
  public.admin_request_refund(uuid, integer, text),
  public.admin_set_rental_vehicle_status(uuid, public.rental_vehicle_status, text),
  public.admin_add_rental_vehicle(text, text, text, smallint, text, public.transmission_type, smallint, public.fuel_type, text, text, integer, integer, integer, boolean, text),
  public.admin_overview(text, timestamptz),
  public.admin_payments_summary(date, date)
from public, anon;
grant execute on function
  public.admin_decide_driver(uuid, boolean, text, public.document_type),
  public.admin_update_safety_case(text, uuid, uuid, public.alert_status, text),
  public.admin_request_refund(uuid, integer, text),
  public.admin_set_rental_vehicle_status(uuid, public.rental_vehicle_status, text),
  public.admin_add_rental_vehicle(text, text, text, smallint, text, public.transmission_type, smallint, public.fuel_type, text, text, integer, integer, integer, boolean, text),
  public.admin_overview(text, timestamptz),
  public.admin_payments_summary(date, date)
to authenticated;

-- The dashboard follows safety cases live (safety_alerts and incident_reports already publish).
alter publication supabase_realtime add table public.safety_case_events;
