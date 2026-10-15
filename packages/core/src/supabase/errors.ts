/**
 * Error codes raised by the database RPCs (`raise exception '<code>: details'`) and Edge Functions
 * (`{ error: '<code>' }`). Apps map these to translated messages instead of showing raw text.
 */
export const SERVER_ERROR_CODES = [
  'not_authenticated',
  'wrong_role',
  'account_blocked',
  'rate_limited',
  'quote_not_found',
  'quote_already_used',
  'quote_expired',
  'invalid_payment_method',
  'rider_has_open_ride',
  'ride_not_found',
  'invalid_transition',
  'status_not_allowed_here',
  'offer_not_found',
  'offer_not_pending',
  'offer_expired',
  'driver_has_active_ride',
  'driver_not_approved',
  'driver_offline',
  'no_active_vehicle',
  'location_required',
  'invalid_coordinates',
  'finish_active_ride_first',
  'driver_not_arrived',
  'ride_not_rateable',
  'application_not_editable',
  'identity_incomplete',
  'vehicle_missing',
  'documents_missing',
  'driver_identity_locked',
  'trusted_contacts_limit_reached',
  'invalid_rental_period',
  'vehicle_not_found',
  'vehicle_unavailable_for_dates',
  'airport_pickup_unavailable',
  'airport_not_found',
  'booking_not_found',
  'no_fare_config',
  'outside_service_area',
  'no_route',
  'upstream_error',
  'payment_not_found',
  'cash_payment',
  'alert_not_found',
  'share_not_found',
  'invalid_request',
  'internal_error',
  'booking_not_cancellable',
  'booking_not_assignable',
  'handover_not_allowed',
  'return_not_allowed',
  'photos_missing',
  'invalid_deposit_hold',
  'inspection_not_ready',
] as const;

export type ServerErrorCode = (typeof SERVER_ERROR_CODES)[number];

/** Extract a known server error code from a PostgREST / Functions error, or null. */
export function serverErrorCode(error: unknown): ServerErrorCode | null {
  const message =
    typeof error === 'string'
      ? error
      : error &&
          typeof error === 'object' &&
          'message' in error &&
          typeof error.message === 'string'
        ? error.message
        : null;
  if (!message) return null;
  const code = (message.split(':')[0] ?? '').trim();
  return (SERVER_ERROR_CODES as readonly string[]).includes(code)
    ? (code as ServerErrorCode)
    : null;
}
