// HTTP helpers shared by every Edge Function: CORS, JSON responses, typed errors.

export const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

/** Thrown anywhere in a handler; becomes `{ error: code }` with the given status. Codes match @iyodriver/core. */
export class HttpError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    readonly details?: unknown,
  ) {
    super(code);
  }
}

export function json(body: unknown, status = 200, headers: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json', ...headers },
  });
}

/** Wraps a handler with CORS preflight, method check and error mapping. */
export function serve(methods: string[], handler: (req: Request) => Promise<Response>): void {
  Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
    if (!methods.includes(req.method)) return json({ error: 'method_not_allowed' }, 405);
    try {
      return await handler(req);
    } catch (error) {
      if (error instanceof HttpError) {
        return json({ error: error.code, details: error.details }, error.status);
      }
      // Errors raised by our RPCs (`raise exception 'code: details'`) carry the code as the message prefix.
      const message =
        error && typeof error === 'object' && 'message' in error
          ? String(error.message)
          : String(error);
      const code = /^([a-z_]+)(?::|$)/.exec(message)?.[1];
      const pgCode =
        error && typeof error === 'object' && 'code' in error ? String(error.code) : '';
      if (code && pgCode.startsWith('P0')) {
        return json({ error: code }, 409);
      }
      if (code === 'wrong_role' || code === 'account_blocked' || code === 'driver_not_approved') {
        return json({ error: code }, 403);
      }
      console.error(message);
      return json({ error: 'internal_error' }, 500);
    }
  });
}

/** Parse and validate a JSON body with a zod schema. */
export async function readBody<T>(
  req: Request,
  schema: {
    safeParse: (v: unknown) => { success: true; data: T } | { success: false; error: unknown };
  },
): Promise<T> {
  let raw: unknown;
  try {
    raw = await req.json();
  } catch {
    throw new HttpError(400, 'invalid_json');
  }
  const parsed = schema.safeParse(raw);
  if (!parsed.success) throw new HttpError(400, 'invalid_request', parsed.error);
  return parsed.data;
}

export function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new HttpError(500, 'server_misconfigured', `${name} is not set`);
  return value;
}
