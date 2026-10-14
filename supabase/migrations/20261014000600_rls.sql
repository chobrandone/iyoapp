-- iyodriver · 06 · grants and row level security
--
-- Model:
--   * anon: may read only public reference data (cities, categories, airports, app_config).
--   * authenticated: SELECT everywhere RLS allows; INSERT/UPDATE/DELETE only on the tables and
--     columns granted explicitly below. Everything else goes through SECURITY DEFINER RPCs.
--   * service_role (Edge Functions): bypasses RLS.
--   * admin: reads everything (future admin dashboard); admin writes will be RPCs.

-- ---------------------------------------------------------------------------
-- Table privileges
-- ---------------------------------------------------------------------------

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;

grant select on public.cities, public.ride_categories, public.airports, public.app_config to anon;
grant select on all tables in schema public to authenticated;
-- Server-only tables.
revoke select on public.api_rate_limits, public.route_cache from authenticated;

-- Card tokens are never readable by apps.
revoke select on public.payment_methods from authenticated;
grant select (id, user_id, type, label, phone, card_brand, card_last4, is_default, created_at)
  on public.payment_methods to authenticated;

-- Column-scoped client writes.
grant update (full_name, avatar_url, language) on public.profiles to authenticated;
grant update (city_code, licence_number, licence_expiry, national_id_number, payout_method, payout_phone)
  on public.driver_profiles to authenticated;
grant insert (driver_id, type, storage_path, mime_type, expires_on) on public.driver_documents to authenticated;
grant update (storage_path, mime_type, expires_on) on public.driver_documents to authenticated;
grant insert (driver_id, category_code, make, model, year, color, plate, seats) on public.vehicles to authenticated;
grant update (category_code, make, model, year, color, plate, seats) on public.vehicles to authenticated;
grant insert, update, delete on public.push_tokens to authenticated;
grant insert (user_id, type, label, phone, is_default) on public.payment_methods to authenticated;
grant update (label, is_default) on public.payment_methods to authenticated;
grant delete on public.payment_methods to authenticated;
grant insert, update, delete on public.saved_places to authenticated;
grant insert, update, delete on public.trusted_contacts to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant delete on public.notifications to authenticated;
grant insert (ride_id, sender_id, body) on public.messages to authenticated;
grant update (read_at) on public.messages to authenticated;
grant insert (user_id, ride_id, rental_booking_id, subject) on public.support_conversations to authenticated;
grant insert (conversation_id, sender_id, body) on public.support_messages to authenticated;

-- ---------------------------------------------------------------------------
-- Enable RLS on every table in public
-- ---------------------------------------------------------------------------

do $$
declare
  t record;
begin
  for t in select tablename from pg_tables where schemaname = 'public' loop
    execute format('alter table public.%I enable row level security', t.tablename);
  end loop;
end;
$$;

-- Admins can read every table except the server-only ones.
do $$
declare
  t record;
begin
  for t in
    select tablename from pg_tables
    where schemaname = 'public' and tablename not in ('api_rate_limits', 'route_cache')
  loop
    execute format(
      'create policy "admins read all" on public.%I for select to authenticated using ((select public.is_admin()))',
      t.tablename
    );
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Ride visibility helpers (SECURITY DEFINER so policies don't recurse through RLS)
-- ---------------------------------------------------------------------------

create or replace function public.is_ride_rider(p_ride_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.rides r where r.id = p_ride_id and r.rider_id = (select auth.uid()));
$$;

create or replace function public.is_ride_driver(p_ride_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.rides r where r.id = p_ride_id and r.driver_id = (select auth.uid()));
$$;

/** Driver sees a ride while it is offered to them (pending offer) or once it is assigned to them. */
create or replace function public.driver_can_see_ride(p_ride_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_ride_driver(p_ride_id)
    or exists (
      select 1 from public.ride_offers o
      where o.ride_id = p_ride_id and o.driver_id = (select auth.uid()) and o.status = 'pending'
    );
$$;

/** Chat is open while the ride has a driver and for chat_close_minutes (default 60) after it ends. */
create or replace function public.is_ride_chat_open(p_ride_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.rides r
    where r.id = p_ride_id
      and r.driver_id is not null
      and (
        r.ended_at is null
        or r.ended_at > now() - make_interval(
          mins => coalesce((select (value)::integer from public.app_config where key = 'chat_close_minutes'), 60)
        )
      )
  );
$$;

-- ---------------------------------------------------------------------------
-- Reference data
-- ---------------------------------------------------------------------------

create policy "everyone reads active cities" on public.cities for select to anon, authenticated using (is_active);
create policy "everyone reads active categories" on public.ride_categories
  for select to anon, authenticated using (is_active);
create policy "everyone reads active airports" on public.airports for select to anon, authenticated using (is_active);
create policy "everyone reads app config" on public.app_config for select to anon, authenticated using (true);
create policy "signed-in users read fare config" on public.fare_config
  for select to authenticated using (is_active);
create policy "signed-in users read transitions" on public.ride_status_transitions
  for select to authenticated using (true);

-- ---------------------------------------------------------------------------
-- People
-- ---------------------------------------------------------------------------

create policy "users read own profile" on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy "users update own profile" on public.profiles
  for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "drivers read own driver profile" on public.driver_profiles
  for select to authenticated using (user_id = (select auth.uid()));
create policy "drivers update own driver profile" on public.driver_profiles
  for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Identity fields are frozen while under review or once approved (payout details stay editable).
create or replace function public.guard_driver_profile_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) = old.user_id
    and old.verification_status in ('under_review', 'approved', 'suspended')
    and (
      new.licence_number is distinct from old.licence_number
      or new.licence_expiry is distinct from old.licence_expiry
      or new.national_id_number is distinct from old.national_id_number
      or new.city_code is distinct from old.city_code
    )
  then
    raise exception 'driver_identity_locked' using errcode = '42501';
  end if;
  return new;
end;
$$;
create trigger driver_profiles_guard before update on public.driver_profiles
  for each row execute function public.guard_driver_profile_update();

create policy "drivers read own documents" on public.driver_documents
  for select to authenticated using (driver_id = (select auth.uid()));
create policy "drivers add own documents" on public.driver_documents
  for insert to authenticated with check (driver_id = (select auth.uid()));
create policy "drivers replace own unapproved documents" on public.driver_documents
  for update to authenticated
  using (driver_id = (select auth.uid()) and status <> 'approved')
  with check (driver_id = (select auth.uid()));

-- Re-uploading a document sends it back for review.
create or replace function public.reset_document_review()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.storage_path is distinct from old.storage_path then
    new.status := 'pending';
    new.rejection_reason := null;
    new.reviewed_at := null;
    new.reviewed_by := null;
  end if;
  return new;
end;
$$;
create trigger driver_documents_reset_review before update on public.driver_documents
  for each row execute function public.reset_document_review();

create policy "drivers read own vehicles" on public.vehicles
  for select to authenticated using (driver_id = (select auth.uid()));
create policy "drivers add own vehicles" on public.vehicles
  for insert to authenticated
  with check (driver_id = (select auth.uid()) and (select public.current_app_role()) = 'driver');
create policy "drivers edit own unapproved vehicles" on public.vehicles
  for update to authenticated
  using (driver_id = (select auth.uid()) and status in ('pending', 'rejected'))
  with check (driver_id = (select auth.uid()));

create or replace function public.reset_vehicle_review()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.status = 'rejected' and (select auth.uid()) = old.driver_id then
    new.status := 'pending';
  end if;
  return new;
end;
$$;
create trigger vehicles_reset_review before update on public.vehicles
  for each row execute function public.reset_vehicle_review();

-- Riders see the live position of the driver assigned to their current ride only.
create policy "drivers read own location" on public.driver_locations
  for select to authenticated using (driver_id = (select auth.uid()));
create policy "riders read assigned driver location" on public.driver_locations
  for select to authenticated using (
    exists (
      select 1 from public.rides r
      where r.driver_id = driver_locations.driver_id
        and r.rider_id = (select auth.uid())
        and r.status in ('driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress')
    )
  );

create policy "users manage own push tokens" on public.push_tokens
  for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Rides
-- ---------------------------------------------------------------------------

create policy "riders read own quotes" on public.fare_quotes
  for select to authenticated using (rider_id = (select auth.uid()));

create policy "riders read own rides" on public.rides
  for select to authenticated using (rider_id = (select auth.uid()));
create policy "drivers read offered or assigned rides" on public.rides
  for select to authenticated using ((select public.driver_can_see_ride(id)));

create policy "parties read ride events" on public.ride_events
  for select to authenticated using (public.is_ride_rider(ride_id) or public.is_ride_driver(ride_id));

create policy "riders read own pickup pin" on public.ride_pins
  for select to authenticated using (public.is_ride_rider(ride_id));

create policy "drivers read own offers" on public.ride_offers
  for select to authenticated using (driver_id = (select auth.uid()));

create policy "users read ratings they gave" on public.ratings
  for select to authenticated using (rater_id = (select auth.uid()));

create policy "parties read trip chat" on public.messages
  for select to authenticated using (public.is_ride_rider(ride_id) or public.is_ride_driver(ride_id));
create policy "parties send while chat is open" on public.messages
  for insert to authenticated with check (
    sender_id = (select auth.uid())
    and (public.is_ride_rider(ride_id) or public.is_ride_driver(ride_id))
    and public.is_ride_chat_open(ride_id)
  );
create policy "recipients mark messages read" on public.messages
  for update to authenticated
  using (sender_id <> (select auth.uid()) and (public.is_ride_rider(ride_id) or public.is_ride_driver(ride_id)))
  with check (sender_id <> (select auth.uid()));

create policy "users read own trip shares" on public.trip_shares
  for select to authenticated using (created_by = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Payments
-- ---------------------------------------------------------------------------

create policy "users read own payment methods" on public.payment_methods
  for select to authenticated using (user_id = (select auth.uid()));
create policy "riders add mobile money methods" on public.payment_methods
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and type in ('mtn_momo', 'orange_money') -- cards are added by the payments Edge Function after tokenisation
    and (select public.current_app_role()) = 'rider'
  );
create policy "users update own payment methods" on public.payment_methods
  for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "users delete own payment methods" on public.payment_methods
  for delete to authenticated using (user_id = (select auth.uid()));

create policy "payers read own payments" on public.payments
  for select to authenticated using (payer_id = (select auth.uid()));
create policy "drivers read payments for their rides" on public.payments
  for select to authenticated using (ride_id is not null and public.is_ride_driver(ride_id));

create policy "drivers read own payouts" on public.driver_payouts
  for select to authenticated using (driver_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Rider personal data, notifications
-- ---------------------------------------------------------------------------

create policy "users manage own saved places" on public.saved_places
  for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "riders manage own trusted contacts" on public.trusted_contacts
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and (select public.current_app_role()) = 'rider');

create policy "users read own notifications" on public.notifications
  for select to authenticated using (user_id = (select auth.uid()));
create policy "users mark own notifications read" on public.notifications
  for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "users delete own notifications" on public.notifications
  for delete to authenticated using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Safety and support (created through RPCs; reporters can read their own)
-- ---------------------------------------------------------------------------

create policy "reporters read own safety alerts" on public.safety_alerts
  for select to authenticated using (raised_by = (select auth.uid()));
create policy "reporters read own incident reports" on public.incident_reports
  for select to authenticated using (reported_by = (select auth.uid()));

create policy "users read own support conversations" on public.support_conversations
  for select to authenticated using (user_id = (select auth.uid()));
create policy "users open support conversations" on public.support_conversations
  for insert to authenticated with check (user_id = (select auth.uid()));

create policy "users read own support messages" on public.support_messages
  for select to authenticated using (
    exists (
      select 1 from public.support_conversations c
      where c.id = conversation_id and c.user_id = (select auth.uid())
    )
  );
create policy "users write in own open conversations" on public.support_messages
  for insert to authenticated with check (
    sender_id = (select auth.uid())
    and exists (
      select 1 from public.support_conversations c
      where c.id = conversation_id and c.user_id = (select auth.uid()) and c.status <> 'closed'
    )
  );

-- ---------------------------------------------------------------------------
-- Rentals
-- ---------------------------------------------------------------------------

create policy "signed-in users browse available rental cars" on public.rental_vehicles
  for select to authenticated using (
    status = 'available'
    or exists (
      select 1 from public.rental_bookings b
      where b.vehicle_id = rental_vehicles.id
        and (b.rider_id = (select auth.uid()) or b.assigned_driver_id = (select auth.uid()))
    )
  );

create policy "riders read own rental bookings" on public.rental_bookings
  for select to authenticated using (rider_id = (select auth.uid()));
create policy "assigned drivers read rental bookings" on public.rental_bookings
  for select to authenticated using (assigned_driver_id = (select auth.uid()));

create policy "booking parties read inspections" on public.rental_inspections
  for select to authenticated using (
    exists (
      select 1 from public.rental_bookings b
      where b.id = booking_id
        and (b.rider_id = (select auth.uid()) or b.assigned_driver_id = (select auth.uid()))
    )
  );
