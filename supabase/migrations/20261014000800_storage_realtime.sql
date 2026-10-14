-- iyodriver · 08 · storage buckets/policies and realtime publication

-- ---------------------------------------------------------------------------
-- Storage
--   driver-documents       private · "<driver_id>/<file>" · owner + admins
--   inspection-photos      private · "<booking_id>/<handover|return>/<side>.jpg" · booking parties + admins
--   avatars                public read · "<user_id>/<file>" · owner writes
--   rental-vehicle-images  public read · admin/service writes
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('driver-documents', 'driver-documents', false, 10485760, array['image/jpeg', 'image/png', 'image/heic', 'application/pdf']),
  ('inspection-photos', 'inspection-photos', false, 10485760, array['image/jpeg', 'image/png', 'image/heic']),
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('rental-vehicle-images', 'rental-vehicle-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy "drivers read own documents" on storage.objects
  for select to authenticated using (
    bucket_id = 'driver-documents'
    and ((storage.foldername(name))[1] = (select auth.uid())::text or (select public.is_admin()))
  );
create policy "drivers upload own documents" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'driver-documents'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select public.current_app_role()) = 'driver'
  );
create policy "drivers replace own documents" on storage.objects
  for update to authenticated
  using (bucket_id = 'driver-documents' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'driver-documents' and (storage.foldername(name))[1] = (select auth.uid())::text);

create or replace function public.is_rental_booking_party(p_booking_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.rental_bookings b
    where b.id::text = p_booking_id
      and (b.rider_id = (select auth.uid()) or b.assigned_driver_id = (select auth.uid()))
  );
$$;
create or replace function public.is_rental_booking_driver(p_booking_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.rental_bookings b
    where b.id::text = p_booking_id and b.assigned_driver_id = (select auth.uid())
  );
$$;
revoke execute on function public.is_rental_booking_party(text), public.is_rental_booking_driver(text)
  from public, anon;
grant execute on function public.is_rental_booking_party(text), public.is_rental_booking_driver(text)
  to authenticated;

create policy "booking parties read inspection photos" on storage.objects
  for select to authenticated using (
    bucket_id = 'inspection-photos'
    and (public.is_rental_booking_party((storage.foldername(name))[1]) or (select public.is_admin()))
  );
create policy "assigned drivers upload inspection photos" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'inspection-photos' and public.is_rental_booking_driver((storage.foldername(name))[1])
  );

create policy "users upload own avatar" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text
  );
create policy "users replace own avatar" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "users delete own avatar" on storage.objects
  for delete to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ---------------------------------------------------------------------------
-- Realtime (postgres_changes respects the RLS policies above)
-- ---------------------------------------------------------------------------

alter publication supabase_realtime add table
  public.rides,
  public.ride_offers,
  public.driver_locations,
  public.messages,
  public.notifications,
  public.safety_alerts,
  public.incident_reports,
  public.rental_bookings,
  public.support_messages;
