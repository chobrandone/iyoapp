// Spins up an in-memory Postgres (PGlite + PostGIS), applies the Supabase stand-ins,
// every migration in supabase/migrations (in order) and optionally supabase/seed.sql.
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { PGlite } from '@electric-sql/pglite';
import { btree_gist } from '@electric-sql/pglite/contrib/btree_gist';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { postgis } from '@electric-sql/pglite-postgis';

const here = dirname(fileURLToPath(import.meta.url));
export const repoRoot = join(here, '..', '..');
const migrationsDir = join(repoRoot, 'supabase', 'migrations');

export async function createDb({ seed = true } = {}) {
  const db = new PGlite({ extensions: { postgis, btree_gist, pgcrypto } });
  await db.exec(readFileSync(join(here, 'supabase-stub.sql'), 'utf8'));

  const files = readdirSync(migrationsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();
  for (const file of files) {
    try {
      await db.exec(readFileSync(join(migrationsDir, file), 'utf8'));
    } catch (error) {
      throw new Error(`Migration ${file} failed: ${error.message}`, { cause: error });
    }
  }
  if (seed) {
    try {
      await db.exec(readFileSync(join(repoRoot, 'supabase', 'seed.sql'), 'utf8'));
    } catch (error) {
      throw new Error(`seed.sql failed: ${error.message}`, { cause: error });
    }
  }
  return { db, migrations: files };
}
