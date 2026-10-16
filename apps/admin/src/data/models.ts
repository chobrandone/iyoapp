// Operations dashboard models (Figma "Admin · …" frames). Amounts are FCFA integers; times are
// Date instants, shown in Douala time (UTC+1).
import type { Database } from '@iyodriver/core/src/supabase/database.types';

type Enums = Database['public']['Enums'];
export type AlertStatus = Enums['alert_status'];
export type DocumentType = Enums['document_type'];
export type FuelType = Enums['fuel_type'];
export type PaymentMethod = Enums['payment_method_type'];
export type PaymentStatus = Enums['payment_status'];
export type RentalBookingStatus = Enums['rental_booking_status'];
export type RentalVehicleStatus = Enums['rental_vehicle_status'];
export type ReviewStatus = Enums['review_status'];
export type RideStatus = Enums['ride_status'];
export type TransmissionType = Enums['transmission_type'];
export type VerificationStatus = Enums['verification_status'];

export interface GeoPoint {
  lat: number;
  lng: number;
}

export interface Place {
  name: string;
  address: string;
  location?: GeoPoint;
}

export interface AdminProfile {
  id: string;
  name: string;
}

export interface DayCount {
  day: Date;
  rides: number;
  rentals: number;
}

export interface DocumentExpiry {
  driverRef: string;
  type: DocumentType;
  expiresOn: Date;
}

export interface AdminOverview {
  ridesToday: number;
  ridesYesterday: number;
  activeRentals: number;
  pickupsToday: number;
  returnsToday: number;
  revenueToday: number;
  revenueYesterday: number;
  driversOnline: number;
  driversOnTrip: number;
  ridesInProgress: number;
  daily: DayCount[];
  openAlerts: number;
  expiring: DocumentExpiry[];
}

export type LiveDriverState = 'available' | 'on_trip' | 'to_pickup';

export interface LiveDriver {
  id: string;
  name: string;
  at: GeoPoint;
  state: LiveDriverState;
}

export interface TimelineEntry {
  title: string;
  detail?: string;
  at: Date;
}

export interface AdminRide {
  id: string;
  reference: string;
  requestedAt: Date;
  riderName: string;
  driverName?: string;
  plate?: string;
  /** "Toyota Corolla". */
  vehicle?: string;
  pickup: Place;
  dropoff: Place;
  status: RideStatus;
  fare: number;
  method: PaymentMethod;
  paymentStatus?: PaymentStatus;
  categoryCode: string;
  distanceMeters: number;
  durationSeconds: number;
  driverEarnings: number;
  hasOpenAlert: boolean;
}

const ACTIVE_RIDE: readonly RideStatus[] = [
  'requested',
  'searching',
  'driver_assigned',
  'driver_arriving',
  'driver_arrived',
  'in_progress',
];
export const isActiveRide = (r: AdminRide) => ACTIVE_RIDE.includes(r.status);

export interface PersonContact {
  name: string;
  reference: string;
  phone?: string;
  email?: string;
  rating?: number;
  /** Driver: vehicle and plate. */
  detail?: string;
}

export interface AdminRideDetail {
  ride: AdminRide;
  rider: PersonContact;
  driver?: PersonContact;
  timeline: TimelineEntry[];
  baseFare: number;
  distanceTimeFare: number;
  /** Minimum fare and rounding: the total minus base and distance/time. */
  adjustments: number;
  paymentId?: string;
  paymentReference?: string;
  capturedAt?: Date;
  refundedAmount: number;
  incidents: number;
  riderRatingGiven?: number;
  receiptAt?: Date;
}

export interface AdminRental {
  id: string;
  reference: string;
  customer: string;
  vehicle: string;
  plate: string;
  startsAt: Date;
  endsAt: Date;
  /** Address, or the airport name. */
  place: string;
  status: RentalBookingStatus;
  totalAmount: number;
  depositAmount: number;
  airportCode?: string;
  terminal?: string;
  flightNumber?: string;
  flightArrivalAt?: Date;
  assignedDriver?: string;
  refunded: boolean;
  vehicleId?: string;
}

export interface AdminDocument {
  type: DocumentType;
  status: ReviewStatus;
  expiresOn?: Date;
  fileName?: string;
  uploadedAt?: Date;
  rejectionReason?: string;
  storagePath?: string;
}

export interface AdminDriver {
  id: string;
  reference: string;
  name: string;
  phone?: string;
  email?: string;
  submittedAt?: Date;
  status: VerificationStatus;
  documents: Partial<Record<DocumentType, AdminDocument>>;
  vehicle?: string;
  plate?: string;
  reviewNotes?: string;
  online: boolean;
}

/** A document expires within [days] of [now] (or has expired). */
export const expiringWithin = (d: AdminDriver, days: number, now: Date) =>
  Object.values(d.documents).some(
    (x) => x?.expiresOn && (x.expiresOn.getTime() - now.getTime()) / 86_400_000 <= days,
  );

export type FleetAvailability =
  'available' | 'reserved' | 'on_rental' | 'return_today' | 'maintenance' | 'retired';

export interface AdminFleetVehicle {
  id: string;
  plate: string;
  make: string;
  model: string;
  category: string;
  fuel: FuelType;
  year?: number;
  availability: FleetAvailability;
  assignedDriver?: string;
  location?: string;
  bookingRef?: string;
  bookingStart?: Date;
  bookingEnd?: Date;
  complianceDue?: Date;
  maintenanceNote?: string;
}

export interface NewRentalVehicle {
  cityCode: string;
  make: string;
  model: string;
  year: number;
  category: string;
  transmission: TransmissionType;
  seats: number;
  fuel: FuelType;
  plate: string;
  color: string;
  dailyRate: number;
  deposit: number;
  kmPerDay: number;
  airportPickup: boolean;
  homeLocation?: string;
}

export type CaseSeverity = 'high' | 'medium' | 'low';

export interface SafetyCase {
  id: string;
  /** 'alert' (rider SOS) or 'incident' (driver report). */
  kind: 'alert' | 'incident';
  reference: string;
  severity: CaseSeverity;
  /** rider_sos, accident, rider_behaviour, vehicle_damage, lost_item, … */
  category: string;
  createdAt: Date;
  status: AlertStatus;
  rideRef?: string;
  rentalRef?: string;
  personName?: string;
  place?: string;
  note?: string;
  assigneeId?: string;
  assigneeName?: string;
  riderName?: string;
  riderPhone?: string;
  driverName?: string;
  driverPhone?: string;
  location?: GeoPoint;
  events: TimelineEntry[];
  resolutionNote?: string;
}

export interface DayAmount {
  day: Date;
  rides: number;
  rentals: number;
}

export interface PaymentsSummary {
  daily: DayAmount[];
  capturedToday: number;
  refundsProcessing: number;
  depositHolds: number;
  nextPayout: number;
}

export type TransactionKind =
  'ride_payment' | 'rental_payment' | 'deposit_hold' | 'refund' | 'payout';

export interface AdminTransaction {
  id: string;
  reference: string;
  kind: TransactionKind;
  bookingRef: string;
  party: string;
  method: string;
  at: Date;
  /** Negative for money going out (refunds, payouts). */
  amount: number;
  /** Server status: succeeded, held, processing, paid, requested, … */
  status: string;
  tone: 'success' | 'neutral' | 'danger';
  paymentId?: string;
  refundable: boolean;
}

/** A failed admin action, with the server's error code (`note_required`, `plate_taken`, …). */
export class BackendError extends Error {
  constructor(
    readonly code: string,
    message?: string,
  ) {
    super(message ?? code);
    this.name = 'BackendError';
  }
}
