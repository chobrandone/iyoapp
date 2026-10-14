// POST /payment-webhook  (called by the payment provider, verify_jwt = false)
// The only place a payment or payout becomes succeeded / failed.
import { getAdminClient } from '../_shared/auth.ts';
import { json, serve } from '../_shared/http.ts';
import { getPaymentProvider } from '../_shared/payments.ts';

serve(['POST'], async (req) => {
  const provider = getPaymentProvider();
  const event = await provider.parseWebhook(req); // throws 401 on a bad signature
  const admin = getAdminClient();
  const now = new Date().toISOString();

  if (event.kind === 'payout') {
    const { error } = await admin
      .from('driver_payouts')
      .update({
        status: event.status === 'succeeded' ? 'paid' : 'failed',
        paid_at: event.status === 'succeeded' ? now : null,
        failure_reason: event.failureReason ?? null,
      })
      .eq('provider', provider.name)
      .eq('provider_reference', event.providerReference);
    if (error) throw error;
    // TODO(Phase 11): push "Payout sent" to the driver.
    return json({ received: true });
  }

  const { data: payment, error } = await admin
    .from('payments')
    .update({
      status: event.status,
      confirmed_at: event.status === 'succeeded' ? now : null,
      failure_reason: event.failureReason ?? null,
    })
    .eq('provider', provider.name)
    .eq('provider_reference', event.providerReference)
    .in('status', ['pending', 'processing'])
    .select('id, purpose, rental_booking_id')
    .maybeSingle();
  if (error) throw error;

  if (payment?.rental_booking_id && payment.purpose === 'rental' && event.status === 'succeeded') {
    await admin
      .from('rental_bookings')
      .update({ status: 'confirmed' })
      .eq('id', payment.rental_booking_id)
      .eq('status', 'pending_payment');
    // TODO(Phase 10): push "Booking confirmed" and the deposit hold.
  }
  // Providers retry on non-2xx, so unknown / already-final references still get 200.
  return json({ received: true });
});
