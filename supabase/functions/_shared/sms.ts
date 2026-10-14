// SMS provider abstraction for safety messages to trusted contacts (not auth OTPs, which
// Supabase Auth sends through its own SMS provider settings).
//
// TODO(owner decision): pick the SMS provider for Cameroon (MTN / Orange delivery) and add it here.

import { HttpError } from './http.ts';

export interface SmsProvider {
  readonly name: string;
  send(to: string, body: string): Promise<{ providerReference: string }>;
}

/** Logs the message instead of sending it. */
export const mockSms: SmsProvider = {
  name: 'mock',
  send(to, body) {
    console.log(`[mock-sms] to=${to.slice(0, 7)}***** body=${JSON.stringify(body)}`);
    return Promise.resolve({ providerReference: `MOCK-SMS-${crypto.randomUUID()}` });
  },
};

export function getSmsProvider(): SmsProvider {
  const name = Deno.env.get('SMS_PROVIDER') ?? 'mock';
  if (name === 'mock') return mockSms;
  throw new HttpError(500, 'server_misconfigured', `Unknown SMS_PROVIDER "${name}"`);
}
