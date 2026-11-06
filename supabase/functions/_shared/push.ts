// Firebase Cloud Messaging (HTTP v1). FIREBASE_SERVICE_ACCOUNT holds the service-account JSON as an
// Edge Function secret; without it pushes are skipped. A failed push never fails the caller:
// the apps also follow rides over Realtime while they are open.
import type { DbClient } from './auth.ts';

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

export interface PushMessage {
  title: string;
  body: string;
  /** Delivered to the app with the notification. */
  data?: Record<string, string>;
  /** Android notification channel created by the app. */
  channelId?: string;
  /** Drop the message when it can't be delivered within this time. */
  ttlSeconds?: number;
}

const SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
const TOKEN_URL = 'https://oauth2.googleapis.com/token';

let cachedToken: { value: string; expiresAt: number } | null = null;

function base64Url(input: string | Uint8Array): string {
  const bytes = typeof input === 'string' ? new TextEncoder().encode(input) : input;
  return btoa(String.fromCharCode(...bytes))
    .replaceAll('+', '-')
    .replaceAll('/', '_')
    .replaceAll('=', '');
}

function importKey(pem: string): Promise<CryptoKey> {
  const der = atob(pem.replace(/-----[A-Z ]+-----/g, '').replace(/\s/g, ''));
  return crypto.subtle.importKey(
    'pkcs8',
    Uint8Array.from(der, (c) => c.charCodeAt(0)),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

async function accessToken(account: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt > now + 60) return cachedToken.value;

  const unsigned = [
    base64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' })),
    base64Url(
      JSON.stringify({
        iss: account.client_email,
        scope: SCOPE,
        aud: TOKEN_URL,
        iat: now,
        exp: now + 3600,
      }),
    ),
  ].join('.');
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    await importKey(account.private_key),
    new TextEncoder().encode(unsigned),
  );
  const res = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${unsigned}.${base64Url(new Uint8Array(signature))}`,
    }),
  });
  if (!res.ok) throw new Error(`Google token ${res.status}: ${await res.text()}`);
  const data = (await res.json()) as { access_token: string; expires_in: number };
  cachedToken = { value: data.access_token, expiresAt: now + data.expires_in };
  return data.access_token;
}

/** Sends to every device of a user in one app and forgets tokens FCM no longer knows. */
export async function sendPush(
  admin: DbClient,
  userId: string,
  app: 'rider' | 'driver',
  message: PushMessage,
): Promise<void> {
  const secret = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (!secret) return;
  try {
    const account = JSON.parse(secret) as ServiceAccount;
    const { data: rows, error } = await admin
      .from('push_tokens')
      .select('token')
      .eq('user_id', userId)
      .eq('app', app);
    if (error) throw error;
    if (!rows?.length) return;

    const bearer = await accessToken(account);
    const url = `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`;
    await Promise.all(
      rows.map(async ({ token }) => {
        const res = await fetch(url, {
          method: 'POST',
          headers: { Authorization: `Bearer ${bearer}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({
            message: {
              token,
              notification: { title: message.title, body: message.body },
              data: message.data,
              android: {
                priority: 'HIGH',
                ttl: message.ttlSeconds ? `${message.ttlSeconds}s` : undefined,
                notification: { channel_id: message.channelId, sound: 'default' },
              },
            },
          }),
        });
        if (res.status === 404) {
          await admin.from('push_tokens').delete().eq('token', token);
        } else if (!res.ok) {
          console.error(`FCM ${res.status}: ${await res.text()}`);
        }
      }),
    );
  } catch (e) {
    console.error('Push failed', e);
  }
}
