-- iyodriver · tighten what later migrations left open (Supabase's default privileges apply to
-- everything created after the blanket revokes in 06 and 07).

-- Trigger bodies and the internal admin guard are never called by clients.
revoke execute on function
  public.on_rental_booking_created(),
  public.on_rental_booking_pin(),
  public._require_admin()
from public, anon, authenticated;

-- These tables are read-only for apps: writes go through SECURITY DEFINER functions.
revoke all on public.rental_handover_pins, public.refunds, public.safety_case_events from anon, authenticated;
grant select on public.rental_handover_pins, public.refunds, public.safety_case_events to authenticated;

-- The handover PIN comes from a CSPRNG, like the ride pickup PIN.
create or replace function public.on_rental_booking_pin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.rental_handover_pins (booking_id, pin)
  values (
    new.id,
    lpad(((('x' || encode(extensions.gen_random_bytes(4), 'hex'))::bit(32)::bigint) % 10000)::text, 4, '0')
  );
  return new;
end;
$$;
revoke execute on function public.on_rental_booking_pin() from public, anon, authenticated;
