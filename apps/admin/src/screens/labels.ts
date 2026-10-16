// Status names and tones shared by several screens.
import type { TFunction } from 'i18next';

import type {
  AdminRide,
  CaseSeverity,
  DocumentType,
  FleetAvailability,
  PaymentStatus,
  RentalBookingStatus,
  RideStatus,
  TransactionKind,
} from '@/data/models';
import type { Tone } from '@/ui/kit';

export type RideGroup = 'matching' | 'arriving' | 'on_trip' | 'completed' | 'cancelled';

export function rideGroup(s: RideStatus): RideGroup {
  switch (s) {
    case 'requested':
    case 'searching':
      return 'matching';
    case 'driver_assigned':
    case 'driver_arriving':
    case 'driver_arrived':
      return 'arriving';
    case 'in_progress':
      return 'on_trip';
    case 'completed':
      return 'completed';
    default:
      return 'cancelled';
  }
}

export function rideStatusLabel(t: TFunction, s: RideStatus): string {
  switch (s) {
    case 'requested':
    case 'searching':
      return t('stMatching');
    case 'driver_assigned':
    case 'driver_arriving':
      return t('stArriving');
    case 'driver_arrived':
      return t('stAtPickup');
    case 'in_progress':
      return t('stOnTrip');
    case 'completed':
      return t('stCompleted');
    case 'no_drivers_found':
      return t('stNoDrivers');
    default:
      return t('stCancelled');
  }
}

export const groupLabel = (t: TFunction, g: RideGroup) =>
  ({
    matching: t('stMatching'),
    arriving: t('stArriving'),
    on_trip: t('stOnTrip'),
    completed: t('stCompleted'),
    cancelled: t('stCancelled'),
  })[g];

export const rideDot = (s: RideStatus): 'ok' | 'ink' =>
  ['on_trip', 'completed'].includes(rideGroup(s)) ? 'ok' : 'ink';

export function rideTone(s: RideStatus): Tone {
  const g = rideGroup(s);
  return g === 'on_trip' || g === 'completed' ? 'success' : g === 'matching' ? 'accent' : 'neutral';
}

export const paymentName = (t: TFunction, s: PaymentStatus) =>
  ({
    pending: t('payPending'),
    processing: t('payAuth'),
    succeeded: t('payPaid'),
    failed: t('payFailed'),
    cancelled: t('payCancelled'),
    refunded: t('payRefunded'),
  })[s];

export function paymentLabel(t: TFunction, r: AdminRide): string {
  if (r.paymentStatus) return paymentName(t, r.paymentStatus);
  if (r.method === 'cash') return r.status === 'completed' ? t('payPaid') : t('payOnDelivery');
  return t('payPending');
}

export const documentName = (t: TFunction, d: DocumentType) =>
  ({
    national_id_front: t('docNationalIdFront'),
    national_id_back: t('docNationalIdBack'),
    driving_licence: t('docDrivingLicence'),
    vehicle_registration: t('docVehicleRegistration'),
    insurance: t('docInsurance'),
    roadworthiness: t('docRoadworthiness'),
    profile_photo: t('docProfilePhoto'),
  })[d];

export function caseTitle(t: TFunction, category: string): string {
  switch (category) {
    case 'rider_sos':
      return t('catRiderSos');
    case 'route_deviation':
      return t('catRouteDeviation');
    case 'vehicle_damage':
      return t('catVehicleDamage');
    case 'lost_item':
      return t('catLostItem');
    case 'accident':
      return t('catAccident');
    case 'rider_behaviour':
      return t('catRiderBehaviour');
    case 'theft_or_aggression':
      return t('catTheft');
    case 'payment':
      return t('catPayment');
    case 'pickup_pin_locked':
    case 'handover_pin_locked':
      return t('catPinLocked');
    default:
      return t('catOther');
  }
}

export const severityName = (t: TFunction, s: CaseSeverity) =>
  ({ high: t('sevHigh'), medium: t('sevMedium'), low: t('sevLow') })[s];

export const severityTone = (s: CaseSeverity): Tone =>
  ({ high: 'danger', medium: 'accent', low: 'neutral' })[s] as Tone;

export const rentalStatusName = (t: TFunction, s: RentalBookingStatus) =>
  ({
    pending_payment: t('rsAwaitingPayment'),
    confirmed: t('rsConfirmed'),
    driver_assigned: t('rsConfirmed'),
    active: t('rsActive'),
    return_pending: t('rsReturnCheck'),
    completed: t('rsReturned'),
    cancelled: t('rsCancelled'),
  })[s];

export const availabilityName = (t: TFunction, a: FleetAvailability) =>
  ({
    available: t('fvAvailable'),
    reserved: t('fvReserved'),
    on_rental: t('fvOnRental'),
    return_today: t('fvReturnToday'),
    maintenance: t('fvMaintenance'),
    retired: t('fvRetired'),
  })[a];

export const availabilityDot = (a: FleetAvailability): 'ok' | 'bad' | 'ink' =>
  a === 'available' || a === 'on_rental' ? 'ok' : a === 'maintenance' ? 'bad' : 'ink';

export const categoryName = (t: TFunction, c: string) =>
  ({ economy: t('catEconomy'), sedan: t('catSedan'), suv: t('catSuv'), pickup: t('catPickup') })[
    c
  ] ?? c;

export const kindName = (t: TFunction, k: TransactionKind) =>
  ({
    ride_payment: t('kRide'),
    rental_payment: t('kRental'),
    deposit_hold: t('kDeposit'),
    refund: t('kRefund'),
    payout: t('kPayout'),
  })[k];

export const txStatusName = (t: TFunction, s: string) => t(`tx_${s}`, { defaultValue: s });
