-- iyodriver · admin dashboard live updates
-- The operations dashboard refreshes when the rider and driver apps change these tables.
-- postgres_changes respects RLS: only admins ("admins read all") see other people's rows.

do $$
declare
  t text;
begin
  foreach t in array array[
    'driver_profiles', 'driver_documents', 'rental_vehicles', 'payments', 'refunds'
  ] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
