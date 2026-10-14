// POST /payments  { action: 'charge', paymentId }
// -> { paymentId, status, providerReference, customerMessage? }
//
// Starts collecting a pending ride or rental payment from the payer's mobile money / card.
// The final status is only ever set by /payment-webhook.
import { requireCaller } from '../_shared/auth.ts';
import { z } from '../_shared/deps.ts';
import { HttpError, json, readBody, serve } from '../_shared/http.ts';
import { getPaymentProvider } from '../_shared/payments.ts';

const bodySchema = z.discriminatedUnion('action', [
  z.object({ action: z.literal('charge'), paymentId: z.uuid() }),
  // TODO: { action: 'add_card' } once the provider's card tokenisation flow is known.
]);

serve(['POST'], async (req) => {
  const caller = await requireCaller(req, ['rider']);
  const body = await readBody(req, bodySchema);
  const { admin } = caller;

  const { data: payment, error } = await admin
    .from('payments')
    .select(
      'id, payer_id, amount, method, status, purpose, ride_id, rides(payment_method_id), rental_booking_id',
    )
    .eq('id', body.paymentId)
    .eq('payer_id', caller.userId)
    .maybeSingle();
  if (error) throw error;
  if (!payment) throw new HttpError(404, 'payment_not_found');
  if (payment.method === 'cash') throw new HttpError(409, 'cash_payment');
  if (payment.status !== 'pending' && payment.status !== 'failed') {
    return json({ paymentId: payment.id, status: payment.status });
  }

  let methodId = payment.rides?.payment_method_id ?? null;
  if (!methodId && payment.rental_booking_id) {
    const { data: booking } = await admin
      .from('rental_bookings')
      .select('payment_method_id')
      .eq('id', payment.rental_booking_id)
      .single();
    methodId = booking?.payment_method_id ?? null;
  }
  const { data: method } = methodId
    ? await admin.from('payment_methods').select('phone').eq('id', methodId).maybeSingle()
    : { data: null };

  const provider = getPaymentProvider();
  const result = await provider.charge({
    paymentId: payment.id,
    amount: payment.amount,
    currency: 'XAF',
    method: payment.method as 'mtn_momo' | 'orange_money' | 'card',
    phone: method?.phone ?? null,
    description: payment.purpose === 'ride_fare' ? 'iyodriver ride' : 'iyodriver rental',
  });

  const { error: updateError } = await admin
    .from('payments')
    .update({
      status: 'processing',
      provider: provider.name,
      provider_reference: result.providerReference,
    })
    .eq('id', payment.id);
  if (updateError) throw updateError;

  return json({
    paymentId: payment.id,
    status: 'processing',
    providerReference: result.providerReference,
    customerMessage: result.customerMessage,
  });
});
