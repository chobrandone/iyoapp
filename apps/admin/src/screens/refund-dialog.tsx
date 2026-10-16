import { useState } from 'react';
import { useTranslation } from 'react-i18next';

import { keys, useAction } from '@/data/queries';
import { formatFcfa } from '@/ui/format';
import { Button, Dialog, Field, inputClass, textareaClass } from '@/ui/kit';

/** Amount + reason, then admin_request_refund. Finance sends it once the provider confirms. */
export function RefundDialog({
  open,
  onClose,
  paymentId,
  bookingRef,
  max,
  rideId,
}: {
  open: boolean;
  onClose: () => void;
  paymentId: string;
  bookingRef: string;
  max: number;
  rideId?: string;
}) {
  const { t } = useTranslation();
  const [amount, setAmount] = useState(String(max));
  const [reason, setReason] = useState('');
  const [error, setError] = useState<{ amount?: string; reason?: string }>({});
  const refund = useAction(
    (repo, a: { amount: number; reason: string }) =>
      repo.requestRefund(paymentId, a.amount, a.reason),
    {
      invalidate: [keys.transactions, keys.payments, ...(rideId ? [keys.ride(rideId)] : [])],
      success: (a) => t('refundIssued', { amount: formatFcfa(a.amount) }),
      errors: {
        invalid_refund_amount: t('refundAmountInvalid', { max }),
        payment_not_refundable: t('actionFailed', { reason: 'payment_not_refundable' }),
      },
    },
  );

  const submit = () => {
    const value = Number(amount.replace(/\D/g, ''));
    const next: typeof error = {};
    if (!value || value > max) next.amount = t('refundAmountInvalid', { max });
    if (reason.trim().length < 3) next.reason = t('fieldsRequired');
    setError(next);
    if (next.amount || next.reason) return;
    refund.mutate({ amount: value, reason: reason.trim() }, { onSuccess: onClose });
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      title={t('refundTitle', { ref: bookingRef })}
      actions={
        <>
          <Button onClick={onClose}>{t('cancel')}</Button>
          <Button tone="primary" loading={refund.isPending} onClick={submit}>
            {t('refundSubmit')}
          </Button>
        </>
      }
    >
      <Field
        label={t('refundAmount')}
        hint={t('refundMax', { amount: formatFcfa(max) })}
        error={error.amount}
      >
        {(p) => (
          <input
            {...p}
            inputMode="numeric"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className={inputClass}
          />
        )}
      </Field>
      <Field label={t('refundReason')} error={error.reason}>
        {(p) => (
          <textarea
            {...p}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            className={textareaClass}
          />
        )}
      </Field>
    </Dialog>
  );
}
