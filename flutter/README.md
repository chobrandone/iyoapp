# iyodriver — Flutter apps

Two independently installable Flutter apps sharing one design system and one core library through a
[pub workspace](https://dart.dev/tools/pub/workspaces). The backend is the shared Supabase project
in [`../supabase`](../supabase/README.md).

| App    | Folder        | Name on device   | Bundle ID / package    |
| ------ | ------------- | ---------------- | ---------------------- |
| Rider  | `apps/rider`  | iyodriver        | `com.iyodriver.rider`  |
| Driver | `apps/driver` | iyodriver Driver | `com.iyodriver.driver` |

```
apps/rider        rider app (go_router, Riverpod, EN/FR ARB strings)
apps/driver       driver app
packages/iyo_ui   theme tokens (Figma), Poppins, shared widgets, map widgets, dev gallery
packages/iyo_core formatters (FCFA, Africa/Douala dates, +237 phones), validators, ride state
                  machine, DB enums generated from the migrations, Supabase setup, shared strings
config/           per-environment keys passed with --dart-define-from-file (gitignored)
```

Apps never import each other; shared code lives only in `packages/`.

## Requirements

Flutter 3.29+ (Dart 3.7+), Android SDK, and Xcode for iOS builds.

## Getting started

```bash
cd flutter
flutter pub get                       # resolves the whole workspace
cp config/dev.example.json config/dev.json   # fill in the keys you have
cd apps/rider
flutter run --dart-define-from-file=../../config/dev.json
```

Run the driver app the same way from `apps/driver`. Both can be installed on one phone side by side.

`config/dev.json` holds:

| Key                        | Used for                                                                 |
| -------------------------- | ------------------------------------------------------------------------ |
| `SUPABASE_URL`             | Supabase project URL                                                     |
| `SUPABASE_PUBLISHABLE_KEY` | Supabase publishable (anon) key. **Never** the service-role key          |

Everything is optional for UI work: without Supabase keys the apps run on demo data. Maps are free
OpenStreetMap vector maps (MapLibre + OpenFreeMap, no key); build with `--dart-define=IYO_MAP=illustration`
to draw the schematic Figma map instead.

In debug builds the home screen has a **Component gallery (dev)** button (`/dev/components`) to compare
every shared widget with the Figma frames.

## Generated code

| What                                   | Command (run where)                       |
| -------------------------------------- | ----------------------------------------- |
| EN/FR strings (`lib/l10n/gen`)         | `flutter gen-l10n` in each app and in `packages/iyo_core` |
| DB enums + ride transitions (Dart)     | `npm run db:types` at the repo root       |

## Checks

```bash
flutter analyze                       # from flutter/
flutter test                          # in packages/iyo_core, apps/rider, apps/driver
```
