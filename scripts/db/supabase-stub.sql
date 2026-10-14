-- Minimal stand-ins for what a Supabase project provides before our migrations run,
-- so scripts/db/check.mjs can test migrations + RLS in PGlite (no Docker needed).
-- NOT a migration: never apply this to a real Supabase project.

create role anon nologin noinherit;
create role authenticated nologin noinherit;
create role service_role nologin noinherit bypassrls;

create schema extensions;
create schema auth;
create schema storage;

grant usage on schema public, extensions, auth, storage to anon, authenticated, service_role;

alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;

-- auth ----------------------------------------------------------------------

create table auth.users (
  instance_id uuid,
  id uuid primary key,
  aud text,
  role text,
  email text,
  phone text unique,
  phone_confirmed_at timestamptz,
  raw_app_meta_data jsonb,
  raw_user_meta_data jsonb,
  created_at timestamptz,
  updated_at timestamptz,
  encrypted_password text,
  confirmation_token text,
  recovery_token text,
  email_change_token_new text,
  email_change text,
  email_change_token_current text,
  phone_change text,
  phone_change_token text,
  reauthentication_token text
);

create table auth.identities (
  id uuid primary key default gen_random_uuid(),
  provider_id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  identity_data jsonb not null,
  provider text not null,
  last_sign_in_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz,
  unique (provider_id, provider)
);

create function auth.uid() returns uuid language sql stable as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid;
$$;

create function auth.role() returns text language sql stable as $$
  select nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role';
$$;

create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb;
$$;

grant execute on all functions in schema auth to anon, authenticated, service_role;

-- storage -------------------------------------------------------------------

create table storage.buckets (
  id text primary key,
  name text not null unique,
  public boolean default false,
  file_size_limit bigint,
  allowed_mime_types text[],
  created_at timestamptz default now()
);

create table storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets (id),
  name text,
  owner uuid,
  metadata jsonb,
  created_at timestamptz default now(),
  unique (bucket_id, name)
);
alter table storage.objects enable row level security;
grant all on storage.objects, storage.buckets to authenticated, service_role;

create function storage.foldername(name text) returns text[] language plpgsql immutable as $$
declare
  _parts text[];
begin
  select string_to_array(name, '/') into _parts;
  return _parts[1:array_length(_parts, 1) - 1];
end;
$$;
grant execute on function storage.foldername(text) to anon, authenticated, service_role;

-- realtime ------------------------------------------------------------------

create publication supabase_realtime;
