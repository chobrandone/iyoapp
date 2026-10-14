# iyodriver backend (Supabase)

One Supabase project serves both apps. Everything here is source-controlled: schema and RLS in
`migrations/`, test data in `seed.sql`, server logic in `functions/`, local stack settings in `config.toml`.

## Layout

| Path                                           | What it holds                                                                                                                                                                                 |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `migrations/…0100_extensions_and_types.sql`    | PostGIS, btree_gist, pgcrypto; every enum (ride status, roles, payments…)                                                                                                                     |
| `migrations/…0200_config_and_people.sql`       | cities, ride categories, `app_config`, `fare_config`, airports, `profiles`, `driver_profiles`, `driver_documents`, `vehicles`, `driver_locations`, push tokens, role helpers, sign-up trigger |
| `migrations/…0300_rides.sql`                   | `fare_quotes`, `rides`, `ride_events`, `ride_status_transitions`, `ride_pins`, `ride_offers`, `ratings`, `messages`, `trip_shares`                                                            |
| `migrations/…0400_payments_safety_support.sql` | payment methods, payments, driver payouts, saved places, trusted contacts, notifications, safety alerts, incident reports, support, rate limits, route cache                                  |
| `migrations/…0500_rentals.sql`                 | rental fleet, bookings (no-overlap exclusion constraint), handover / return inspections                                                                                                       |
| `migrations/…0600_rls.sql`                     | grants + RLS policies for every table                                                                                                                                                         |
| `migrations/…0700_ride_rpcs.sql`               | server-authoritative RPCs (state machine, PIN, offers, ratings, safety, rentals)                                                                                                              |
| `migrations/…0800_storage_realtime.sql`        | Storage buckets + policies, Realtime publication                                                                                                                                              |
| `migrations/…0900_reference_data.sql`          | cities, categories, **placeholder** fares/fees, `app_config` defaults                                                                                                                         |
| `seed.sql`                                     | test riders, drivers (approved / pending / action needed), admin, vehicles, live positions, rental fleet, one past ride                                                                       |
| `functions/`                                   | Edge Functions (Deno), see below                                                                                                                                                              |

## Security model

- **Roles.** `profiles.role` is `rider`, `driver` or `admin`, set once at sign-up from
  `options.data.app_role` (anything but `driver` becomes `rider`; admins are only made by hand).
  Every RPC and Edge Function checks it (`require_role()` / `requireCaller()`), so a driver can't call
  rider RPCs and vice versa.
- **Writes.** Apps write directly only where a column-level grant + RLS policy allows it (own profile
  fields, saved places, trusted contacts, documents, unapproved vehicles, chat, push tokens…).
  Rides, offers, PINs, ratings, payments, alerts and bookings change only through RPCs or the service role.
- **Rides.** A driver sees a ride only while it is offered to them or assigned to them. Rider details
  come from `get_ride_counterpart()`: first name + rating while offered, phone once assigned, full name
  once the trip starts. The pickup PIN lives in `ride_pins`, which drivers can't read.
- **Status changes** all go through `_transition_ride()`, which checks `ride_status_transitions`
  (mirrors `RIDE_TRANSITIONS` in `@iyodriver/core`) and writes `ride_events`.
- **Config.** `fare_config` and `app_config` are read-only for apps. Values marked `is_placeholder = true`
  still need a business decision.
- **Storage.** `driver-documents` and `inspection-photos` are private (owner / booking parties / admins);
  `avatars` and `rental-vehicle-images` are public-read.
- **Admin.** An `admins read all` policy exists on every table for the future dashboard; admin writes
  will be added as RPCs with that app.

## Edge Functions

| Function              | Who                       | What                                                                                             |
| --------------------- | ------------------------- | ------------------------------------------------------------------------------------------------ |
| `places-autocomplete` | rider, driver             | Places (New) autocomplete, Cameroon only, session tokens, 60/min                                 |
| `place-details`       | rider, driver             | Place Details (ends the session), 60/min                                                         |
| `compute-route`       | rider, driver             | Routes API polyline / distance / duration, cached 5 min, 30/min                                  |
| `estimate-fares`      | rider                     | Route + `compute_fare()` for each category, stored as `fare_quotes` (10 min)                     |
| `match-ride`          | rider (own ride), service | Offers the ride to one driver at a time, 2 → 5 → 8 km, ETA-ranked; `no_drivers_found` at the end |
| `payments`            | rider                     | Starts collecting a pending payment through the provider                                         |
| `payment-webhook`     | provider (no JWT)         | Only place a payment / payout becomes final; HMAC-verified                                       |
| `safety-notify`       | rider                     | SMS to trusted contacts with a share-trip link after `raise_safety_alert()`                      |
| `shared-trip`         | public (no JWT)           | Live position for a valid share token                                                            |

Payment and SMS providers are interfaces with **mock** implementations
(`functions/_shared/payments.ts`, `functions/_shared/sms.ts`). Choosing the real Cameroon providers is
an open decision.

**Mock payment confirmation** (local): POST the webhook with an HMAC of the exact body:

```bash
BODY='{"reference":"MOCK-<payment id>","status":"succeeded"}'
SIG=$(printf '%s' "$BODY" | openssl dgst -sha256 -hmac "$PAYMENT_PROVIDER_SECRET" -hex | sed 's/.* //')
curl -X POST http://127.0.0.1:54321/functions/v1/payment-webhook -H "x-mock-signature: $SIG" -d "$BODY"
```

## Testing without Docker

```bash
npm run db:check   # migrations + seed in PGlite (Postgres + PostGIS in-process), then RLS / RPC / lifecycle checks
npm run db:types   # regenerate DB types for @iyodriver/core and the Edge Functions
```

`scripts/db/supabase-stub.sql` stands in for Supabase's `auth` / `storage` schemas and roles. It is
only for these checks; never apply it to a real project.

## Running the real stack

Local (needs Docker):

```bash
npx supabase start                 # applies migrations + seed.sql, phone OTP 123456 for seed users
npx supabase functions serve --env-file supabase/.env
```

Hosted project:

```bash
npx supabase link --project-ref <ref>
npx supabase db push               # migrations only; never run seed.sql on production
npx supabase secrets set --env-file supabase/.env
npx supabase functions deploy
npx supabase gen types typescript --project-id <ref> > packages/core/src/supabase/database.types.ts
```

Also on the hosted project: enable the **Phone** provider with an SMS provider for OTPs (Auth →
Providers), and keep email sign-ups off.
