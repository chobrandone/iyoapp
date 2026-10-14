-- iyodriver · 07 · server-authoritative RPCs
--
-- Client RPCs (granted to authenticated) check the caller's role with require_role().
-- Server RPCs (service_role only) are called by Edge Functions such as match-ride.

-- ---------------------------------------------------------------------------
-- Internal: the only place a ride's status changes
-- ---------------------------------------------------------------------------

create or replace function public._transition_ride(
  p_ride_id uuid,
  p_to public.ride_status,
  p_actor public.ride_actor,
  p_actor_id uuid,
  p_metadata jsonb default '{}'
)
returns public.rides
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_ride public.rides;
  v_from public.ride_status;
begin
  select * into v_ride from public.rides where id = p_ride_id for update;
  if not found then
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;
  v_from := v_ride.status;

  if p_actor <> 'admin' and not exists (
    select 1 from public.ride_status_transitions t
    where t.from_status = v_from and t.to_status = p_to and t.actor = p_actor
  ) then
    raise exception 'invalid_transition: % -> % by %', v_from, p_to, p_actor using errcode = 'P0001';
  end if;

  update public.rides set
    status = p_to,
    assigned_at = case when p_to = 'driver_assigned' then now() else assigned_at end,
    arriving_at = case when p_to = 'driver_arriving' then now() else arriving_at end,
    arrived_at = case when p_to = 'driver_arrived' then now() else arrived_at end,
    started_at = case when p_to = 'in_progress' then now() else started_at end,
    completed_at = case when p_to = 'completed' then now() else completed_at end,
    cancelled_at = case when p_to in ('cancelled_by_rider', 'cancelled_by_driver') then now() else cancelled_at end,
    ended_at = case
      when p_to in ('completed', 'cancelled_by_rider', 'cancelled_by_driver', 'no_drivers_found') then now()
      else ended_at
    end,
    cancel_reason = coalesce(p_metadata ->> 'reason', cancel_reason)
  where id = p_ride_id
  returning * into v_ride;

  insert into public.ride_events (ride_id, from_status, to_status, actor, actor_id, metadata)
  values (p_ride_id, v_from, p_to, p_actor, p_actor_id, coalesce(p_metadata, '{}'));

  -- Any open offer dies with the search.
  if p_to not in ('searching') then
    update public.ride_offers set status = 'cancelled', responded_at = now()
    where ride_id = p_ride_id and status = 'pending';
  end if;

  return v_ride;
end;
$$;

-- ---------------------------------------------------------------------------
-- Pricing (9.4)
-- fare = max(minimum_fare, base + per_km*km + per_min*min) * category_multiplier, rounded to 50 FCFA
-- ---------------------------------------------------------------------------

create or replace function public.compute_fare(
  p_city_code text,
  p_category_code text,
  p_distance_m integer,
  p_duration_s integer
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  c public.fare_config;
  v_km numeric := greatest(p_distance_m, 0) / 1000.0;
  v_min numeric := greatest(p_duration_s, 0) / 60.0;
  v_metered numeric;
  v_fare integer;
begin
  select * into c from public.fare_config
  where city_code = p_city_code and category_code = p_category_code and is_active;
  if not found then
    raise exception 'no_fare_config: %/%', p_city_code, p_category_code using errcode = 'P0002';
  end if;

  v_metered := c.base_fare + c.per_km * v_km + c.per_min * v_min;
  v_fare := public.round_fcfa(greatest(c.minimum_fare, v_metered) * c.category_multiplier);

  return jsonb_build_object(
    'fare_amount', v_fare,
    'currency', c.currency,
    'commission_rate', c.commission_rate,
    'driver_earnings', v_fare - round(v_fare * c.commission_rate)::integer,
    'is_placeholder', c.is_placeholder,
    'breakdown', jsonb_build_object(
      'base_fare', c.base_fare,
      'distance_km', round(v_km, 2),
      'distance_amount', round(c.per_km * v_km),
      'duration_min', round(v_min, 1),
      'duration_amount', round(c.per_min * v_min),
      'minimum_fare', c.minimum_fare,
      'category_multiplier', c.category_multiplier
    )
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Rider RPCs
-- ---------------------------------------------------------------------------

create or replace function public.request_ride(
  p_quote_id uuid,
  p_payment_method public.payment_method_type,
  p_payment_method_id uuid default null
)
returns public.rides
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('rider');
  q public.fare_quotes;
  v_ride public.rides;
  v_pin text;
begin
  select * into q from public.fare_quotes where id = p_quote_id and rider_id = v_uid for update;
  if not found then
    raise exception 'quote_not_found' using errcode = 'P0002';
  end if;
  if q.used_at is not null then
    raise exception 'quote_already_used' using errcode = 'P0001';
  end if;
  if q.expires_at < now() then
    raise exception 'quote_expired' using errcode = 'P0001';
  end if;

  if p_payment_method = 'cash' then
    p_payment_method_id := null;
  elsif p_payment_method_id is null or not exists (
    select 1 from public.payment_methods m
    where m.id = p_payment_method_id and m.user_id = v_uid and m.type = p_payment_method
  ) then
    raise exception 'invalid_payment_method' using errcode = 'P0001';
  end if;

  begin
    insert into public.rides (
      rider_id, quote_id, city_code, category_code,
      pickup_location, pickup_address, pickup_place_id,
      dropoff_location, dropoff_address, dropoff_place_id,
      route_polyline, distance_m, duration_s,
      fare_amount, commission_rate, payment_method, payment_method_id
    ) values (
      v_uid, q.id, q.city_code, q.category_code,
      q.pickup_location, q.pickup_address, q.pickup_place_id,
      q.dropoff_location, q.dropoff_address, q.dropoff_place_id,
      q.route_polyline, q.distance_m, q.duration_s,
      q.fare_amount, q.commission_rate, p_payment_method, p_payment_method_id
    )
    returning * into v_ride;
  exception when unique_violation then
    raise exception 'rider_has_open_ride' using errcode = 'P0001';
  end;

  update public.fare_quotes set used_at = now() where id = q.id;

  -- 4-digit pickup PIN from a CSPRNG.
  v_pin := lpad(((('x' || encode(extensions.gen_random_bytes(4), 'hex'))::bit(32)::bigint) % 10000)::text, 4, '0');
  insert into public.ride_pins (ride_id, pin) values (v_ride.id, v_pin);

  insert into public.ride_events (ride_id, from_status, to_status, actor, actor_id)
  values (v_ride.id, null, 'requested', 'rider', v_uid);

  return v_ride;
end;
$$;

create or replace function public.cancel_ride_as_rider(p_ride_id uuid, p_reason text default null)
returns public.rides
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('rider');
begin
  if not exists (select 1 from public.rides where id = p_ride_id and rider_id = v_uid) then
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;
  return public._transition_ride(
    p_ride_id, 'cancelled_by_rider', 'rider', v_uid,
    jsonb_build_object('reason', left(p_reason, 200))
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Driver RPCs
-- ---------------------------------------------------------------------------

create or replace function public.set_driver_online(
  p_online boolean,
  p_lat double precision default null,
  p_lng double precision default null
)
returns public.driver_locations
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  v_vehicle uuid;
  v_row public.driver_locations;
begin
  if not p_online then
    if exists (
      select 1 from public.rides
      where driver_id = v_uid and status in ('driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress')
    ) then
      raise exception 'finish_active_ride_first' using errcode = 'P0001';
    end if;
    update public.ride_offers set status = 'declined', responded_at = now()
    where driver_id = v_uid and status = 'pending';
    update public.driver_locations set is_online = false, went_online_at = null, updated_at = now()
    where driver_id = v_uid
    returning * into v_row;
    return v_row;
  end if;

  if not public.is_approved_driver(v_uid) then
    raise exception 'driver_not_approved' using errcode = '42501';
  end if;
  select id into v_vehicle from public.vehicles
  where driver_id = v_uid and is_active and status = 'approved';
  if v_vehicle is null then
    raise exception 'no_active_vehicle' using errcode = 'P0001';
  end if;
  if p_lat is null or p_lng is null then
    raise exception 'location_required' using errcode = '22023';
  end if;

  insert into public.driver_locations (driver_id, location, is_online, vehicle_id, went_online_at, updated_at)
  values (v_uid, public.make_point(p_lat, p_lng), true, v_vehicle, now(), now())
  on conflict (driver_id) do update set
    location = excluded.location,
    is_online = true,
    vehicle_id = excluded.vehicle_id,
    went_online_at = coalesce(public.driver_locations.went_online_at, now()),
    updated_at = now()
  returning * into v_row;
  return v_row;
end;
$$;

create or replace function public.update_driver_location(
  p_lat double precision,
  p_lng double precision,
  p_heading real default null,
  p_speed_mps real default null,
  p_accuracy_m real default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
begin
  if p_lat not between -90 and 90 or p_lng not between -180 and 180 then
    raise exception 'invalid_coordinates' using errcode = '22023';
  end if;
  update public.driver_locations set
    location = public.make_point(p_lat, p_lng),
    heading = case when p_heading is null then null else mod(p_heading::numeric + 360, 360)::real end,
    speed_mps = greatest(p_speed_mps, 0),
    accuracy_m = greatest(p_accuracy_m, 0),
    updated_at = now()
  where driver_id = v_uid and is_online;
  if not found then
    raise exception 'driver_offline' using errcode = 'P0001';
  end if;
end;
$$;

create or replace function public.respond_to_ride_offer(p_offer_id uuid, p_accept boolean)
returns public.rides
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  o public.ride_offers;
  v_vehicle uuid;
  v_ride public.rides;
begin
  select * into o from public.ride_offers where id = p_offer_id and driver_id = v_uid for update;
  if not found then
    raise exception 'offer_not_found' using errcode = 'P0002';
  end if;
  if o.status <> 'pending' then
    raise exception 'offer_not_pending' using errcode = 'P0001';
  end if;
  if o.expires_at < now() then
    raise exception 'offer_expired' using errcode = 'P0001'; -- expire_ride_offers() marks it
  end if;

  if not p_accept then
    update public.ride_offers set status = 'declined', responded_at = now() where id = o.id;
    return null;
  end if;

  select vehicle_id into v_vehicle from public.driver_locations where driver_id = v_uid and is_online;
  if v_vehicle is null then
    raise exception 'driver_offline' using errcode = 'P0001';
  end if;

  update public.ride_offers set status = 'accepted', responded_at = now() where id = o.id;
  begin
    update public.rides set driver_id = v_uid, vehicle_id = v_vehicle where id = o.ride_id;
    v_ride := public._transition_ride(o.ride_id, 'driver_assigned', 'driver', v_uid,
      jsonb_build_object('offer_id', o.id));
  exception when unique_violation then
    raise exception 'driver_has_active_ride' using errcode = 'P0001';
  end;
  return v_ride;
end;
$$;

/** Driver-side transitions other than accept and start (start needs the PIN). */
create or replace function public.driver_update_ride_status(
  p_ride_id uuid,
  p_status public.ride_status,
  p_reason text default null
)
returns public.rides
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  v_ride public.rides;
begin
  if p_status not in ('driver_arriving', 'driver_arrived', 'completed', 'cancelled_by_driver') then
    raise exception 'status_not_allowed_here: %', p_status using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.rides where id = p_ride_id and driver_id = v_uid) then
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;

  v_ride := public._transition_ride(p_ride_id, p_status, 'driver', v_uid,
    case when p_reason is null then '{}'::jsonb else jsonb_build_object('reason', left(p_reason, 200)) end);

  if p_status = 'completed' then
    -- Cash is collected by the driver; other methods are confirmed by the provider webhook.
    insert into public.payments (payer_id, ride_id, purpose, method, amount, status, provider)
    values (
      v_ride.rider_id, v_ride.id, 'ride_fare', v_ride.payment_method, v_ride.fare_amount, 'pending',
      case when v_ride.payment_method = 'cash' then 'cash' else 'mock' end
    );
  end if;
  return v_ride;
end;
$$;

/** Check the rider's pickup PIN and start the trip. Never raises on a wrong PIN, so the attempt is counted. */
create or replace function public.verify_pickup_pin(p_ride_id uuid, p_pin text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  v_ride public.rides;
  v_pin public.ride_pins;
  v_max integer := coalesce((select (value)::integer from public.app_config where key = 'pin_max_attempts'), 5);
begin
  select * into v_ride from public.rides where id = p_ride_id and driver_id = v_uid;
  if not found then
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;
  if v_ride.status <> 'driver_arrived' then
    raise exception 'driver_not_arrived' using errcode = 'P0001';
  end if;

  select * into v_pin from public.ride_pins where ride_id = p_ride_id for update;
  if v_pin.locked_at is not null then
    return jsonb_build_object('ok', false, 'locked', true, 'attempts_left', 0);
  end if;

  if p_pin is not null and p_pin = v_pin.pin then
    update public.ride_pins set verified_at = now() where ride_id = p_ride_id;
    perform public._transition_ride(p_ride_id, 'in_progress', 'driver', v_uid, '{"pin_verified": true}');
    return jsonb_build_object('ok', true, 'locked', false, 'attempts_left', v_max - v_pin.failed_attempts);
  end if;

  update public.ride_pins set
    failed_attempts = failed_attempts + 1,
    locked_at = case when failed_attempts + 1 >= v_max then now() else null end
  where ride_id = p_ride_id
  returning * into v_pin;

  if v_pin.locked_at is not null then
    -- Alert the support / safety team.
    insert into public.incident_reports (ride_id, reported_by, rider_id, driver_id, vehicle_id, category, description, snapshot)
    values (
      p_ride_id, v_uid, v_ride.rider_id, v_uid, v_ride.vehicle_id, 'pickup_pin_locked',
      'Pickup PIN locked after ' || v_max || ' wrong attempts.',
      jsonb_build_object('pickup_address', v_ride.pickup_address)
    );
  end if;

  return jsonb_build_object(
    'ok', false,
    'locked', v_pin.locked_at is not null,
    'attempts_left', greatest(v_max - v_pin.failed_attempts, 0)
  );
end;
$$;

/** Driver submits onboarding for review once identity, vehicle and required documents are in. */
create or replace function public.submit_driver_application()
returns public.driver_profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  d public.driver_profiles;
  v_required public.document_type[];
  v_missing public.document_type[];
begin
  select * into d from public.driver_profiles where user_id = v_uid for update;
  if d.verification_status not in ('pending', 'action_needed') then
    raise exception 'application_not_editable' using errcode = 'P0001';
  end if;
  if d.licence_number is null or d.national_id_number is null or d.city_code is null then
    raise exception 'identity_incomplete' using errcode = 'P0001';
  end if;
  if not exists (select 1 from public.vehicles where driver_id = v_uid and status <> 'inactive') then
    raise exception 'vehicle_missing' using errcode = 'P0001';
  end if;

  select coalesce(array_agg(x::public.document_type), '{}') into v_required
  from jsonb_array_elements_text(
    coalesce((select value from public.app_config where key = 'required_driver_documents'), '[]')
  ) x;
  select coalesce(array_agg(r), '{}') into v_missing
  from unnest(v_required) r
  where not exists (
    select 1 from public.driver_documents doc
    where doc.driver_id = v_uid and doc.type = r and doc.status <> 'rejected'
  );
  if cardinality(v_missing) > 0 then
    raise exception 'documents_missing: %', v_missing using errcode = 'P0001';
  end if;

  update public.driver_profiles set verification_status = 'under_review', submitted_at = now()
  where user_id = v_uid
  returning * into d;
  return d;
end;
$$;

-- ---------------------------------------------------------------------------
-- Both apps
-- ---------------------------------------------------------------------------

/**
 * The other party of a ride, with only what the caller may see:
 *   rider -> driver name, photo, rating, phone, vehicle (once assigned)
 *   driver -> rider first name + rating while offered/before pickup; phone once assigned;
 *             full name once the trip has started.
 */
create or replace function public.get_ride_counterpart(p_ride_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  r public.rides;
  p public.profiles;
  v public.vehicles;
begin
  select * into r from public.rides where id = p_ride_id;
  if not found then
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;

  if r.rider_id = v_uid then
    if r.driver_id is null then
      return null;
    end if;
    select * into p from public.profiles where id = r.driver_id;
    select * into v from public.vehicles where id = r.vehicle_id;
    return jsonb_build_object(
      'role', 'driver',
      'id', p.id,
      'full_name', p.full_name,
      'avatar_url', p.avatar_url,
      'rating', p.rating,
      'rating_count', p.rating_count,
      'phone', case when r.ended_at is null then p.phone end, -- TODO: masked calling (out of scope v1)
      'vehicle', case when v.id is null then null else jsonb_build_object(
        'make', v.make, 'model', v.model, 'color', v.color, 'plate', v.plate, 'category_code', v.category_code
      ) end
    );
  end if;

  if r.driver_id = v_uid or exists (
    select 1 from public.ride_offers o where o.ride_id = p_ride_id and o.driver_id = v_uid and o.status = 'pending'
  ) then
    select * into p from public.profiles where id = r.rider_id;
    return jsonb_build_object(
      'role', 'rider',
      'id', p.id,
      'first_name', split_part(p.full_name, ' ', 1),
      'full_name', case when r.status in ('in_progress', 'completed') then p.full_name end,
      'avatar_url', case when r.driver_id = v_uid then p.avatar_url end,
      'rating', p.rating,
      'rating_count', p.rating_count,
      'phone', case
        when r.driver_id = v_uid and r.ended_at is null then p.phone
      end
    );
  end if;

  raise exception 'ride_not_found' using errcode = 'P0002';
end;
$$;

create or replace function public.rate_ride(
  p_ride_id uuid,
  p_stars smallint,
  p_tags text[] default '{}',
  p_comment text default null,
  p_tip_amount integer default 0
)
returns public.ratings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_role public.app_role := public.current_app_role();
  r public.rides;
  v_ratee uuid;
  v_row public.ratings;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  select * into r from public.rides where id = p_ride_id;
  if not found or r.status <> 'completed' then
    raise exception 'ride_not_rateable' using errcode = 'P0001';
  end if;

  if v_role = 'rider' and r.rider_id = v_uid then
    v_ratee := r.driver_id;
  elsif v_role = 'driver' and r.driver_id = v_uid then
    v_ratee := r.rider_id;
    p_tip_amount := 0; -- tips only go rider -> driver
  else
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;

  insert into public.ratings (ride_id, rater_id, ratee_id, rater_role, stars, tags, comment, tip_amount)
  values (p_ride_id, v_uid, v_ratee, v_role, p_stars, coalesce(p_tags, '{}'), left(p_comment, 500), coalesce(p_tip_amount, 0))
  returning * into v_row;

  update public.profiles set
    rating = s.avg_stars,
    rating_count = s.total
  from (
    select round(avg(stars)::numeric, 1) as avg_stars,
           (select count(*) from public.ratings where ratee_id = v_ratee)::integer as total
    from (select stars from public.ratings where ratee_id = v_ratee order by created_at desc limit 100) last100
  ) s
  where id = v_ratee;

  return v_row;
end;
$$;

create or replace function public.create_trip_share(p_ride_id uuid)
returns public.trip_shares
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_hours integer := coalesce((select (value)::integer from public.app_config where key = 'trip_share_hours'), 4);
  v_row public.trip_shares;
begin
  if not (public.is_ride_rider(p_ride_id) or public.is_ride_driver(p_ride_id)) then
    raise exception 'ride_not_found' using errcode = 'P0002';
  end if;
  insert into public.trip_shares (ride_id, created_by, expires_at)
  values (p_ride_id, v_uid, now() + make_interval(hours => v_hours))
  returning * into v_row;
  return v_row;
end;
$$;

create or replace function public.raise_safety_alert(
  p_ride_id uuid,
  p_lat double precision default null,
  p_lng double precision default null,
  p_reason text default null,
  p_note text default null
)
returns public.safety_alerts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('rider');
  r public.rides;
  v_row public.safety_alerts;
begin
  if p_ride_id is not null then
    select * into r from public.rides where id = p_ride_id and rider_id = v_uid;
    if not found then
      raise exception 'ride_not_found' using errcode = 'P0002';
    end if;
  end if;

  insert into public.safety_alerts (
    ride_id, raised_by, rider_id, driver_id, vehicle_id, location, reason, note, snapshot
  ) values (
    p_ride_id, v_uid, v_uid, r.driver_id, r.vehicle_id,
    case when p_lat is not null and p_lng is not null then public.make_point(p_lat, p_lng) end,
    left(p_reason, 80), left(p_note, 1000),
    jsonb_build_object(
      'ride_status', r.status,
      'pickup_address', r.pickup_address,
      'dropoff_address', r.dropoff_address,
      'driver', (select jsonb_build_object('name', full_name, 'phone', phone) from public.profiles where id = r.driver_id),
      'vehicle', (select jsonb_build_object('plate', plate, 'make', make, 'model', model, 'color', color)
                  from public.vehicles where id = r.vehicle_id)
    )
  )
  returning * into v_row;
  return v_row;
end;
$$;

create or replace function public.report_incident(
  p_category text,
  p_description text default null,
  p_ride_id uuid default null,
  p_rental_booking_id uuid default null,
  p_lat double precision default null,
  p_lng double precision default null,
  p_is_urgent boolean default false
)
returns public.incident_reports
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.require_role('driver');
  r public.rides;
  v_row public.incident_reports;
begin
  if p_ride_id is not null then
    select * into r from public.rides where id = p_ride_id and driver_id = v_uid;
    if not found then
      raise exception 'ride_not_found' using errcode = 'P0002';
    end if;
  end if;
  if p_rental_booking_id is not null and not exists (
    select 1 from public.rental_bookings where id = p_rental_booking_id and assigned_driver_id = v_uid
  ) then
    raise exception 'booking_not_found' using errcode = 'P0002';
  end if;

  insert into public.incident_reports (
    ride_id, rental_booking_id, reported_by, rider_id, driver_id, vehicle_id, location,
    category, description, is_urgent, snapshot
  ) values (
    p_ride_id, p_rental_booking_id, v_uid, r.rider_id, v_uid, r.vehicle_id,
    case when p_lat is not null and p_lng is not null then public.make_point(p_lat, p_lng) end,
    left(p_category, 80), left(p_description, 2000), coalesce(p_is_urgent, false),
    jsonb_build_object(
      'ride_status', r.status,
      'pickup_address', r.pickup_address,
      'rider_first_name', (select split_part(full_name, ' ', 1) from public.profiles where id = r.rider_id)
    )
  )
  returning * into v_row;
  return v_row;
end;
$$;

-- ---------------------------------------------------------------------------
-- Rentals (rider)
-- ---------------------------------------------------------------------------

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
  p_return_address text default null
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

  begin
    insert into public.rental_bookings (
      rider_id, vehicle_id, starts_at, ends_at, pickup_type,
      pickup_address, pickup_location, airport_code, terminal, flight_number, flight_arrival_at, grace_minutes,
      return_address, days, daily_rate, rental_amount, airport_fee, deposit_amount, total_amount, km_allowance,
      payment_method, payment_method_id
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
      coalesce(a.pickup_fee, 0), v.deposit_amount,
      v.daily_rate * v_days + coalesce(a.pickup_fee, 0),
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

-- ---------------------------------------------------------------------------
-- Server RPCs (Edge Functions with the service role)
-- ---------------------------------------------------------------------------

create or replace function public.server_transition_ride(
  p_ride_id uuid,
  p_to public.ride_status,
  p_metadata jsonb default '{}'
)
returns public.rides
language sql
security definer
set search_path = ''
as $$
  select public._transition_ride(p_ride_id, p_to, 'server', null, p_metadata);
$$;

/** Online, approved, idle drivers of the ride's category within p_radius_m of pickup, nearest first. */
create or replace function public.find_candidate_drivers(p_ride_id uuid, p_radius_m integer, p_limit integer default 10)
returns table (driver_id uuid, vehicle_id uuid, distance_m integer, lat double precision, lng double precision)
language sql
stable
security definer
set search_path = ''
as $$
  select l.driver_id, l.vehicle_id,
         extensions.st_distance(l.location, r.pickup_location)::integer as distance_m,
         extensions.st_y(l.location::extensions.geometry) as lat,
         extensions.st_x(l.location::extensions.geometry) as lng
  from public.rides r
  join public.driver_locations l
    on l.is_online
   and l.updated_at > now() - interval '60 seconds'
   and extensions.st_dwithin(l.location, r.pickup_location, p_radius_m)
  join public.vehicles v
    on v.id = l.vehicle_id and v.status = 'approved' and v.category_code = r.category_code
  join public.driver_profiles d on d.user_id = l.driver_id and d.verification_status = 'approved'
  join public.profiles p on p.id = l.driver_id and not p.is_blocked
  where r.id = p_ride_id
    and l.driver_id <> r.rider_id
    and not exists (select 1 from public.ride_offers o where o.ride_id = r.id and o.driver_id = l.driver_id)
    and not exists (select 1 from public.ride_offers o where o.driver_id = l.driver_id and o.status = 'pending')
    and not exists (
      select 1 from public.rides busy
      where busy.driver_id = l.driver_id
        and busy.status in ('driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress')
    )
  order by l.location operator(extensions.<->) r.pickup_location
  limit p_limit;
$$;

create or replace function public.create_ride_offer(
  p_ride_id uuid,
  p_driver_id uuid,
  p_search_radius_m integer,
  p_distance_m integer default null,
  p_eta_seconds integer default null
)
returns public.ride_offers
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_timeout integer := coalesce((select (value)::integer from public.app_config where key = 'offer_timeout_seconds'), 15);
  v_row public.ride_offers;
begin
  if (select status from public.rides where id = p_ride_id) <> 'searching' then
    raise exception 'ride_not_searching' using errcode = 'P0001';
  end if;
  update public.rides set search_radius_m = p_search_radius_m where id = p_ride_id;
  insert into public.ride_offers (ride_id, driver_id, search_radius_m, distance_m, eta_seconds, expires_at)
  values (p_ride_id, p_driver_id, p_search_radius_m, p_distance_m, p_eta_seconds,
          now() + make_interval(secs => v_timeout))
  returning * into v_row;
  return v_row;
end;
$$;

create or replace function public.expire_ride_offers()
returns integer
language sql
security definer
set search_path = ''
as $$
  with expired as (
    update public.ride_offers set status = 'expired', responded_at = now()
    where status = 'pending' and expires_at < now()
    returning 1
  )
  select count(*)::integer from expired;
$$;

/** Fixed-window rate limit for Edge Functions. Returns true when the request is allowed. */
create or replace function public.consume_rate_limit(
  p_user_id uuid,
  p_bucket text,
  p_limit integer,
  p_window_seconds integer
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_window timestamptz := to_timestamp(floor(extract(epoch from now()) / p_window_seconds) * p_window_seconds);
  v_count integer;
begin
  insert into public.api_rate_limits (user_id, bucket, window_start, request_count)
  values (p_user_id, p_bucket, v_window, 1)
  on conflict (user_id, bucket, window_start)
  do update set request_count = public.api_rate_limits.request_count + 1
  returning request_count into v_count;

  delete from public.api_rate_limits where window_start < now() - interval '1 day';
  return v_count <= p_limit;
end;
$$;

-- ---------------------------------------------------------------------------
-- Function privileges: nothing is callable unless granted here.
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public, anon, authenticated;

-- Used inside RLS policies.
grant execute on function
  public.current_app_role(),
  public.is_admin(),
  public.is_approved_driver(uuid),
  public.is_ride_rider(uuid),
  public.is_ride_driver(uuid),
  public.driver_can_see_ride(uuid),
  public.is_ride_chat_open(uuid)
to authenticated;

-- Client RPCs (each checks the caller's role).
grant execute on function
  public.request_ride(uuid, public.payment_method_type, uuid),
  public.cancel_ride_as_rider(uuid, text),
  public.set_driver_online(boolean, double precision, double precision),
  public.update_driver_location(double precision, double precision, real, real, real),
  public.respond_to_ride_offer(uuid, boolean),
  public.driver_update_ride_status(uuid, public.ride_status, text),
  public.verify_pickup_pin(uuid, text),
  public.submit_driver_application(),
  public.get_ride_counterpart(uuid),
  public.rate_ride(uuid, smallint, text[], text, integer),
  public.create_trip_share(uuid),
  public.raise_safety_alert(uuid, double precision, double precision, text, text),
  public.report_incident(text, text, uuid, uuid, double precision, double precision, boolean),
  public.create_rental_booking(
    uuid, timestamptz, timestamptz, public.rental_pickup_type, public.payment_method_type, uuid,
    text, double precision, double precision, text, text, text, timestamptz, text
  )
to authenticated;

-- Server-only.
grant execute on function
  public.compute_fare(text, text, integer, integer),
  public.server_transition_ride(uuid, public.ride_status, jsonb),
  public.find_candidate_drivers(uuid, integer, integer),
  public.create_ride_offer(uuid, uuid, integer, integer, integer),
  public.expire_ride_offers(),
  public.consume_rate_limit(uuid, text, integer, integer)
to service_role;
