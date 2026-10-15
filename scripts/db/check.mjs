// npm run db:check — applies migrations + seed to an in-memory Postgres and exercises
// RLS, role checks and the ride lifecycle as real users would through PostgREST.
import assert from 'node:assert/strict';

import { RIDE_STATUSES, RIDE_TRANSITIONS } from '../../packages/core/src/rides/status.ts';
import { createDb } from './load.mjs';

const U = {
  aicha: 'a0000000-0000-4000-8000-000000000001',
  christian: 'a0000000-0000-4000-8000-000000000002',
  mireille: 'a0000000-0000-4000-8000-000000000003',
  jeanPaul: 'd0000000-0000-4000-8000-000000000001',
  brice: 'd0000000-0000-4000-8000-000000000002',
  herve: 'd0000000-0000-4000-8000-000000000003',
  patrick: 'd0000000-0000-4000-8000-000000000004',
  admin: 'c0000000-0000-4000-8000-000000000001',
};

const { db } = await createDb();

/** Run SQL as a signed-in user (role authenticated + JWT sub), like a PostgREST request. */
async function as(userId, sql, params = []) {
  return db.transaction(async (tx) => {
    if (userId === 'service') {
      // Edge Functions call with the service key: JWT role claim = service_role.
      await tx.query(`select set_config('request.jwt.claims', $1, true)`, [
        JSON.stringify({ role: 'service_role' }),
      ]);
      await tx.exec(`set local role service_role`);
    } else if (userId === 'anon') {
      await tx.exec(`set local role anon`);
    } else {
      await tx.query(`select set_config('request.jwt.claims', $1, true)`, [
        JSON.stringify({ sub: userId, role: 'authenticated' }),
      ]);
      await tx.exec(`set local role authenticated`);
    }
    return (await tx.query(sql, params)).rows;
  });
}

async function rejects(userId, sql, params, pattern) {
  await assert.rejects(() => as(userId, sql, params), pattern);
}

let passed = 0;
async function test(name, fn) {
  try {
    await fn();
    passed += 1;
    console.log(`  ✓ ${name}`);
  } catch (error) {
    console.error(`  ✗ ${name}\n    ${error.message}`);
    process.exitCode = 1;
  }
}

console.log('Contract with @iyodriver/core');

await test('ride_status enum matches RIDE_STATUSES', async () => {
  const rows = await db.query(`select unnest(enum_range(null::public.ride_status))::text as s`);
  assert.deepEqual(
    rows.rows.map((r) => r.s),
    [...RIDE_STATUSES],
  );
});

await test('ride_status_transitions matches RIDE_TRANSITIONS', async () => {
  const rows = await db.query(
    `select from_status::text f, to_status::text t, actor::text a from public.ride_status_transitions`,
  );
  const db_ = rows.rows.map((r) => `${r.f}>${r.t}:${r.a}`).sort();
  const ts = Object.entries(RIDE_TRANSITIONS)
    .flatMap(([from, list]) => list.map((x) => `${from}>${x.to}:${x.actor}`))
    .sort();
  assert.deepEqual(db_, ts);
});

console.log('RLS and grants');

await test('every public table has RLS enabled', async () => {
  const rows = await db.query(
    `select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity`,
  );
  assert.deepEqual(rows.rows, []);
});

await test('anon reads app_config but no profiles', async () => {
  const cfg = await as('anon', `select key from public.app_config where key = 'emergency_numbers'`);
  assert.equal(cfg.length, 1);
  await rejects('anon', `select * from public.profiles`, [], /permission denied/);
});

await test('generated lat/lng columns mirror the geography points', async () => {
  const [r] = await as(U.aicha, `select pickup_lat, pickup_lng from public.rides limit 1`);
  assert.deepEqual(r, { pickup_lat: 4.031, pickup_lng: 9.692 });
});

await test('a rider sees only their own profile and rides', async () => {
  assert.equal((await as(U.aicha, `select id from public.profiles`)).length, 1);
  assert.equal((await as(U.christian, `select id from public.rides`)).length, 0);
  assert.equal((await as(U.aicha, `select id from public.rides`)).length, 1);
});

await test('users cannot change their own role', async () => {
  await rejects(
    U.aicha,
    `update public.profiles set role = 'admin' where id = $1`,
    [U.aicha],
    /permission denied/,
  );
});

await test('card tokens are not readable', async () => {
  await rejects(
    U.aicha,
    `select provider_token from public.payment_methods`,
    [],
    /permission denied/,
  );
});

await test('fare_config is read-only for apps', async () => {
  await rejects(U.aicha, `update public.fare_config set base_fare = 0`, [], /permission denied/);
});

await test('admin reads every profile', async () => {
  assert.ok((await as(U.admin, `select id from public.profiles`)).length >= 9);
});

await test('server-only RPCs are not callable by apps', async () => {
  await rejects(
    U.aicha,
    `select public.compute_fare('douala','standard',1000,60)`,
    [],
    /permission denied/,
  );
  await rejects(U.jeanPaul, `select public.expire_ride_offers()`, [], /permission denied/);
});

console.log('Pricing');

await test('Douala Standard 3.4 km / 14 min = 1 350 FCFA (placeholder config)', async () => {
  const [r] = await as('service', `select public.compute_fare('douala','standard',3400,840) as q`);
  assert.equal(r.q.fare_amount, 1350);
  assert.equal(r.q.driver_earnings, 1080);
});

await test('minimum fare applies and Comfort multiplier rounds to 50', async () => {
  const [r] = await as('service', `select public.compute_fare('douala','comfort',500,60) as q`);
  assert.equal(r.q.fare_amount, 1350); // max(1000, 500+75+25) * 1.35 = 1350
});

console.log('Ride lifecycle');

async function quoteFor(riderId, category = 'standard', city = 'douala', pickup = [4.0475, 9.699]) {
  const [q] = await as(
    'service',
    `insert into public.fare_quotes (rider_id, city_code, category_code, pickup_location, pickup_address,
       dropoff_location, dropoff_address, distance_m, duration_s, fare_amount, commission_rate)
     values ($1, $2, $3, public.make_point($4, $5), 'Akwa, Douala', public.make_point(4.0310, 9.6920),
       'Bonapriso, Douala', 3400, 840, 1350, 0.2)
     returning id`,
    [riderId, city, category, pickup[0], pickup[1]],
  );
  return q.id;
}

let rideId;
let offerId;

await test('drivers cannot call rider RPCs', async () => {
  const q = await quoteFor(U.christian);
  await rejects(U.jeanPaul, `select public.request_ride($1, 'cash')`, [q], /wrong_role/);
});

await test('rider requests a ride from a quote, PIN created', async () => {
  const q = await quoteFor(U.christian);
  const [r] = await as(U.christian, `select * from public.request_ride($1, 'cash')`, [q]);
  rideId = r.id;
  assert.equal(r.status, 'requested');
  assert.equal(r.fare_amount, 1350);
  await rejects(U.christian, `select public.request_ride($1, 'cash')`, [q], /quote_already_used/);
  const [pin] = await as(U.christian, `select pin from public.ride_pins where ride_id = $1`, [
    rideId,
  ]);
  assert.match(pin.pin, /^\d{4}$/);
});

await test('server moves to searching and finds the nearest Standard driver', async () => {
  await as('service', `select public.server_transition_ride($1, 'searching')`, [rideId]);
  const c = await as('service', `select * from public.find_candidate_drivers($1, 2000)`, [rideId]);
  assert.deepEqual(
    c.map((x) => x.driver_id),
    [U.jeanPaul],
  ); // Brice drives Comfort
  const [o] = await as('service', `select * from public.create_ride_offer($1, $2, 2000, $3)`, [
    rideId,
    U.jeanPaul,
    c[0].distance_m,
  ]);
  offerId = o.id;
});

await test('offered driver sees the ride and only the rider first name', async () => {
  assert.equal(
    (await as(U.jeanPaul, `select id from public.rides where id = $1`, [rideId])).length,
    1,
  );
  assert.equal(
    (await as(U.brice, `select id from public.rides where id = $1`, [rideId])).length,
    0,
  );
  const [{ c }] = await as(U.jeanPaul, `select public.get_ride_counterpart($1) c`, [rideId]);
  assert.equal(c.first_name, 'Christian');
  assert.equal(c.full_name, null);
  assert.equal(c.phone, null);
});

await test('riders cannot call driver RPCs', async () => {
  await rejects(
    U.christian,
    `select public.respond_to_ride_offer($1, true)`,
    [offerId],
    /wrong_role/,
  );
});

await test('driver accepts; rider sees driver, vehicle and live location', async () => {
  const [r] = await as(U.jeanPaul, `select * from public.respond_to_ride_offer($1, true)`, [
    offerId,
  ]);
  assert.equal(r.status, 'driver_assigned');
  const [{ c }] = await as(U.christian, `select public.get_ride_counterpart($1) c`, [rideId]);
  assert.equal(c.full_name, 'Jean-Paul Mbarga');
  assert.equal(c.vehicle.plate, 'LT 123 AB');
  assert.equal(
    (
      await as(U.christian, `select 1 from public.driver_locations where driver_id = $1`, [
        U.jeanPaul,
      ])
    ).length,
    1,
  );
  assert.equal(
    (await as(U.aicha, `select 1 from public.driver_locations where driver_id = $1`, [U.jeanPaul]))
      .length,
    0,
  );
});

await test('driver never sees the pickup PIN', async () => {
  assert.equal((await as(U.jeanPaul, `select * from public.ride_pins`)).length, 0);
});

await test('driver cannot skip the PIN to start the trip', async () => {
  await rejects(
    U.jeanPaul,
    `select public.driver_update_ride_status($1, 'in_progress')`,
    [rideId],
    /status_not_allowed_here/,
  );
});

await test('arriving -> arrived; wrong PIN counts, right PIN starts the trip', async () => {
  await as(U.jeanPaul, `select public.driver_update_ride_status($1, 'driver_arriving')`, [rideId]);
  await as(U.jeanPaul, `select public.driver_update_ride_status($1, 'driver_arrived')`, [rideId]);
  const [pin] = await as(U.christian, `select pin from public.ride_pins where ride_id = $1`, [
    rideId,
  ]);
  const wrong = pin.pin === '0000' ? '1111' : '0000';
  const [{ r: bad }] = await as(U.jeanPaul, `select public.verify_pickup_pin($1, $2) r`, [
    rideId,
    wrong,
  ]);
  assert.deepEqual(bad, { ok: false, locked: false, attempts_left: 4 });
  const [{ r: good }] = await as(U.jeanPaul, `select public.verify_pickup_pin($1, $2) r`, [
    rideId,
    pin.pin,
  ]);
  assert.equal(good.ok, true);
  const [ride] = await as(U.christian, `select status from public.rides where id = $1`, [rideId]);
  assert.equal(ride.status, 'in_progress');
});

await test('trip chat: parties can write, others cannot', async () => {
  await as(
    U.christian,
    `insert into public.messages (ride_id, sender_id, body) values ($1, $2, 'Je suis devant')`,
    [rideId, U.christian],
  );
  assert.equal(
    (await as(U.jeanPaul, `select body from public.messages where ride_id = $1`, [rideId])).length,
    1,
  );
  await rejects(
    U.aicha,
    `insert into public.messages (ride_id, sender_id, body) values ($1, $2, 'hi')`,
    [rideId, U.aicha],
    /row-level security/,
  );
});

await test('rider cannot cancel once the trip is in progress', async () => {
  await rejects(
    U.christian,
    `select public.cancel_ride_as_rider($1)`,
    [rideId],
    /invalid_transition/,
  );
});

await test('complete creates a payment; both sides rate; averages update', async () => {
  await as(U.jeanPaul, `select public.driver_update_ride_status($1, 'completed')`, [rideId]);
  const [p] = await as(
    U.christian,
    `select amount, status, method from public.payments where ride_id = $1`,
    [rideId],
  );
  assert.deepEqual(p, { amount: 1350, status: 'pending', method: 'cash' });
  await as(U.christian, `select public.rate_ride($1, 4::smallint)`, [rideId]);
  await as(U.jeanPaul, `select public.rate_ride($1, 5::smallint)`, [rideId]);
  await rejects(U.christian, `select public.rate_ride($1, 5::smallint)`, [rideId], /duplicate key/);
  const [d] = await as(
    'service',
    `select rating, rating_count from public.profiles where id = $1`,
    [U.jeanPaul],
  );
  assert.equal(d.rating_count, 2); // seed ride + this one
  assert.equal(Number(d.rating), 4.5);
  const events = await as(
    U.christian,
    `select to_status from public.ride_events where ride_id = $1`,
    [rideId],
  );
  assert.equal(events.length, 7);
});

await test('five wrong PINs lock the ride and alert support', async () => {
  const q = await quoteFor(U.mireille);
  const [r] = await as(U.mireille, `select * from public.request_ride($1, 'cash')`, [q]);
  await as('service', `select public.server_transition_ride($1, 'searching')`, [r.id]);
  const [o] = await as('service', `select * from public.create_ride_offer($1, $2, 2000)`, [
    r.id,
    U.jeanPaul,
  ]);
  await as(U.jeanPaul, `select public.respond_to_ride_offer($1, true)`, [o.id]);
  await as(U.jeanPaul, `select public.driver_update_ride_status($1, 'driver_arriving')`, [r.id]);
  await as(U.jeanPaul, `select public.driver_update_ride_status($1, 'driver_arrived')`, [r.id]);
  const [pin] = await as(U.mireille, `select pin from public.ride_pins where ride_id = $1`, [r.id]);
  const wrong = pin.pin === '0000' ? '1111' : '0000';
  let last;
  for (let i = 0; i < 5; i += 1) {
    [{ r: last }] = await as(U.jeanPaul, `select public.verify_pickup_pin($1, $2) r`, [
      r.id,
      wrong,
    ]);
  }
  assert.deepEqual(last, { ok: false, locked: true, attempts_left: 0 });
  const [{ r: after }] = await as(U.jeanPaul, `select public.verify_pickup_pin($1, $2) r`, [
    r.id,
    pin.pin,
  ]);
  assert.equal(after.ok, false);
  const inc = await as(U.admin, `select category from public.incident_reports where ride_id = $1`, [
    r.id,
  ]);
  assert.equal(inc[0].category, 'pickup_pin_locked');
  await as(
    U.jeanPaul,
    `select public.driver_update_ride_status($1, 'cancelled_by_driver', 'PIN locked')`,
    [r.id],
  );
});

await test('no XL drivers in Douala -> no_drivers_found', async () => {
  const q = await quoteFor(U.aicha, 'xl');
  const [r] = await as(U.aicha, `select * from public.request_ride($1, 'cash')`, [q]);
  await as('service', `select public.server_transition_ride($1, 'searching')`, [r.id]);
  const c = await as('service', `select * from public.find_candidate_drivers($1, 8000)`, [r.id]);
  assert.equal(c.length, 0);
  const [done] = await as(
    'service',
    `select status from public.server_transition_ride($1, 'no_drivers_found')`,
    [r.id],
  );
  assert.equal(done.status, 'no_drivers_found');
});

await test('one open ride per rider', async () => {
  const q1 = await quoteFor(U.aicha);
  const q2 = await quoteFor(U.aicha);
  await as(U.aicha, `select public.request_ride($1, 'cash')`, [q1]);
  await rejects(U.aicha, `select public.request_ride($1, 'cash')`, [q2], /rider_has_open_ride/);
});

console.log('Drivers');

await test('pending driver cannot go online', async () => {
  await rejects(
    U.patrick,
    `select public.set_driver_online(true, 4.05, 9.70)`,
    [],
    /driver_not_approved/,
  );
});

await test('pending driver cannot submit without documents', async () => {
  await as(
    U.patrick,
    `update public.driver_profiles set licence_number = 'X1', national_id_number = 'N1', city_code = 'douala'`,
  );
  await as(
    U.patrick,
    `insert into public.vehicles (driver_id, category_code, make, model, color, plate) values ($1, 'standard', 'Kia', 'Rio', 'Blanc', 'LT 777 ZZ')`,
    [U.patrick],
  );
  await rejects(U.patrick, `select public.submit_driver_application()`, [], /documents_missing/);
});

await test('approved driver identity fields are locked', async () => {
  await rejects(
    U.jeanPaul,
    `update public.driver_profiles set licence_number = 'NEW' where user_id = $1`,
    [U.jeanPaul],
    /driver_identity_locked/,
  );
  await as(
    U.jeanPaul,
    `update public.driver_profiles set payout_phone = '+237677000000' where user_id = $1`,
    [U.jeanPaul],
  );
});

await test('driver documents bucket is per-driver', async () => {
  await as(
    U.jeanPaul,
    `insert into storage.objects (bucket_id, name) values ('driver-documents', $1 || '/licence.jpg')`,
    [U.jeanPaul],
  );
  await rejects(
    U.jeanPaul,
    `insert into storage.objects (bucket_id, name) values ('driver-documents', $1 || '/licence.jpg')`,
    [U.brice],
    /row-level security/,
  );
  assert.equal(
    (await as(U.brice, `select 1 from storage.objects where bucket_id = 'driver-documents'`))
      .length,
    0,
  );
});

console.log('Rentals and safety');

await test('overlapping rental bookings are refused', async () => {
  const [v] = await as(U.aicha, `select id from public.rental_vehicles where plate = 'LT 210 RA'`);
  const book = (uid, from, to) =>
    as(
      uid,
      `select * from public.create_rental_booking($1, now() + $2::interval, now() + $3::interval, 'airport', 'cash',
         p_airport_code => 'DLA', p_flight_number => 'af 900', p_flight_arrival_at => now() + $2::interval)`,
      [v.id, from, to],
    );
  const [b] = await book(U.aicha, '3 days', '6 days');
  assert.equal(b.days, 3);
  assert.equal(b.total_amount, 3 * 35000 + 5000);
  assert.equal(b.flight_number, 'AF900');
  await assert.rejects(
    () => book(U.christian, '5 days', '8 days'),
    /vehicle_unavailable_for_dates/,
  );
  await book(U.christian, '6 days', '8 days'); // back-to-back is fine
});

await test('rental lifecycle: pay → assign → handover → active → return → deposit', async () => {
  const [v] = await as(
    U.aicha,
    `select id, deposit_amount from public.rental_vehicles where plate = 'LT 211 RB'`,
  );
  const [b] = await as(
    U.aicha,
    `select * from public.create_rental_booking($1, now() + interval '2 days', now() + interval '4 days', 'address', 'mtn_momo',
       p_payment_method_id => 'f0000000-0000-4000-8000-000000000001', p_pickup_address => 'Akwa, Douala')`,
    [v.id],
  );
  assert.equal(b.status, 'pending_payment');
  const [p] = await as(
    U.aicha,
    `select amount, status, purpose from public.payments where rental_booking_id = $1`,
    [b.id],
  );
  assert.deepEqual(p, { amount: b.total_amount, status: 'pending', purpose: 'rental' });

  // Payment confirmed by the webhook (service role), then the dashboard assigns a driver.
  await as('service', `update public.rental_bookings set status = 'confirmed' where id = $1`, [
    b.id,
  ]);
  await rejects(
    U.jeanPaul,
    `select public.assign_rental_driver($1, $2)`,
    [b.id, U.jeanPaul],
    /wrong_role/,
  );
  await as('service', `select public.assign_rental_driver($1, $2)`, [b.id, U.jeanPaul]);
  assert.equal(
    (await as(U.jeanPaul, `select id from public.rental_bookings where id = $1`, [b.id])).length,
    1,
  );
  assert.equal(
    (await as(U.brice, `select id from public.rental_bookings where id = $1`, [b.id])).length,
    0,
  );
  const [who] = await as(U.jeanPaul, `select public.get_rental_rider($1) as r`, [b.id]);
  assert.ok(who.r.name.length > 0);
  await rejects(U.brice, `select public.get_rental_rider($1)`, [b.id], /booking_not_found/);

  const photos = JSON.stringify({
    front: 'f.jpg',
    back: 'b.jpg',
    left: 'l.jpg',
    right: 'r.jpg',
    interior: 'i.jpg',
  });
  await rejects(
    U.jeanPaul,
    `select public.submit_rental_inspection($1, 'handover', 8::smallint, 41200, '{"front":"f.jpg"}'::jsonb)`,
    [b.id],
    /photos_missing/,
  );
  await as(
    U.jeanPaul,
    `select public.submit_rental_inspection($1, 'handover', 8::smallint, 41200, $2::jsonb)`,
    [b.id, photos],
  );
  await rejects(
    U.jeanPaul,
    `select public.confirm_rental_inspection($1, 'handover')`,
    [b.id],
    /wrong_role/,
  );
  const [active] = await as(
    U.aicha,
    `select * from public.confirm_rental_inspection($1, 'handover')`,
    [b.id],
  );
  assert.equal(active.status, 'active');
  assert.equal(active.deposit_status, 'held');

  await rejects(
    U.jeanPaul,
    `select public.submit_rental_inspection($1, 'return', 4::smallint, 41650, $2::jsonb, 'Scratch rear bumper', '{}'::jsonb, $3)`,
    [b.id, photos, v.deposit_amount + 1],
    /invalid_deposit_hold/,
  );
  await as(
    U.jeanPaul,
    `select public.submit_rental_inspection($1, 'return', 4::smallint, 41650, $2::jsonb, 'Scratch rear bumper', '{}'::jsonb, 20000)`,
    [b.id, photos],
  );
  const [done] = await as(U.aicha, `select * from public.confirm_rental_inspection($1, 'return')`, [
    b.id,
  ]);
  assert.equal(done.status, 'completed');
  assert.equal(done.deposit_status, 'partially_held');
  assert.equal(done.deposit_held_amount, 20000);
});

await test('cash rentals are confirmed at once; riders cancel before the start only', async () => {
  const [v] = await as(U.aicha, `select id from public.rental_vehicles where plate = 'LT 212 RC'`);
  const [b] = await as(
    U.christian,
    `select * from public.create_rental_booking($1, now() + interval '5 days', now() + interval '6 days', 'address', 'cash',
       p_pickup_address => 'Bonapriso, Douala')`,
    [v.id],
  );
  const [row] = await as(U.christian, `select status from public.rental_bookings where id = $1`, [
    b.id,
  ]);
  assert.equal(row.status, 'confirmed');
  await rejects(U.aicha, `select public.cancel_rental_booking($1)`, [b.id], /booking_not_found/);
  const [c] = await as(
    U.christian,
    `select * from public.cancel_rental_booking($1, 'plans changed')`,
    [b.id],
  );
  assert.equal(c.status, 'cancelled');
  await rejects(
    U.christian,
    `select public.cancel_rental_booking($1)`,
    [b.id],
    /booking_not_cancellable/,
  );
});

await test('trusted contacts are capped at 5', async () => {
  for (let i = 0; i < 4; i += 1) {
    await as(
      U.aicha,
      `insert into public.trusted_contacts (user_id, name, phone) values ($1, $2, $3)`,
      [U.aicha, `Contact ${i}`, `+23767000010${i}`],
    );
  }
  await rejects(
    U.aicha,
    `insert into public.trusted_contacts (user_id, name, phone) values ($1, 'Six', '+237670000199')`,
    [U.aicha],
    /trusted_contacts_limit_reached/,
  );
});

await test('rider safety alert snapshots the trip; drivers cannot raise rider alerts', async () => {
  const [ride] = await as(
    U.aicha,
    `select id from public.rides where status = 'completed' limit 1`,
  );
  const [a] = await as(
    U.aicha,
    `select * from public.raise_safety_alert($1, 4.05, 9.70, 'unsafe_driving')`,
    [ride.id],
  );
  assert.equal(a.snapshot.vehicle.plate, 'LT 123 AB');
  await rejects(U.jeanPaul, `select public.raise_safety_alert(null)`, [], /wrong_role/);
});

await test('trip share token is unguessable and owned', async () => {
  const [ride] = await as(
    U.aicha,
    `select id from public.rides where status = 'completed' limit 1`,
  );
  const [s] = await as(U.aicha, `select * from public.create_trip_share($1)`, [ride.id]);
  assert.match(s.token, /^[0-9a-f]{36}$/);
  await rejects(U.christian, `select public.create_trip_share($1)`, [ride.id], /ride_not_found/);
});

console.log(`\n${passed} checks passed${process.exitCode ? ', some FAILED' : ''}.`);
await db.close();
