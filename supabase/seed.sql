-- iyodriver · local / staging seed data (NOT for production)
--
-- Test logins (phone OTP, local stack uses the fixed code 123456 from config.toml [auth.sms.test_otp]):
--   Riders   +237 671 23 45 67  Aïcha Ngo Mbappe     (MTN MoMo, saved places, trusted contact, 1 past ride)
--            +237 699 11 22 33  Christian Fotso
--            +237 655 44 33 22  Mireille Tchoumi
--   Drivers  +237 677 88 99 00  Jean-Paul Mbarga     approved · Douala · Standard · online (Akwa)
--            +237 690 11 22 44  Brice Nkoulou        approved · Douala · Comfort  · online (Bonapriso)
--            +237 651 99 88 77  Hervé Ndongo         approved · Yaoundé · XL      · online (Bastos)
--            +237 682 33 44 55  Patrick Essomba      pending (nothing uploaded yet)
--            +237 675 66 77 88  Sandrine Abena       action needed (insurance rejected)
--   Admin    +237 600 00 00 01  iyodriver Admin
-- Douala has no XL driver on purpose, to exercise the "no drivers available" path.

-- ---------------------------------------------------------------------------
-- Auth users (the on_auth_user_created trigger creates profiles / driver_profiles)
-- ---------------------------------------------------------------------------

create or replace function pg_temp.seed_user(
  p_id uuid, p_phone text, p_full_name text, p_role text, p_language text
) returns void
language plpgsql
as $$
begin
  insert into auth.users (
    instance_id, id, aud, role, phone, phone_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    encrypted_password, confirmation_token, recovery_token, email_change_token_new, email_change,
    email_change_token_current, phone_change, phone_change_token, reauthentication_token
  ) values (
    '00000000-0000-0000-0000-000000000000', p_id, 'authenticated', 'authenticated', p_phone, now(),
    '{"provider": "phone", "providers": ["phone"]}',
    jsonb_build_object('full_name', p_full_name, 'app_role', p_role, 'language', p_language),
    now(), now(),
    '', '', '', '', '', '', '', '', ''
  );
  insert into auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  values (
    p_id::text, p_id,
    jsonb_build_object('sub', p_id::text, 'phone', p_phone, 'phone_verified', true),
    'phone', now(), now(), now()
  );
end;
$$;

select pg_temp.seed_user('a0000000-0000-4000-8000-000000000001', '237671234567', 'Aïcha Ngo Mbappe', 'rider', 'fr');
select pg_temp.seed_user('a0000000-0000-4000-8000-000000000002', '237699112233', 'Christian Fotso', 'rider', 'en');
select pg_temp.seed_user('a0000000-0000-4000-8000-000000000003', '237655443322', 'Mireille Tchoumi', 'rider', 'fr');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000001', '237677889900', 'Jean-Paul Mbarga', 'driver', 'fr');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000002', '237690112244', 'Brice Nkoulou', 'driver', 'fr');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000003', '237651998877', 'Hervé Ndongo', 'driver', 'en');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000004', '237682334455', 'Patrick Essomba', 'driver', 'fr');
select pg_temp.seed_user('d0000000-0000-4000-8000-000000000005', '237675667788', 'Sandrine Abena', 'driver', 'fr');
select pg_temp.seed_user('c0000000-0000-4000-8000-000000000001', '237600000001', 'iyodriver Admin', 'rider', 'fr');

update public.profiles set role = 'admin' where id = 'c0000000-0000-4000-8000-000000000001';

update public.profiles set rating = 4.8, rating_count = 37 where id = 'a0000000-0000-4000-8000-000000000001';
update public.profiles set rating = 4.9, rating_count = 1248 where id = 'd0000000-0000-4000-8000-000000000001';
update public.profiles set rating = 4.7, rating_count = 412 where id = 'd0000000-0000-4000-8000-000000000002';
update public.profiles set rating = 4.9, rating_count = 230 where id = 'd0000000-0000-4000-8000-000000000003';

-- ---------------------------------------------------------------------------
-- Drivers: verification, documents, vehicles, live locations
-- ---------------------------------------------------------------------------

update public.driver_profiles d set
  verification_status = v.status::public.verification_status,
  city_code = v.city,
  licence_number = v.licence,
  licence_expiry = v.licence_expiry,
  national_id_number = v.nid,
  payout_method = v.payout_method::public.payment_method_type,
  payout_phone = v.payout_phone,
  submitted_at = case when v.status <> 'pending' then now() - interval '20 days' end,
  reviewed_at = case when v.status in ('approved', 'action_needed') then now() - interval '18 days' end,
  reviewed_by = case when v.status in ('approved', 'action_needed') then 'c0000000-0000-4000-8000-000000000001'::uuid end,
  approved_at = case when v.status = 'approved' then now() - interval '18 days' end,
  review_notes = v.notes
from (values
  ('d0000000-0000-4000-8000-000000000001'::uuid, 'approved', 'douala', 'LT-DL-204518', date '2029-03-31', '112233445', 'mtn_momo', '+237677889900', null),
  ('d0000000-0000-4000-8000-000000000002'::uuid, 'approved', 'douala', 'LT-DL-331902', date '2028-11-30', '223344556', 'orange_money', '+237690112244', null),
  ('d0000000-0000-4000-8000-000000000003'::uuid, 'approved', 'yaounde', 'CE-YD-118734', date '2030-06-30', '334455667', 'mtn_momo', '+237651998877', null),
  ('d0000000-0000-4000-8000-000000000004'::uuid, 'pending', null, null, null, null, null, null, null),
  ('d0000000-0000-4000-8000-000000000005'::uuid, 'action_needed', 'douala', 'LT-DL-552210', date '2027-08-31', '445566778', 'orange_money', '+237675667788',
   'Insurance certificate is expired. Please upload the current one.')
) as v(id, status, city, licence, licence_expiry, nid, payout_method, payout_phone, notes)
where d.user_id = v.id;

insert into public.driver_documents (driver_id, type, storage_path, mime_type, status, reviewed_at, reviewed_by, rejection_reason)
select d.id, t.type, d.id::text || '/' || t.type || '.jpg', 'image/jpeg',
       case when d.id = 'd0000000-0000-4000-8000-000000000005' and t.type = 'insurance' then 'rejected' else 'approved' end::public.review_status,
       now() - interval '18 days', 'c0000000-0000-4000-8000-000000000001',
       case when d.id = 'd0000000-0000-4000-8000-000000000005' and t.type = 'insurance' then 'Expired certificate' end
from (values
  ('d0000000-0000-4000-8000-000000000001'::uuid),
  ('d0000000-0000-4000-8000-000000000002'::uuid),
  ('d0000000-0000-4000-8000-000000000003'::uuid),
  ('d0000000-0000-4000-8000-000000000005'::uuid)
) d(id)
cross join unnest(enum_range(null::public.document_type)) t(type);

insert into public.vehicles (id, driver_id, category_code, make, model, year, color, plate, seats, status, is_active, reviewed_at, reviewed_by) values
  ('e0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001', 'standard', 'Toyota', 'Corolla', 2018, 'Blanc', 'LT 123 AB', 4, 'approved', true, now() - interval '18 days', 'c0000000-0000-4000-8000-000000000001'),
  ('e0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000002', 'comfort', 'Toyota', 'Camry', 2020, 'Gris', 'LT 456 CD', 4, 'approved', true, now() - interval '18 days', 'c0000000-0000-4000-8000-000000000001'),
  ('e0000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000003', 'xl', 'Toyota', 'Sienna', 2017, 'Noir', 'CE 789 EF', 6, 'approved', true, now() - interval '18 days', 'c0000000-0000-4000-8000-000000000001'),
  ('e0000000-0000-4000-8000-000000000005', 'd0000000-0000-4000-8000-000000000005', 'standard', 'Hyundai', 'Elantra', 2016, 'Bleu', 'LT 902 GH', 4, 'pending', false, null, null);

insert into public.driver_locations (driver_id, location, heading, is_online, vehicle_id, went_online_at, updated_at) values
  ('d0000000-0000-4000-8000-000000000001', public.make_point(4.0483, 9.7008), 90, true, 'e0000000-0000-4000-8000-000000000001', now() - interval '2 hours', now()),
  ('d0000000-0000-4000-8000-000000000002', public.make_point(4.0346, 9.6936), 180, true, 'e0000000-0000-4000-8000-000000000002', now() - interval '40 minutes', now()),
  ('d0000000-0000-4000-8000-000000000003', public.make_point(3.8930, 11.5130), 270, true, 'e0000000-0000-4000-8000-000000000003', now() - interval '1 hour', now());

-- ---------------------------------------------------------------------------
-- Rider data
-- ---------------------------------------------------------------------------

insert into public.payment_methods (id, user_id, type, label, phone, is_default) values
  ('f0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'mtn_momo', 'MTN MoMo', '+237671234567', true),
  ('f0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000002', 'orange_money', 'Orange Money', '+237699112233', true);

insert into public.saved_places (user_id, kind, label, address, location) values
  ('a0000000-0000-4000-8000-000000000001', 'home', 'Maison', 'Rue Njo-Njo, Bonapriso, Douala', public.make_point(4.0310, 9.6920)),
  ('a0000000-0000-4000-8000-000000000001', 'work', 'Bureau', 'Boulevard de la Liberté, Akwa, Douala', public.make_point(4.0475, 9.6990)),
  ('a0000000-0000-4000-8000-000000000001', 'other', 'Salle de sport', 'Carrefour Bonamoussadi, Douala', public.make_point(4.0940, 9.7400));

insert into public.trusted_contacts (user_id, name, phone) values
  ('a0000000-0000-4000-8000-000000000001', 'Grâce Ngo Mbappe', '+237670001122');

-- One completed ride in Aïcha's history (Bonapriso -> Akwa with Jean-Paul).
insert into public.rides (
  id, rider_id, driver_id, vehicle_id, city_code, category_code, status,
  pickup_location, pickup_address, dropoff_location, dropoff_address,
  distance_m, duration_s, fare_amount, commission_rate, payment_method, payment_method_id,
  requested_at, assigned_at, arriving_at, arrived_at, started_at, completed_at, ended_at
) values (
  '90000000-0000-4000-8000-000000000001',
  'a0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001', 'e0000000-0000-4000-8000-000000000001',
  'douala', 'standard', 'completed',
  public.make_point(4.0310, 9.6920), 'Rue Njo-Njo, Bonapriso, Douala',
  public.make_point(4.0475, 9.6990), 'Boulevard de la Liberté, Akwa, Douala',
  3400, 840, 1350, 0.200, 'mtn_momo', 'f0000000-0000-4000-8000-000000000001',
  now() - interval '2 days 1 hour', now() - interval '2 days 58 minutes', now() - interval '2 days 58 minutes',
  now() - interval '2 days 52 minutes', now() - interval '2 days 50 minutes', now() - interval '2 days 36 minutes',
  now() - interval '2 days 36 minutes'
);
insert into public.ride_pins (ride_id, pin, verified_at) values
  ('90000000-0000-4000-8000-000000000001', '4826', now() - interval '2 days 50 minutes');
insert into public.ride_events (ride_id, from_status, to_status, actor, actor_id, created_at) values
  ('90000000-0000-4000-8000-000000000001', null, 'requested', 'rider', 'a0000000-0000-4000-8000-000000000001', now() - interval '2 days 1 hour'),
  ('90000000-0000-4000-8000-000000000001', 'requested', 'searching', 'server', null, now() - interval '2 days 1 hour'),
  ('90000000-0000-4000-8000-000000000001', 'searching', 'driver_assigned', 'driver', 'd0000000-0000-4000-8000-000000000001', now() - interval '2 days 58 minutes'),
  ('90000000-0000-4000-8000-000000000001', 'driver_assigned', 'driver_arriving', 'driver', 'd0000000-0000-4000-8000-000000000001', now() - interval '2 days 58 minutes'),
  ('90000000-0000-4000-8000-000000000001', 'driver_arriving', 'driver_arrived', 'driver', 'd0000000-0000-4000-8000-000000000001', now() - interval '2 days 52 minutes'),
  ('90000000-0000-4000-8000-000000000001', 'driver_arrived', 'in_progress', 'driver', 'd0000000-0000-4000-8000-000000000001', now() - interval '2 days 50 minutes'),
  ('90000000-0000-4000-8000-000000000001', 'in_progress', 'completed', 'driver', 'd0000000-0000-4000-8000-000000000001', now() - interval '2 days 36 minutes');
insert into public.payments (payer_id, ride_id, purpose, method, amount, status, provider, provider_reference, confirmed_at) values
  ('a0000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 'ride_fare', 'mtn_momo', 1350, 'succeeded', 'mock', 'MOCK-SEED-0001', now() - interval '2 days 35 minutes');
insert into public.ratings (ride_id, rater_id, ratee_id, rater_role, stars, tags) values
  ('90000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001', 'rider', 5, array['clean_car', 'safe_driving']),
  ('90000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'driver', 5, '{}');

insert into public.driver_payouts (driver_id, amount, method, phone, period_start, period_end, status, provider_reference, paid_at) values
  ('d0000000-0000-4000-8000-000000000001', 84500, 'mtn_momo', '+237677889900', current_date - 14, current_date - 8, 'paid', 'MOCK-PAYOUT-0001', now() - interval '7 days');

-- ---------------------------------------------------------------------------
-- Rental fleet (PLACEHOLDER pricing)
-- ---------------------------------------------------------------------------

insert into public.rental_vehicles
  (city_code, make, model, year, category, transmission, seats, fuel_type, plate, color,
   daily_rate, deposit_amount, km_per_day, extra_km_rate, features, airport_pickup_available)
values
  ('douala', 'Toyota', 'Corolla', 2020, 'sedan', 'automatic', 5, 'petrol', 'LT 211 RB', 'Blanc', 25000, 100000, 200, 150, array['ac', 'bluetooth'], true),
  ('douala', 'Toyota', 'RAV4', 2021, 'suv', 'automatic', 5, 'petrol', 'LT 210 RA', 'Gris', 35000, 150000, 200, 200, array['ac', 'bluetooth', 'reverse_camera'], true),
  ('douala', 'Hyundai', 'Tucson', 2022, 'suv', 'automatic', 5, 'diesel', 'LT 212 RC', 'Noir', 40000, 150000, 200, 200, array['ac', 'carplay'], true),
  ('douala', 'Toyota', 'Land Cruiser Prado', 2019, 'suv', 'automatic', 7, 'diesel', 'LT 213 RD', 'Blanc', 60000, 250000, 250, 250, array['ac', '4x4'], true),
  ('yaounde', 'Suzuki', 'Swift', 2021, 'economy', 'manual', 5, 'petrol', 'CE 101 RA', 'Rouge', 20000, 80000, 150, 150, array['ac'], false),
  ('yaounde', 'Toyota', 'Hilux', 2020, 'pickup', 'manual', 5, 'diesel', 'CE 102 RB', 'Blanc', 45000, 200000, 200, 250, array['ac', '4x4'], true);
