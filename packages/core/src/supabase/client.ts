import {
  createClient,
  type SupabaseClient,
  type SupabaseClientOptions,
} from '@supabase/supabase-js';

import type { Database } from './database.types';

export type IyoSupabaseClient = SupabaseClient<Database>;

/** Where the auth session is persisted. Each app passes its own SecureStore-backed adapter. */
export type AuthStorage = NonNullable<
  NonNullable<SupabaseClientOptions<'public'>['auth']>['storage']
>;

export interface CreateSupabaseClientOptions {
  url: string;
  /** The public anon / publishable key. Never the service-role key. */
  anonKey: string;
  storage: AuthStorage;
  /** Sent as x-client-info so server logs can tell the two apps apart. */
  appRole: 'rider' | 'driver';
}

export function createSupabaseClient({
  url,
  anonKey,
  storage,
  appRole,
}: CreateSupabaseClientOptions): IyoSupabaseClient {
  if (!url || !anonKey) {
    throw new Error(
      'Supabase URL and anon key are required (EXPO_PUBLIC_SUPABASE_URL / _ANON_KEY).',
    );
  }
  return createClient<Database>(url, anonKey, {
    auth: {
      storage,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
    },
    global: { headers: { 'x-client-info': `iyodriver-${appRole}` } },
  });
}
