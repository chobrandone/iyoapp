-- iyodriver · 10 · rental lifecycle: payment on booking, cancellation, handover / return
-- inspections with both-party confirmation, deposit release or partial hold (spec §9.5).
--
-- booking status: pending_payment → confirmed → driver_assigned → active → return_pending → completed
--                 (cancelled from pending_payment / confirmed / driver_assigned before the start)

-- ---------------------------------------------------------------------------
-- New booking → its payment. Cash is collected at handover, so cash bookings are confirmed now.
-- ---------------------------------------------------------------------------

create or replace function public.on_rental_booking_created()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.payments (payer_id, rental_booking_id, purpose, method, amount, status, provider)
  values (
    new.rider_id, new.id, 'rental', new.payment_method, new.total_amount, 'pending',
    case when new.payment_method = 'cash' then 'cash' else 'mock' end
  );
  if new.payment_method = 'cash' then
    update public.rental_bookings set status = 'confirmed' where id = new.id;
  end if;
  return new;
end;
$$;

create trigger rental_booking_created
  after insert on public.rental_bookings
  for each row execute function public.on_rental_booking_created();

-- ---------------------------------------------------------------------------
-- Rider: cancel before the rental starts
-- ---------------------------------------------------------------------------

create or replace function public.cancel_rental_booking(p_booking_id uuid, p_reason text default null)
returns public.rental_bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('rider');
  b public.rental_bookings;
begin
  select * into b from public.rental_bookings where id = p_booking_id and rider_id = v_uid for update;
  if not found then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;
  if b.status not in ('pending_payment', 'confirmed', 'driver_assigned') or b.starts_at <= now() then
    raise exception 'booking_not_cancellable' using errcode = 'P0001';
  end if;
  update public.rental_bookings
  set status = 'cancelled', cancelled_at = now(), cancel_reason = left(p_reason, 200)
  where id = p_booking_id
  returning * into b;
  -- TODO(payments): refund succeeded payments through the provider once one is chosen.
  update public.payments set status = 'cancelled'
  where rental_booking_id = p_booking_id and status in ('pending', 'processing');
  return b;
end;
$$;

-- ---------------------------------------------------------------------------
-- Admin / service: assign the delivering driver (admin dashboard later; demo assigns itself).
-- ---------------------------------------------------------------------------

create or replace function public.assign_rental_driver(p_booking_id uuid, p_driver_id uuid)
returns public.rental_bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  b public.rental_bookings;
begin
  if not (public.is_admin() or (select auth.role()) = 'service_role') then
    raise exception 'wrong_role: admin required' using errcode = '42501';
  end if;
  if not public.is_approved_driver(p_driver_id) then
    raise exception 'driver_not_approved' using errcode = '42501';
  end if;
  update public.rental_bookings
  set assigned_driver_id = p_driver_id, status = 'driver_assigned'
  where id = p_booking_id and status = 'confirmed'
  returning * into b;
  if not found then
    raise exception 'booking_not_assignable' using errcode = 'P0001';
  end if;
  return b;
end;
$$;

-- ---------------------------------------------------------------------------
-- Driver: handover / return inspection (fuel, odometer, photos of 4 sides + interior, damage)
-- ---------------------------------------------------------------------------

create or replace function public.submit_rental_inspection(
  p_booking_id uuid,
  p_type public.inspection_type,
  p_fuel_level smallint,
  p_odometer_km integer,
  p_photo_paths jsonb,
  p_damage_notes text default null,
  p_checklist jsonb default '{}',
  p_deposit_hold_amount integer default 0
)
returns public.rental_inspections
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  b public.rental_bookings;
  v_row public.rental_inspections;
begin
  select * into b from public.rental_bookings where id = p_booking_id and assigned_driver_id = v_uid for update;
  if not found then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;
  if p_type = 'handover' and b.status <> 'driver_assigned' then
    raise exception 'handover_not_allowed' using errcode = 'P0001';
  end if;
  if p_type = 'return' and b.status <> 'active' then
    raise exception 'return_not_allowed' using errcode = 'P0001';
  end if;
  -- All five photos are required.
  if not (p_photo_paths ?& array['front', 'back', 'left', 'right', 'interior']) then
    raise exception 'photos_missing' using errcode = 'P0001';
  end if;
  if p_deposit_hold_amount < 0 or p_deposit_hold_amount > b.deposit_amount or (p_type = 'handover' and p_deposit_hold_amount <> 0) then
    raise exception 'invalid_deposit_hold' using errcode = 'P0001';
  end if;

  insert into public.rental_inspections (
    booking_id, type, inspector_id, fuel_level, odometer_km, photo_paths, damage_notes, checklist,
    deposit_hold_amount, inspector_confirmed_at
  ) values (
    p_booking_id, p_type, v_uid, p_fuel_level, p_odometer_km, p_photo_paths, left(p_damage_notes, 2000),
    coalesce(p_checklist, '{}'), p_deposit_hold_amount, now()
  )
  on conflict (booking_id, type) do update set
    fuel_level = excluded.fuel_level,
    odometer_km = excluded.odometer_km,
    photo_paths = excluded.photo_paths,
    damage_notes = excluded.damage_notes,
    checklist = excluded.checklist,
    deposit_hold_amount = excluded.deposit_hold_amount,
    inspector_confirmed_at = now(),
    rider_confirmed_at = null
  returning * into v_row;

  if p_type = 'return' then
    update public.rental_bookings set status = 'return_pending' where id = p_booking_id;
  end if;
  return v_row;
end;
$$;

-- ---------------------------------------------------------------------------
-- Rider: confirm an inspection. Handover → rental active, deposit held.
-- Return → rental completed, deposit released or partially held.
-- ---------------------------------------------------------------------------

create or replace function public.confirm_rental_inspection(p_booking_id uuid, p_type public.inspection_type)
returns public.rental_bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('rider');
  b public.rental_bookings;
  i public.rental_inspections;
begin
  select * into b from public.rental_bookings where id = p_booking_id and rider_id = v_uid for update;
  if not found then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;
  select * into i from public.rental_inspections where booking_id = p_booking_id and type = p_type;
  if not found or i.inspector_confirmed_at is null then
    raise exception 'inspection_not_ready' using errcode = 'P0001';
  end if;
  update public.rental_inspections set rider_confirmed_at = now() where id = i.id;

  if p_type = 'handover' then
    if b.status <> 'driver_assigned' then
      raise exception 'handover_not_allowed' using errcode = 'P0001';
    end if;
    update public.rental_bookings set status = 'active', deposit_status = 'held'
    where id = p_booking_id returning * into b;
  else
    if b.status <> 'return_pending' then
      raise exception 'return_not_allowed' using errcode = 'P0001';
    end if;
    update public.rental_bookings set
      status = 'completed',
      deposit_held_amount = i.deposit_hold_amount,
      deposit_status = (case when i.deposit_hold_amount = 0 then 'released' else 'partially_held' end)::public.deposit_status
    where id = p_booking_id returning * into b;
    -- TODO(payments): release the deposit hold through the provider.
  end if;
  return b;
end;
$$;

-- ---------------------------------------------------------------------------
-- Assigned driver: who to hand the car to (profiles are otherwise private).
-- ---------------------------------------------------------------------------

create or replace function public.get_rental_rider(p_booking_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  p public.profiles;
begin
  select pr.* into p
  from public.rental_bookings b join public.profiles pr on pr.id = b.rider_id
  where b.id = p_booking_id and b.assigned_driver_id = (select auth.uid());
  if not found then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;
  return jsonb_build_object('name', p.full_name, 'phone', p.phone);
end;
$$;

revoke execute on function
  public.on_rental_booking_created(),
  public.get_rental_rider(uuid),
  public.cancel_rental_booking(uuid, text),
  public.assign_rental_driver(uuid, uuid),
  public.submit_rental_inspection(uuid, public.inspection_type, smallint, integer, jsonb, text, jsonb, integer),
  public.confirm_rental_inspection(uuid, public.inspection_type)
from public, anon;

grant execute on function
  public.get_rental_rider(uuid),
  public.cancel_rental_booking(uuid, text),
  public.submit_rental_inspection(uuid, public.inspection_type, smallint, integer, jsonb, text, jsonb, integer),
  public.confirm_rental_inspection(uuid, public.inspection_type),
  public.assign_rental_driver(uuid, uuid)
to authenticated;

grant execute on function public.assign_rental_driver(uuid, uuid) to service_role;

alter publication supabase_realtime add table public.rental_inspections;

-- ---------------------------------------------------------------------------
-- Trusted contacts: relationship label shown on R26 ("Sister · +237 …").
-- ---------------------------------------------------------------------------

alter table public.trusted_contacts
  add column relationship text check (char_length(relationship) <= 40);
