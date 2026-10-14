// POST /safety-notify  { alertId }  -> { notified }
// After raise_safety_alert(), texts the rider's trusted contacts a live-trip link.
// The iyodriver safety team sees the alert in realtime (safety_alerts is in the realtime publication).
import { requireCaller } from '../_shared/auth.ts';
import { z } from '../_shared/deps.ts';
import { HttpError, json, readBody, serve } from '../_shared/http.ts';
import { getSmsProvider } from '../_shared/sms.ts';

const bodySchema = z.object({ alertId: z.uuid() });

serve(['POST'], async (req) => {
  const caller = await requireCaller(req, ['rider']);
  const { alertId } = await readBody(req, bodySchema);
  const { admin } = caller;

  const { data: alert, error } = await admin
    .from('safety_alerts')
    .select('id, ride_id, raised_by, contacts_notified_at')
    .eq('id', alertId)
    .eq('raised_by', caller.userId)
    .maybeSingle();
  if (error) throw error;
  if (!alert) throw new HttpError(404, 'alert_not_found');
  if (alert.contacts_notified_at) return json({ notified: 0, alreadyNotified: true });

  const [{ data: contacts }, { data: profile }] = await Promise.all([
    admin
      .from('trusted_contacts')
      .select('phone')
      .eq('user_id', caller.userId)
      .eq('notify_on_alert', true),
    admin.from('profiles').select('full_name, language').eq('id', caller.userId).single(),
  ]);

  let link = '';
  if (alert.ride_id) {
    // Reuses the RPC through the user's own client so ownership is checked again.
    const { data: share } = await caller.userClient.rpc('create_trip_share', {
      p_ride_id: alert.ride_id,
    });
    const base = Deno.env.get('TRIP_SHARE_BASE_URL'); // TODO(owner): public page that renders /shared-trip
    if (share && base) link = ` ${base}?t=${(share as { token: string }).token}`;
  }

  const name = profile?.full_name || 'Un utilisateur iyodriver';
  const body =
    profile?.language === 'en'
      ? `iyodriver safety alert: ${name} has raised an alert during a trip.${link}`
      : `Alerte sécurité iyodriver : ${name} a déclenché une alerte pendant un trajet.${link}`;

  const sms = getSmsProvider();
  let notified = 0;
  for (const contact of contacts ?? []) {
    try {
      await sms.send(contact.phone, body);
      notified += 1;
    } catch (e) {
      console.error('SMS failed', e);
    }
  }

  await admin
    .from('safety_alerts')
    .update({ contacts_notified_at: new Date().toISOString() })
    .eq('id', alert.id);
  return json({ notified });
});
