-- iyodriver · 09 · reference data needed in every environment
--
-- !!! PLACEHOLDERS !!! Every price, fee, commission and emergency number below is a placeholder for
-- the owner to confirm. Rows carry is_placeholder = true until changed (edit the tables, no app release).

insert into public.cities (code, name, center) values
  ('douala', 'Douala', public.make_point(4.0511, 9.7679)),
  ('yaounde', 'Yaoundé', public.make_point(3.8480, 11.5021));

insert into public.ride_categories (code, name_en, name_fr, description_en, description_fr, seats, sort_order) values
  ('standard', 'Standard', 'Standard', 'Affordable everyday rides', 'Courses abordables au quotidien', 4, 1),
  ('comfort', 'Comfort', 'Confort', 'Newer cars, more legroom', 'Voitures récentes, plus d''espace', 4, 2),
  ('xl', 'XL', 'XL', 'Up to 6 passengers', 'Jusqu''à 6 passagers', 6, 3);

-- PLACEHOLDER fares (FCFA). Formula: max(minimum, base + per_km*km + per_min*min) * multiplier, rounded to 50.
insert into public.fare_config
  (city_code, category_code, base_fare, per_km, per_min, minimum_fare, category_multiplier, commission_rate, is_placeholder)
values
  ('douala', 'standard', 500, 150, 25, 1000, 1.00, 0.200, true),
  ('douala', 'comfort', 500, 150, 25, 1000, 1.35, 0.200, true),
  ('douala', 'xl', 500, 150, 25, 1000, 1.70, 0.200, true),
  ('yaounde', 'standard', 500, 150, 25, 1000, 1.00, 0.200, true),
  ('yaounde', 'comfort', 500, 150, 25, 1000, 1.35, 0.200, true),
  ('yaounde', 'xl', 500, 150, 25, 1000, 1.70, 0.200, true);

-- PLACEHOLDER airport pickup fees.
insert into public.airports (code, name, city_code, location, terminals, pickup_fee, is_placeholder) values
  ('DLA', 'Douala International Airport', 'douala', public.make_point(4.0061, 9.7195), array['Arrivals'], 5000, true),
  ('NSI', 'Yaoundé Nsimalen International Airport', 'yaounde', public.make_point(3.7226, 11.5533), array['Arrivals'], 5000, true);

insert into public.app_config (key, value, description, is_placeholder) values
  ('emergency_numbers',
   '[{"service": "police", "number": "117"}, {"service": "fire", "number": "118"}, {"service": "ambulance", "number": "119"}]',
   'Cameroon emergency numbers shown on safety screens (to verify).', true),
  ('support_phone', '"+237600000000"', 'iyodriver support line (placeholder).', true),
  ('offer_timeout_seconds', '15', 'Seconds a driver has to accept a ride offer.', false),
  ('matching_radii_m', '[2000, 5000, 8000]', 'Expanding search radii for match-ride.', false),
  ('driver_location_interval_s', '{"online": 5, "on_trip": 3}', 'How often the driver app sends its position.', false),
  ('pin_max_attempts', '5', 'Wrong pickup PIN attempts before lock + support alert.', false),
  ('chat_close_minutes', '60', 'Trip chat closes this long after the trip ends.', false),
  ('trip_share_hours', '4', 'Lifetime of a share-live-trip link.', false),
  ('trusted_contacts_max', '5', 'Maximum trusted contacts per rider.', false),
  ('fare_quote_ttl_minutes', '10', 'How long an upfront price stays valid.', false),
  ('airport_grace_minutes', '60', 'Free waiting time after the flight lands.', true),
  ('rental_min_days', '1', 'Minimum rental length in days.', true),
  ('required_driver_documents',
   '["national_id_front", "national_id_back", "driving_licence", "vehicle_registration", "insurance", "roadworthiness", "profile_photo"]',
   'Documents a driver must upload before submitting for review.', true),
  ('driver_store_urls',
   '{"ios": null, "android": null}',
   'Store links for the iyodriver Driver app (welcome screen "Want to drive?" link).', true);
