# iyodriver

Two independently installable React Native (Expo SDK 57) apps for ride-hailing and car rental in Cameroon / CEMAC, sharing one Supabase backend and one design system.

| App    | Folder        | Name on device   | Bundle ID / package    |
| ------ | ------------- | ---------------- | ---------------------- |
| Rider  | `apps/rider`  | iyodriver        | `com.iyodriver.rider`  |
| Driver | `apps/driver` | iyodriver Driver | `com.iyodriver.driver` |

The Flutter versions of both apps live in `flutter/`. The operations dashboard for staff is a web app in `apps/admin` (React + TypeScript, Vite).

## Layout

```
apps/rider     Expo app (routes in src/app, Expo Router)
apps/driver    Expo app (routes in src/app, Expo Router)
apps/admin     Operations dashboard (React, Vite, Tailwind, TanStack Query, MapLibre)
flutter/       Flutter rider and driver apps and their shared packages
packages/ui    @iyodriver/ui   – theme tokens, Poppins, shared components
packages/core  @iyodriver/core – typed Supabase client + generated DB types, formatters (FCFA,
                                 Africa/Douala dates, +237 phones), zod schemas, ride status machine, i18n (EN/FR)
packages/config @iyodriver/config – shared tsconfig + Prettier
supabase/      migrations, RLS, RPCs, Edge Functions, seed — see supabase/README.md
scripts/db/    db:check / db:types (PGlite, no Docker needed)
```

Apps never import from each other (enforced by ESLint); shared code lives only in `packages/`.

## Getting started

```bash
npm install            # from the repo root, installs every workspace
cp apps/rider/.env.example apps/rider/.env
cp apps/driver/.env.example apps/driver/.env
npm run rider          # Expo dev server for the rider app
npm run driver         # Expo dev server for the driver app
```

Early UI work runs in **Expo Go (SDK 57)**. Maps keys, background location and push notifications need development builds: `npx expo run:android` / `npx expo run:ios` inside each app, or `npx eas-cli@latest build --profile development`.

Add native libraries with `npx expo install <pkg>` **inside the app folder** so versions match the SDK.

## Connecting the apps

Rider, driver and the dashboard share data only through **one Supabase project**. Until one is configured, each app runs on its own built-in Douala demo data.

1. Create the Supabase project and apply `supabase/migrations` (see `supabase/README.md`), then deploy the Edge Functions.
2. Copy `flutter/config/dev.example.json` to `flutter/config/dev.json` and fill in `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (public values only). The Flutter apps read it with `--dart-define-from-file=config/dev.json`, and `npm run admin` reads the same file. To point the dashboard elsewhere, set `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` in `apps/admin/.env.local` instead.
3. Create a staff account in the Supabase dashboard (Authentication → Users, email and password), then make it an admin: `update public.profiles set role = 'admin' where id = '<user id>';`

The dashboard then shows rides, rentals, driver applications, safety alerts and payments from both apps, and refreshes live (Supabase Realtime) as riders and drivers act.

In the dashboard, the header search and the Live operations search take trip, booking and driver references, names, or a place: a place that matches no active trip centres the live map on it.

## Scripts (root)

| Script                             | What it does                                           |
| ---------------------------------- | ------------------------------------------------------ |
| `npm run rider` / `npm run driver` | Start that app's dev server                            |
| `npm run admin`                    | Start the operations dashboard (http://localhost:8084) |
| `npm run typecheck`                | `tsc --noEmit` in every workspace                      |
| `npm run lint`                     | ESLint (eslint-config-expo + Prettier) across the repo |
| `npm run format`                   | Prettier write                                         |
| `npm run test`                     | Jest (added in Phase 13)                               |
| `npm run db:check`                 | Apply migrations + seed in PGlite and test RLS / RPCs  |
| `npm run db:types`                 | Regenerate Supabase DB types from the migrations       |

## EAS

Each app has its own `eas.json` (`development`, `preview`, `production`). Run `npx eas-cli@latest init` inside each app folder once to create its own EAS project; it writes `extra.eas.projectId` into that app's config.
