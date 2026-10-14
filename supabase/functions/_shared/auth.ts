// Caller identity and role checks. Every function that acts for a user goes through requireCaller().
import type { Database } from './database.types.ts';
import { createClient, type SupabaseClient } from './deps.ts';
import { HttpError, requireEnv } from './http.ts';

export type AppRole = Database['public']['Enums']['app_role'];
export type DbClient = SupabaseClient<Database>;

export interface Caller {
  userId: string;
  role: AppRole;
  /** Client acting as the user (RLS applies). */
  userClient: DbClient;
  /** Service-role client (bypasses RLS). Use only after checking the caller. */
  admin: DbClient;
}

let adminClient: DbClient | null = null;

/** Service-role client. SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are injected by Supabase. */
export function getAdminClient(): DbClient {
  adminClient ??= createClient<Database>(
    requireEnv('SUPABASE_URL'),
    requireEnv('SUPABASE_SERVICE_ROLE_KEY'),
    {
      auth: { persistSession: false, autoRefreshToken: false },
    },
  );
  return adminClient;
}

/** True when the request carries the service-role key (cron jobs, other functions). */
export function isServiceRequest(req: Request): boolean {
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  return !!key && req.headers.get('Authorization') === `Bearer ${key}`;
}

/** Authenticate the user from the Authorization header and enforce the allowed app roles. */
export async function requireCaller(req: Request, allowed: AppRole[]): Promise<Caller> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) throw new HttpError(401, 'not_authenticated');

  const userClient = createClient<Database>(
    requireEnv('SUPABASE_URL'),
    requireEnv('SUPABASE_ANON_KEY'),
    {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false, autoRefreshToken: false },
    },
  );
  const { data, error } = await userClient.auth.getUser(authHeader.slice('Bearer '.length));
  if (error || !data.user) throw new HttpError(401, 'not_authenticated');

  const admin = getAdminClient();
  const { data: profile } = await admin
    .from('profiles')
    .select('role, is_blocked')
    .eq('id', data.user.id)
    .single();
  if (!profile) throw new HttpError(403, 'wrong_role');
  if (profile.is_blocked) throw new HttpError(403, 'account_blocked');
  if (!allowed.includes(profile.role)) throw new HttpError(403, 'wrong_role');

  return { userId: data.user.id, role: profile.role, userClient, admin };
}

/** Per-user fixed-window rate limit (public.consume_rate_limit). */
export async function rateLimit(caller: Caller, bucket: string, limit: number, windowSeconds = 60) {
  const { data, error } = await caller.admin.rpc('consume_rate_limit', {
    p_user_id: caller.userId,
    p_bucket: bucket,
    p_limit: limit,
    p_window_seconds: windowSeconds,
  });
  if (error) throw error;
  if (data !== true) throw new HttpError(429, 'rate_limited');
}
