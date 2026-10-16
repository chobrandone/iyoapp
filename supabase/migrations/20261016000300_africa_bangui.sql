-- iyodriver · Africa-wide phone numbers, Bangui launch city, 350 XAF base fare
--
-- !!! PLACEHOLDERS !!! Bangui's per-km, per-minute and minimum fares and the airport pickup fee
-- are placeholders for the owner to confirm (is_placeholder = true until changed).

-- ---------------------------------------------------------------------------
-- Phone numbers: any country in E.164 (the apps pick the country or detect it from the code)
-- ---------------------------------------------------------------------------

do $$
declare
  r record;
begin
  -- Drop every check that only allowed Cameroonian (+237) numbers.
  for r in
    select c.conrelid::regclass as tbl, c.conname
    from pg_constraint c
    join pg_namespace n on n.oid = c.connamespace
    where n.nspname = 'public' and c.contype = 'c' and pg_get_constraintdef(c.oid) like '%+237%'
  loop
    execute format('alter table %s drop constraint %I', r.tbl, r.conname);
  end loop;
end $$;

-- "+" then 8 to 15 digits, no leading zero in the country code (E.164).
alter table public.profiles
  add constraint profiles_phone_e164 check (phone ~ '^\+[1-9][0-9]{7,14}$');
alter table public.driver_profiles
  add constraint driver_profiles_payout_phone_e164 check (payout_phone ~ '^\+[1-9][0-9]{7,14}$');
alter table public.payment_methods
  add constraint payment_methods_phone_e164 check (phone ~ '^\+[1-9][0-9]{7,14}$');
alter table public.driver_payouts
  add constraint driver_payouts_phone_e164 check (phone ~ '^\+[1-9][0-9]{7,14}$');
alter table public.trusted_contacts
  add constraint trusted_contacts_phone_e164 check (phone ~ '^\+[1-9][0-9]{7,14}$');

-- ---------------------------------------------------------------------------
-- Bangui (Central African Republic), the launch city
-- ---------------------------------------------------------------------------

insert into public.cities (code, name, country_code, timezone, center) values
  ('bangui', 'Bangui', 'CF', 'Africa/Bangui', public.make_point(4.3733, 18.5628))
on conflict (code) do nothing;

-- Fares follow the Uber / Yango model:
--   max(minimum_fare, base 350 + per_km × km + per_min × min) × category multiplier, to 50 XAF.
insert into public.fare_config
  (city_code, category_code, base_fare, per_km, per_min, minimum_fare, category_multiplier, commission_rate, is_placeholder)
values
  ('bangui', 'standard', 350, 120, 15, 600, 1.00, 0.200, true),
  ('bangui', 'comfort', 350, 120, 15, 600, 1.35, 0.200, true),
  ('bangui', 'xl', 350, 120, 15, 600, 1.70, 0.200, true);

-- Every city starts from the same 350 XAF base.
update public.fare_config set base_fare = 350, updated_at = now() where base_fare <> 350;

insert into public.airports (code, name, city_code, location, terminals, pickup_fee, is_placeholder) values
  ('BGF', 'Bangui M''Poko International Airport', 'bangui', public.make_point(4.3985, 18.5188), array['Arrivals'], 5000, true)
on conflict (code) do nothing;
