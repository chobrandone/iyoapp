/// Error codes raised by the database RPCs (`raise exception '<code>: details'`) and Edge Functions
/// (`{ "error": "<code>" }`). Screens map these to translated messages instead of raw text.
/// Keep in sync with packages/core/src/supabase/errors.ts.
const List<String> serverErrorCodes = [
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
];

/// Extracts a known server error code from a PostgrestException / FunctionException message.
String? serverErrorCode(Object? error) {
  final message = switch (error) {
    String s => s,
    null => null,
    _ => _messageOf(error),
  };
  if (message == null) return null;
  final code = message.split(':').first.trim();
  return serverErrorCodes.contains(code) ? code : null;
}

String? _messageOf(Object error) {
  try {
    // PostgrestException, AuthException and FunctionException all expose `message` or `details`.
    final dynamic e = error;
    final dynamic message = e.message;
    if (message is String) return message;
    final dynamic details = e.details;
    if (details is Map && details['error'] is String) return details['error'] as String;
  } on NoSuchMethodError {
    return error.toString();
  }
  return error.toString();
}
