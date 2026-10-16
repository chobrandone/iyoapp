import type {
  AdminDriver,
  AdminFleetVehicle,
  AdminOverview,
  AdminProfile,
  AdminRental,
  AdminRide,
  AdminRideDetail,
  AdminTransaction,
  AlertStatus,
  DocumentType,
  LiveDriver,
  NewRentalVehicle,
  PaymentsSummary,
  Place,
  RentalVehicleStatus,
  SafetyCase,
} from './models';

/** Everything the dashboard reads and writes: the Douala demo dataset or Supabase. */
export interface AdminRepository {
  readonly isDemo: boolean;

  /** Calls [listener] with the signed-in admin now and on every change; returns an unsubscribe. */
  watchAdmin(listener: (admin: AdminProfile | null) => void): () => void;
  signIn(email: string, password: string): Promise<void>;
  signOut(): Promise<void>;

  overview(): Promise<AdminOverview>;
  liveDrivers(): Promise<LiveDriver[]>;
  admins(): Promise<AdminProfile[]>;

  rides(): Promise<AdminRide[]>;
  rideDetail(rideId: string): Promise<AdminRideDetail>;

  rentals(): Promise<AdminRental[]>;

  drivers(): Promise<AdminDriver[]>;
  decideDriver(
    driverId: string,
    decision: { approve: boolean; note?: string; rejectDocument?: DocumentType },
  ): Promise<void>;
  /** Signed URL for a driver document (private bucket), valid a few minutes. */
  documentUrl(storagePath: string): Promise<string | null>;

  fleet(): Promise<AdminFleetVehicle[]>;
  setVehicleStatus(vehicleId: string, status: RentalVehicleStatus, note?: string): Promise<void>;
  addVehicle(v: NewRentalVehicle): Promise<void>;

  safetyCases(): Promise<SafetyCase[]>;
  updateSafetyCase(
    c: SafetyCase,
    update: { assignTo?: string; status?: AlertStatus; note?: string },
  ): Promise<void>;

  paymentsSummary(from: Date, to: Date): Promise<PaymentsSummary>;
  transactions(): Promise<AdminTransaction[]>;
  requestRefund(paymentId: string, amount: number, reason: string): Promise<void>;

  /** Places matching [query] in Cameroon, best first (for moving the map). */
  searchPlaces(query: string): Promise<Place[]>;

  /**
   * Calls [onChange] when the rider or driver apps change shared data (realtime), so the
   * dashboard refreshes without a reload. Returns an unsubscribe. The demo has no other apps.
   */
  subscribe(onChange: (topic: ChangeTopic) => void): () => void;
}

export type ChangeTopic = 'rides' | 'drivers' | 'rentals' | 'fleet' | 'safety' | 'payments';
