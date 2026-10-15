// npm run db:types — generates packages/core/src/supabase/database.types.ts from the migrations,
// in the same shape as `supabase gen types typescript` (so the two are interchangeable once a
// hosted project exists: `npx supabase gen types typescript --project-id <ref> > ...`).
import { writeFileSync } from 'node:fs';
import { join } from 'node:path';

import { createDb, repoRoot } from './load.mjs';

// Written twice: for the apps (@iyodriver/core) and for Edge Functions (Deno can't import from packages/).
const OUTPUTS = [
  join(repoRoot, 'packages', 'core', 'src', 'supabase', 'database.types.ts'),
  join(repoRoot, 'supabase', 'functions', '_shared', 'database.types.ts'),
];
const { db } = await createDb({ seed: false });
const q = async (sql) => (await db.query(sql)).rows;

const enums = await q(`
  select t.typname as name, array_agg(e.enumlabel order by e.enumsortorder) as labels
  from pg_type t join pg_enum e on e.enumtypid = t.oid join pg_namespace n on n.oid = t.typnamespace
  where n.nspname = 'public' group by t.typname order by t.typname`);
const enumNames = new Set(enums.map((e) => e.name));

const tables = (
  await q(`select c.relname as name from pg_class c join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public' and c.relkind = 'r' order by c.relname`)
).map((r) => r.name);
const tableNames = new Set(tables);

const columns = await q(`
  select c.relname as table, a.attname as name, a.attnum as num, not a.attnotnull as nullable,
         t.typname as type, t.typcategory as category, et.typname as elem_type,
         a.atthasdef as has_default, a.attidentity <> '' as is_identity, a.attgenerated <> '' as is_generated
  from pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  join pg_type t on t.oid = a.atttypid
  left join pg_type et on et.oid = t.typelem and t.typcategory = 'A'
  where n.nspname = 'public' and c.relkind = 'r' and a.attnum > 0 and not a.attisdropped
  order by c.relname, a.attname`);

const fks = await q(`
  select con.conname as name, src.relname as table, dst.relname as ref_table,
         dn.nspname as ref_schema,
         (select array_agg(a.attname order by k.ord) from unnest(con.conkey) with ordinality k(attnum, ord)
            join pg_attribute a on a.attrelid = con.conrelid and a.attnum = k.attnum) as cols,
         (select array_agg(a.attname order by k.ord) from unnest(con.confkey) with ordinality k(attnum, ord)
            join pg_attribute a on a.attrelid = con.confrelid and a.attnum = k.attnum) as ref_cols,
         exists (
           select 1 from pg_index i
           where i.indrelid = con.conrelid and i.indisunique and i.indpred is null
             and (select array_agg(x order by x) from unnest(i.indkey::int2[]) x)
               = (select array_agg(x order by x) from unnest(con.conkey) x)
         ) as one_to_one
  from pg_constraint con
  join pg_class src on src.oid = con.conrelid
  join pg_namespace sn on sn.oid = src.relnamespace
  join pg_class dst on dst.oid = con.confrelid
  join pg_namespace dn on dn.oid = dst.relnamespace
  where con.contype = 'f' and sn.nspname = 'public'
  order by src.relname, con.conname`);

const functions = await q(`
  select p.proname as name, p.proretset as returns_set, rt.typname as return_type, rt.typtype as return_kind,
         p.pronargs as nargs, p.pronargdefaults as ndefaults,
         coalesce(p.proargnames, '{}') as arg_names,
         coalesce(p.proargmodes::text[], '{}') as arg_modes,
         (select array_agg(t.typname order by o.ord)
            from unnest(coalesce(p.proallargtypes, p.proargtypes::oid[])) with ordinality o(oid, ord)
            join pg_type t on t.oid = o.oid) as arg_types,
         (select array_agg(case when t.typcategory = 'A' then '_' || et.typname else t.typname end order by o.ord)
            from unnest(coalesce(p.proallargtypes, p.proargtypes::oid[])) with ordinality o(oid, ord)
            join pg_type t on t.oid = o.oid left join pg_type et on et.oid = t.typelem) as arg_types_full
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  join pg_type rt on rt.oid = p.prorettype
  where n.nspname = 'public' and p.prokind = 'f' and rt.typname <> 'trigger'
  order by p.proname`);

function tsScalar(type) {
  if (enumNames.has(type)) return `Database["public"]["Enums"]["${type}"]`;
  if (tableNames.has(type)) return `Database["public"]["Tables"]["${type}"]["Row"]`;
  switch (type) {
    case 'bool':
      return 'boolean';
    case 'int2':
    case 'int4':
    case 'int8':
    case 'float4':
    case 'float8':
    case 'numeric':
      return 'number';
    case 'json':
    case 'jsonb':
      return 'Json';
    case 'uuid':
    case 'text':
    case 'varchar':
    case 'bpchar':
    case 'date':
    case 'time':
    case 'timestamp':
    case 'timestamptz':
    case 'tstzrange':
    case 'interval':
    case 'bytea':
    case 'name':
      return 'string';
    case 'void':
      return 'undefined';
    default:
      return 'unknown'; // geography/geometry: read through RPCs or select with ST_ helpers
  }
}
const tsType = (type, elem) =>
  elem
    ? `${tsScalar(elem)}[]`
    : type.startsWith('_')
      ? `${tsScalar(type.slice(1))}[]`
      : tsScalar(type);

const lines = [];
const out = (s = '') => lines.push(s);

out('// Generated by scripts/db/gen-types.mjs from supabase/migrations. Do not edit by hand.');
out(
  '// Regenerate with `npm run db:types` (or `npx supabase gen types typescript` against a project).',
);
out();
out(
  'export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];',
);
out();
out('export type Database = {');
out('  // Allows createClient<Database>() to pick the right PostgREST features.');
out('  __InternalSupabase: {');
out('    PostgrestVersion: "13";');
out('  };');
out('  public: {');
out('    Tables: {');
for (const table of tables) {
  const cols = columns.filter((c) => c.table === table);
  out(`      ${table}: {`);
  out('        Row: {');
  for (const c of cols)
    out(`          ${c.name}: ${tsType(c.type, c.elem_type)}${c.nullable ? ' | null' : ''};`);
  out('        };');
  for (const kind of ['Insert', 'Update']) {
    out(`        ${kind}: {`);
    for (const c of cols) {
      if (c.is_generated) {
        out(`          ${c.name}?: never;`);
        continue;
      }
      const optional = kind === 'Update' || c.nullable || c.has_default || c.is_identity;
      out(
        `          ${c.name}${optional ? '?' : ''}: ${tsType(c.type, c.elem_type)}${c.nullable ? ' | null' : ''};`,
      );
    }
    out('        };');
  }
  const rels = fks.filter((f) => f.table === table && f.ref_schema === 'public');
  if (rels.length === 0) {
    out('        Relationships: [];');
  } else {
    out('        Relationships: [');
    for (const f of rels) {
      out('          {');
      out(`            foreignKeyName: "${f.name}";`);
      out(`            columns: [${f.cols.map((c) => `"${c}"`).join(', ')}];`);
      out(`            isOneToOne: ${f.one_to_one};`);
      out(`            referencedRelation: "${f.ref_table}";`);
      out(`            referencedColumns: [${f.ref_cols.map((c) => `"${c}"`).join(', ')}];`);
      out('          },');
    }
    out('        ];');
  }
  out('      };');
}
out('    };');
out('    Views: {');
out('      [_ in never]: never;');
out('    };');
out('    Functions: {');
for (const f of functions) {
  const inArgs = [];
  const outCols = [];
  const types = f.arg_types_full ?? [];
  types.forEach((type, i) => {
    const mode = f.arg_modes[i] ?? 'i';
    const name = f.arg_names[i];
    if (mode === 'i' || mode === 'b') inArgs.push({ name, type });
    if (mode === 't' || mode === 'o' || mode === 'b') outCols.push({ name, type });
  });
  const firstDefault = inArgs.length - f.ndefaults;
  out(`      ${f.name}: {`);
  if (inArgs.length === 0) {
    out('        Args: never;');
  } else {
    out('        Args: {');
    inArgs.forEach((a, i) =>
      out(`          ${a.name}${i >= firstDefault ? '?' : ''}: ${tsType(a.type)};`),
    );
    out('        };');
  }
  let ret;
  if (outCols.length > 0) {
    ret = `{\n${outCols.map((c) => `          ${c.name}: ${tsType(c.type)};`).join('\n')}\n        }`;
  } else {
    ret = tsType(f.return_type);
  }
  out(`        Returns: ${ret}${f.returns_set ? '[]' : ''};`);
  out('      };');
}
out('    };');
out('    Enums: {');
for (const e of enums) out(`      ${e.name}: ${e.labels.map((l) => `"${l}"`).join(' | ')};`);
out('    };');
out('    CompositeTypes: {');
out('      [_ in never]: never;');
out('    };');
out('  };');
out('};');
out();
out('type PublicSchema = Database["public"];');
out();
out(
  'export type Tables<T extends keyof PublicSchema["Tables"]> = PublicSchema["Tables"][T]["Row"];',
);
out(
  'export type TablesInsert<T extends keyof PublicSchema["Tables"]> = PublicSchema["Tables"][T]["Insert"];',
);
out(
  'export type TablesUpdate<T extends keyof PublicSchema["Tables"]> = PublicSchema["Tables"][T]["Update"];',
);
out('export type Enums<T extends keyof PublicSchema["Enums"]> = PublicSchema["Enums"][T];');
out(
  'export type Functions<T extends keyof PublicSchema["Functions"]> = PublicSchema["Functions"][T];',
);
out();
out('export const Constants = {');
out('  public: {');
out('    Enums: {');
for (const e of enums) out(`      ${e.name}: [${e.labels.map((l) => `"${l}"`).join(', ')}],`);
out('    },');
out('  },');
out('} as const;');

for (const file of OUTPUTS) writeFileSync(file, lines.join('\n') + '\n');

// ---------------------------------------------------------------------------
// Dart: every DB enum + the ride transition table, for the Flutter apps (iyo_core).
// ---------------------------------------------------------------------------

const DART_OUT = join(
  repoRoot,
  'flutter',
  'packages',
  'iyo_core',
  'lib',
  'src',
  'supabase',
  'db_enums.dart',
);
const camel = (s) => s.replace(/_([a-z0-9])/g, (_, c) => c.toUpperCase());
const pascal = (s) => camel(s).replace(/^./, (c) => c.toUpperCase());
// Dart keywords, plus names that clash with members every Dart enum already has.
const DART_RESERVED = new Set(
  (
    'assert break case catch class const continue default do else enum extends false final finally for ' +
    'if in is new null rethrow return super switch this throw true try var void while with ' +
    'values index name value'
  ).split(' '),
);
const member = (label) => {
  const m = camel(label);
  return DART_RESERVED.has(m) ? `${m}_` : m;
};

const transitions = await q(
  `select from_status::text f, to_status::text t, actor::text a from public.ride_status_transitions order by 1, 2, 3`,
);

const dart = [];
dart.push(
  '// Generated by scripts/db/gen-types.mjs from supabase/migrations. Do not edit by hand.',
);
dart.push('// Regenerate with `npm run db:types` from the repo root.');
dart.push('// ignore_for_file: constant_identifier_names');
dart.push('');
for (const e of enums) {
  const type = pascal(e.name);
  dart.push(`/// Postgres enum \`public.${e.name}\`.`);
  dart.push(`enum ${type} {`);
  for (const label of e.labels) dart.push(`  ${member(label)}('${label}'),`);
  dart.push('  ;');
  dart.push('');
  dart.push(`  const ${type}(this.value);`);
  dart.push('');
  dart.push('  /// The value stored in the database.');
  dart.push('  final String value;');
  dart.push('');
  dart.push(`  static ${type} fromValue(String value) =>`);
  dart.push(
    `      values.firstWhere((e) => e.value == value, orElse: () => throw ArgumentError.value(value, '${e.name}'));`,
  );
  dart.push('}');
  dart.push('');
}
dart.push('/// Rows of `public.ride_status_transitions`: (from, to, actor).');
dart.push('const List<(RideStatus, RideStatus, RideActor)> rideStatusTransitions = [');
for (const t of transitions) {
  dart.push(`  (RideStatus.${member(t.f)}, RideStatus.${member(t.t)}, RideActor.${member(t.a)}),`);
}
dart.push('];');
writeFileSync(DART_OUT, dart.join('\n') + '\n');

await db.close();
console.log(
  `Wrote ${OUTPUTS.join(', ')} (${tables.length} tables, ${functions.length} functions, ${enums.length} enums)`,
);
