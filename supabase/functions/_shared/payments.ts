// Payment provider abstraction. Only the mock exists today.
//
// TODO(owner decision): choose the Cameroon mobile-money aggregator (MTN MoMo + Orange Money + cards)
// and implement it as another PaymentProvider. Do not pick one without the owner's approval.

import { HttpError, requireEnv } from './http.ts';

export type PaymentMethodType = 'mtn_momo' | 'orange_money' | 'card' | 'cash';

export interface ChargeRequest {
  paymentId: string;
  amount: number; // FCFA
  currency: 'XAF';
  method: Exclude<PaymentMethodType, 'cash'>;
  phone?: string | null; // mobile money wallet, E.164 (+236…, +237…)
  description: string;
}

export interface ChargeResult {
  providerReference: string;
  status: 'processing' | 'succeeded' | 'failed';
  /** e.g. "Approve the payment on your phone (*126#)". */
  customerMessage?: string;
}

export interface PayoutRequest {
  payoutId: string;
  amount: number;
  method: 'mtn_momo' | 'orange_money';
  phone: string;
}

export interface WebhookEvent {
  providerReference: string;
  status: 'succeeded' | 'failed';
  failureReason?: string;
  kind: 'charge' | 'payout';
}

export interface PaymentProvider {
  readonly name: string;
  charge(req: ChargeRequest): Promise<ChargeResult>;
  payout(req: PayoutRequest): Promise<{ providerReference: string }>;
  /** Verify the webhook signature and normalise the event. Throws on a bad signature. */
  parseWebhook(req: Request): Promise<WebhookEvent>;
}

async function hmacHex(secret: string, body: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(body));
  return Array.from(new Uint8Array(sig), (b) => b.toString(16).padStart(2, '0')).join('');
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i += 1) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/**
 * Development provider: every charge goes to "processing". Confirm it by POSTing to
 * /payment-webhook with body {"reference": "...", "status": "succeeded"} and header
 * x-mock-signature = hex HMAC-SHA256(body, PAYMENT_PROVIDER_SECRET). See supabase/README.md.
 */
export const mockProvider: PaymentProvider = {
  name: 'mock',
  charge(req) {
    return Promise.resolve({
      providerReference: `MOCK-${req.paymentId}`,
      status: 'processing',
      customerMessage: 'Mock payment: confirm it with the payment-webhook function.',
    });
  },
  payout(req) {
    return Promise.resolve({ providerReference: `MOCK-PAYOUT-${req.payoutId}` });
  },
  async parseWebhook(req) {
    const body = await req.text();
    const expected = await hmacHex(requireEnv('PAYMENT_PROVIDER_SECRET'), body);
    const given = req.headers.get('x-mock-signature') ?? '';
    if (!timingSafeEqual(given, expected)) throw new HttpError(401, 'invalid_signature');
    const event = JSON.parse(body) as {
      reference?: string;
      status?: string;
      kind?: string;
      reason?: string;
    };
    if (!event.reference || (event.status !== 'succeeded' && event.status !== 'failed')) {
      throw new HttpError(400, 'invalid_request');
    }
    return {
      providerReference: event.reference,
      status: event.status,
      failureReason: event.reason,
      kind: event.kind === 'payout' ? 'payout' : 'charge',
    };
  },
};

export function getPaymentProvider(): PaymentProvider {
  const name = Deno.env.get('PAYMENT_PROVIDER') ?? 'mock';
  if (name === 'mock') return mockProvider;
  throw new HttpError(500, 'server_misconfigured', `Unknown PAYMENT_PROVIDER "${name}"`);
}
