# iyodriver

Two independently installable React Native (Expo SDK 57) apps for ride-hailing and car rental in Cameroon / CEMAC, sharing one Supabase backend and one design system.

| App    | Folder        | Name on device   | Bundle ID / package    |
| ------ | ------------- | ---------------- | ---------------------- |
| Rider  | `apps/rider`  | iyodriver        | `com.iyodriver.rider`  |
| Driver | `apps/driver` | iyodriver Driver | `com.iyodriver.driver` |

## Layout

```
apps/rider     Expo app (routes in src/app, Expo Router)
apps/driver    Expo app (routes in src/app, Expo Router)
packages/ui    @iyodriver/ui   – theme tokens, Poppins, shared components
packages/core  @iyodriver/core – formatters (FCFA, Africa/Douala dates, +237 phones), zod schemas,
                                 ride status machine types, i18n (EN/FR)
packages/config @iyodriver/config – shared tsconfig + Prettier
supabase/      migrations, edge functions, seed (Phase 3)
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

## Scripts (root)

| Script                             | What it does                                           |
| ---------------------------------- | ------------------------------------------------------ |
| `npm run rider` / `npm run driver` | Start that app's dev server                            |
| `npm run typecheck`                | `tsc --noEmit` in every workspace                      |
| `npm run lint`                     | ESLint (eslint-config-expo + Prettier) across the repo |
| `npm run format`                   | Prettier write                                         |
| `npm run test`                     | Jest (added in Phase 13)                               |

## EAS

Each app has its own `eas.json` (`development`, `preview`, `production`). Run `npx eas-cli@latest init` inside each app folder once to create its own EAS project; it writes `extra.eas.projectId` into that app's config.
