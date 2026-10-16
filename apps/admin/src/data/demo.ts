// In-memory operations data for the dashboard without a Supabase project: one consistent Douala
// day (rides, rentals, drivers, fleet, safety cases, payments) around "now". Writes stay in memory.
import {
  BackendError,
  type AdminDocument,
  type AdminDriver,
  type AdminFleetVehicle,
  type AdminOverview,
  type AdminProfile,
  type AdminRental,
  type AdminRide,
  type AdminRideDetail,
  type AdminTransaction,
  type AlertStatus,
  type DocumentType,
  type FleetAvailability,
  type FuelType,
  type GeoPoint,
  type LiveDriver,
  type NewRentalVehicle,
  type PaymentMethod,
  type PaymentStatus,
  type PaymentsSummary,
  type RentalBookingStatus,
  type RentalVehicleStatus,
  type ReviewStatus,
  type RideStatus,
  type SafetyCase,
  type TimelineEntry,
  type TransactionKind,
} from './models';
import type { AdminRepository } from './repository';
import { addDays, doualaDay } from './time';

export const DEMO_ADMIN_EMAIL = 'ops@iyodriver.cm';
export const DEMO_ADMIN_PASSWORD = 'iyodriver-demo';

const ME: AdminProfile = { id: 'admin-1', name: 'Nadine Eyenga' };
const TEAM: AdminProfile[] = [
  ME,
  { id: 'admin-2', name: 'Maya Ekambi' },
  { id: 'admin-3', name: 'Joël Nana' },
];

const COORDS: Record<string, GeoPoint> = {
  Akwa: { lat: 4.0505, lng: 9.6966 },
  Bonapriso: { lat: 4.033, lng: 9.693 },
  Bonanjo: { lat: 4.043, lng: 9.688 },
  Deido: { lat: 4.064, lng: 9.707 },
  Bali: { lat: 4.044, lng: 9.703 },
  Makepe: { lat: 4.075, lng: 9.748 },
  Bonamoussadi: { lat: 4.09, lng: 9.742 },
  Bessengué: { lat: 4.061, lng: 9.714 },
  Logpom: { lat: 4.088, lng: 9.765 },
  Ndokoti: { lat: 4.047, lng: 9.74 },
};

const DOC_TYPES: DocumentType[] = [
  'national_id_front',
  'national_id_back',
  'driving_licence',
  'vehicle_registration',
  'insurance',
  'roadworthiness',
  'profile_photo',
];

const METHOD_LABEL: Record<PaymentMethod, string> = {
  mtn_momo: 'MTN MoMo',
  orange_money: 'Orange Money',
  cash: 'Cash',
  card: 'Card',
};

const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));

/** The demo sign-in survives a page refresh in this tab, like a real session. */
const SESSION_KEY = 'iyodriver.admin.demo-session';
function rememberSession(on: boolean) {
  try {
    if (on) sessionStorage.setItem(SESSION_KEY, '1');
    else sessionStorage.removeItem(SESSION_KEY);
  } catch {
    // Storage blocked: the session lasts until the page reloads.
  }
}
function hasSession() {
  try {
    return sessionStorage.getItem(SESSION_KEY) === '1';
  } catch {
    return false;
  }
}

export class DemoAdminBackend implements AdminRepository {
  readonly isDemo = true;
  private readonly now: Date;
  private signedIn: AdminProfile | null = null;
  private readonly listeners = new Set<(a: AdminProfile | null) => void>();
  /** Simulated network delay, so loading states show (0 in tests). */
  private readonly latency: number;
  private readonly persist: boolean;

  private rideList: AdminRide[] = [];
  private rentalList: AdminRental[] = [];
  private driverList: AdminDriver[] = [];
  private fleetList: AdminFleetVehicle[] = [];
  private caseList: SafetyCase[] = [];
  private txList: AdminTransaction[] = [];
  private readonly refunded = new Map<string, number>();

  constructor(
    options: { now?: Date; latency?: number; signedIn?: boolean; persistSession?: boolean } = {},
  ) {
    this.now = options.now ?? new Date();
    this.latency = options.latency ?? 150;
    this.persist = options.persistSession ?? false;
    if (options.signedIn || (this.persist && hasSession())) this.signedIn = ME;
    this.seed();
  }

  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  watchAdmin(listener: (a: AdminProfile | null) => void) {
    this.listeners.add(listener);
    listener(this.signedIn);
    return () => void this.listeners.delete(listener);
  }

  private emit() {
    for (const l of this.listeners) l(this.signedIn);
  }

  async signIn(email: string, password: string) {
    await wait(this.latency);
    if (email.trim().toLowerCase() !== DEMO_ADMIN_EMAIL || password !== DEMO_ADMIN_PASSWORD) {
      throw new BackendError('invalid_credentials');
    }
    this.signedIn = ME;
    if (this.persist) rememberSession(true);
    this.emit();
  }

  async signOut() {
    this.signedIn = null;
    if (this.persist) rememberSession(false);
    this.emit();
  }

  async admins() {
    return TEAM;
  }

  // -------------------------------------------------------------------------
  // Seed data
  // -------------------------------------------------------------------------

  /** Today in Douala at h:m. */
  private todayAt(h: number, m: number) {
    return new Date(doualaDay(this.now).getTime() + (h * 60 + m) * 60_000);
  }

  private dayAt(offset: number, h: number, m: number) {
    return addDays(this.todayAt(h, m), offset);
  }

  private seed() {
    const place = (name: string, area: string) => ({
      name,
      address: `${name}, ${area}, Douala`,
      location: COORDS[area],
    });
    const ride = (
      ref: string,
      h: number,
      m: number,
      rider: string,
      driver: string | null,
      plate: string | null,
      from: [string, string],
      to: [string, string],
      status: RideStatus,
      fare: number,
      method: PaymentMethod,
      pay: PaymentStatus | null,
      alert = false,
    ): AdminRide => ({
      id: `ride-${ref}`,
      reference: ref,
      requestedAt: this.todayAt(h, m),
      riderName: rider,
      driverName: driver ?? undefined,
      plate: plate ?? undefined,
      vehicle: plate ? 'Toyota Corolla' : undefined,
      pickup: place(...from),
      dropoff: place(...to),
      status,
      fare,
      method,
      paymentStatus: pay ?? undefined,
      categoryCode: 'standard',
      distanceMeters: 3800,
      durationSeconds: 18 * 60,
      driverEarnings: Math.round(fare * 0.8),
      hasOpenAlert: alert,
    });
    // prettier-ignore
    this.rideList = [
      ride('RD-1047', 9, 38, 'Ines Kamga', 'Serge Talla', 'LT 451 BD', ['Rue Joffre', 'Akwa'], ['Carrefour Makepe', 'Makepe'], 'in_progress', 3200, 'mtn_momo', 'processing'),
      ride('RD-1046', 9, 37, 'Paul Atangana', null, null, ['Marché Sandaga', 'Bali'], ['Gare de Bessengué', 'Bessengué'], 'searching', 2300, 'orange_money', 'pending'),
      ride('RD-1045', 9, 34, 'Christian Fotso', 'Eric Mvondo', 'LT 302 EM', ['Boulevard de la Liberté', 'Akwa'], ['Rond-point Deido', 'Deido'], 'in_progress', 2500, 'mtn_momo', 'processing'),
      ride('RD-1044', 9, 30, 'Samuel Ekane', 'Hervé Ngono', 'LT 214 HN', ['Rue Njo-Njo', 'Bonapriso'], ['Carrefour Logpom', 'Logpom'], 'in_progress', 4100, 'cash', null),
      ride('RD-1043', 9, 38, 'Aïcha Ngo Mbappe', 'Jean-Paul Mbarga', 'LT 123 AB', ['12 Rue Joss', 'Akwa'], ['Gare de Bessengué', 'Bessengué'], 'driver_arriving', 3100, 'mtn_momo', 'pending', true),
      ride('RD-1042', 9, 4, 'Aïcha Ngo Mbappe', 'Jean-Paul Mbarga', 'LT 123 AB', ['12 Rue Joss', 'Akwa'], ['Gare de Bessengué', 'Bessengué'], 'completed', 3100, 'mtn_momo', 'succeeded'),
      ride('RD-1041', 9, 1, 'Grâce Mballa', 'Nadège Abena', 'LT 778 NA', ['Rue Gallieni', 'Bonanjo'], ['Ndokoti', 'Ndokoti'], 'cancelled_by_rider', 500, 'mtn_momo', 'succeeded'),
      ride('RD-1040', 8, 55, 'Ruth Ndongo', 'Serge Talla', 'LT 451 BD', ['Collège Libermann', 'Bali'], ['Bonamoussadi', 'Bonamoussadi'], 'completed', 4200, 'orange_money', 'succeeded'),
      ride('RD-1039', 8, 41, 'Brice Nkoulou', 'Eric Mvondo', 'LT 302 EM', ['Akwa Palace', 'Akwa'], ['Makepe Missoke', 'Makepe'], 'completed', 3600, 'card', 'succeeded'),
      ride('RD-1038', 8, 20, 'Christian Fotso', 'Jean-Paul Mbarga', 'LT 123 AB', ['Deido Plage', 'Deido'], ['Rue Koloko', 'Bonapriso'], 'completed', 3250, 'mtn_momo', 'succeeded'),
      ride('RD-1037', 8, 2, 'Junior Essomba', null, null, ['Ndokoti', 'Ndokoti'], ['Akwa Nord', 'Akwa'], 'no_drivers_found', 2800, 'mtn_momo', 'cancelled'),
      ride('RD-1034', 7, 45, 'Mireille Tchoumi', 'Jean-Paul Mbarga', 'LT 123 AB', ['Bali', 'Bali'], ['Rue Joss', 'Akwa'], 'completed', 3060, 'mtn_momo', 'succeeded'),
    ];

    const rental = (
      ref: string,
      customer: string,
      vehicle: string,
      plate: string,
      startDay: number,
      startH: number,
      days: number,
      where: string,
      airport: string | null,
      status: RentalBookingStatus,
      total: number,
      extra: { driver?: string; flight?: string; refunded?: boolean } = {},
    ): AdminRental => ({
      id: `rental-${ref}`,
      reference: ref,
      customer,
      vehicle,
      plate,
      startsAt: this.dayAt(startDay, startH, 0),
      endsAt: this.dayAt(startDay + days, startH, 0),
      place: where,
      airportCode: airport ?? undefined,
      terminal: airport ? 'Arrivals' : undefined,
      flightNumber: extra.flight,
      flightArrivalAt: extra.flight ? this.dayAt(startDay, startH - 1, 15) : undefined,
      status,
      totalAmount: total,
      depositAmount: 100000,
      assignedDriver: extra.driver,
      refunded: extra.refunded ?? false,
      vehicleId: `car-${plate}`,
    });
    const airport = 'Douala International Airport';
    // prettier-ignore
    this.rentalList = [
      rental('RN-2048', 'Aïcha Ngo Mbappe', 'Toyota Corolla', 'LT 211 RB', 1, 10, 3, airport, 'DLA', 'driver_assigned', 89000, { driver: 'Jean-Paul Mbarga', flight: 'AF900' }),
      rental('RN-2049', 'Christian Fotso', 'Toyota RAV4', 'LT 210 RA', 2, 11, 3, airport, 'DLA', 'confirmed', 110000, { driver: 'Hervé Ngono', flight: 'SN371' }),
      rental('RN-2050', 'Ruth Ndongo', 'Toyota Corolla', 'LT 215 RC', 0, 9, 2, 'Hub Akwa, Rue Joss', null, 'confirmed', 50000, { driver: 'Nadège Abena' }),
      rental('RN-2044', 'Paul Atangana', 'Hyundai Tucson', 'LT 212 RC', -2, 10, 3, 'Dépôt Bonapriso', null, 'active', 120000, { driver: 'Eric Mvondo' }),
      rental('RN-2042', 'Ines Kamga', 'Toyota Corolla', 'LT 216 RD', -3, 12, 3, airport, 'DLA', 'active', 89000, { driver: 'Serge Talla', flight: 'ET905' }),
      rental('RN-2039', 'Grâce Mballa', 'Toyota RAV4', 'LT 217 RE', -6, 10, 3, 'Dépôt Bonapriso', null, 'completed', 105000, { driver: 'Nadège Abena' }),
      rental('RN-2038', 'Samuel Ekane', 'Toyota Corolla', 'LT 215 RC', -7, 9, 2, airport, 'DLA', 'cancelled', 55000, { refunded: true, flight: 'QC401' }),
    ];

    const today = doualaDay(this.now);
    const doc = (
      type: DocumentType,
      status: ReviewStatus,
      o: { expiresInDays?: number; file?: string; reason?: string } = {},
    ): AdminDocument => ({
      type,
      status,
      expiresOn: o.expiresInDays === undefined ? undefined : addDays(today, o.expiresInDays),
      fileName: o.file ?? `${type}.jpg`,
      uploadedAt: this.todayAt(8, 39),
      rejectionReason: o.reason,
    });
    const docs = (status: ReviewStatus, o: { licence?: number; insurance?: number } = {}) => {
      const expiry: Partial<Record<DocumentType, number>> = {
        driving_licence: o.licence ?? 1200,
        insurance: o.insurance ?? 340,
        vehicle_registration: 700,
        roadworthiness: 150,
      };
      return Object.fromEntries(
        DOC_TYPES.map((t) => [t, doc(t, status, { expiresInDays: expiry[t] })]),
      ) as Record<DocumentType, AdminDocument>;
    };
    const { vehicle_registration: _missing, ...withoutRegistration } = docs('pending');
    this.driverList = [
      {
        id: 'drv-032',
        reference: 'DR-032',
        name: 'Arnaud Fouda',
        phone: '+237677001032',
        email: 'arnaud.fouda@email.cm',
        submittedAt: this.todayAt(8, 40),
        status: 'under_review',
        vehicle: 'Toyota Corolla',
        plate: 'LT 432 AF',
        online: false,
        documents: {
          ...docs('approved'),
          insurance: doc('insurance', 'pending', {
            expiresInDays: 350,
            file: 'Assurance_Fouda.pdf',
          }),
        },
      },
      {
        id: 'drv-031',
        reference: 'DR-031',
        name: 'Carine Mbida',
        phone: '+237699001031',
        submittedAt: this.dayAt(-1, 16, 15),
        status: 'under_review',
        vehicle: 'Suzuki Swift',
        plate: 'LT 511 CM',
        online: false,
        documents: withoutRegistration,
      },
      {
        id: 'drv-027',
        reference: 'DR-027',
        name: 'Patrick Essomba',
        phone: '+237682334455',
        submittedAt: this.dayAt(-2, 11, 20),
        status: 'approved',
        vehicle: 'Toyota Corolla',
        plate: 'LT 777 ZZ',
        online: true,
        documents: docs('approved', { insurance: 1 }),
      },
      {
        id: 'drv-018',
        reference: 'DR-018',
        name: 'Jean-Paul Mbarga',
        phone: '+237677889900',
        submittedAt: this.dayAt(-160, 10, 30),
        status: 'approved',
        vehicle: 'Toyota Corolla',
        plate: 'LT 123 AB',
        online: true,
        documents: docs('approved'),
      },
      {
        id: 'drv-021',
        reference: 'DR-021',
        name: 'Hervé Ngono',
        phone: '+237677002021',
        submittedAt: this.dayAt(-120, 9, 10),
        status: 'approved',
        vehicle: 'Toyota Yaris',
        plate: 'LT 214 HN',
        online: true,
        documents: docs('approved'),
      },
      {
        id: 'drv-030',
        reference: 'DR-030',
        name: 'Luc Ndjock',
        phone: '+237699003030',
        submittedAt: this.dayAt(-3, 14, 5),
        status: 'action_needed',
        vehicle: 'Toyota Corolla',
        plate: 'LT 630 LN',
        reviewNotes: 'Licence photo unreadable',
        online: false,
        documents: {
          ...docs('approved'),
          driving_licence: doc('driving_licence', 'rejected', { reason: 'Unreadable' }),
        },
      },
    ];

    const car = (
      plate: string,
      make: string,
      model: string,
      category: string,
      fuel: FuelType,
      year: number,
      availability: FleetAvailability,
      driver: string | null,
      location: string,
      o: { ref?: string; start?: number; days?: number; compliance?: number; note?: string } = {},
    ): AdminFleetVehicle => ({
      id: `car-${plate}`,
      plate,
      make,
      model,
      category,
      fuel,
      year,
      availability,
      assignedDriver: driver ?? undefined,
      location,
      bookingRef: o.ref,
      bookingStart: o.start === undefined ? undefined : this.dayAt(o.start, 10, 0),
      bookingEnd: o.start === undefined ? undefined : this.dayAt(o.start + (o.days ?? 3), 10, 0),
      complianceDue: addDays(today, o.compliance ?? 45),
      maintenanceNote: o.note,
    });
    // prettier-ignore
    this.fleetList = [
      car('LT 211 RB', 'Toyota', 'Corolla', 'sedan', 'petrol', 2020, 'reserved', 'Jean-Paul Mbarga', 'Hub Akwa', { ref: 'RN-2048', start: 1, compliance: 45 }),
      car('LT 210 RA', 'Toyota', 'RAV4', 'suv', 'petrol', 2021, 'reserved', 'Hervé Ngono', 'Aéroport de Douala', { ref: 'RN-2049', start: 2, compliance: 120 }),
      car('LT 215 RC', 'Toyota', 'Corolla', 'sedan', 'petrol', 2022, 'reserved', 'Nadège Abena', 'Hub Akwa', { ref: 'RN-2050', start: 0, days: 2, compliance: 82 }),
      car('LT 212 RC', 'Hyundai', 'Tucson', 'suv', 'diesel', 2022, 'on_rental', 'Eric Mvondo', 'Customer use', { ref: 'RN-2044', start: -2, compliance: 73 }),
      car('LT 216 RD', 'Toyota', 'Corolla', 'sedan', 'petrol', 2022, 'return_today', 'Serge Talla', 'Aéroport de Douala', { ref: 'RN-2042', start: -3, compliance: 153 }),
      car('LT 213 RD', 'Toyota', 'Land Cruiser Prado', 'suv', 'diesel', 2019, 'maintenance', null, 'Garage Ndokoti', { compliance: 0, note: 'Tyre replacement and inspection' }),
      car('LT 217 RE', 'Toyota', 'RAV4', 'suv', 'petrol', 2021, 'available', null, 'Dépôt Bonapriso', { compliance: 200 }),
    ];

    const quote = 'Je ne me sens pas en sécurité à ce point de départ.';
    this.caseList = [
      {
        id: 'case-091',
        kind: 'alert',
        reference: 'SA-091',
        severity: 'high',
        category: 'rider_sos',
        createdAt: this.todayAt(9, 40),
        status: 'open',
        rideRef: 'RD-1043',
        personName: 'Aïcha Ngo Mbappe',
        place: '12 Rue Joss, Akwa',
        note: quote,
        riderName: 'Aïcha Ngo Mbappe',
        riderPhone: '+237671234567',
        driverName: 'Jean-Paul Mbarga',
        driverPhone: '+237677889900',
        location: COORDS.Akwa,
        events: [
          {
            title: 'Rider requested a safety callback',
            detail: `“${quote}”`,
            at: this.todayAt(9, 40),
          },
          {
            title: 'Alert received by operations',
            detail: 'Location attached · No emergency dispatch',
            at: this.todayAt(9, 40),
          },
        ],
      },
      {
        id: 'case-090',
        kind: 'incident',
        reference: 'SA-090',
        severity: 'medium',
        category: 'route_deviation',
        createdAt: this.todayAt(9, 26),
        status: 'acknowledged',
        rideRef: 'RD-1036',
        personName: 'Brice Nkoulou',
        place: 'Makepe',
        assigneeId: 'admin-2',
        assigneeName: 'Maya Ekambi',
        riderName: 'Brice Nkoulou',
        riderPhone: '+237699112244',
        driverName: 'Eric Mvondo',
        driverPhone: '+237677003040',
        location: COORDS.Makepe,
        events: [{ title: 'Driver reported a route deviation', at: this.todayAt(9, 26) }],
      },
      {
        id: 'case-089',
        kind: 'incident',
        reference: 'SA-089',
        severity: 'medium',
        category: 'vehicle_damage',
        createdAt: this.todayAt(9, 12),
        status: 'acknowledged',
        rentalRef: 'RN-2040',
        personName: 'Ruth Ndongo',
        place: 'Aéroport de Douala',
        assigneeId: 'admin-3',
        assigneeName: 'Joël Nana',
        events: [{ title: 'Rental condition dispute at return', at: this.todayAt(9, 12) }],
      },
      {
        id: 'case-088',
        kind: 'incident',
        reference: 'SA-088',
        severity: 'low',
        category: 'lost_item',
        createdAt: this.dayAt(-1, 18, 5),
        status: 'resolved',
        rideRef: 'RD-1021',
        personName: 'Ines Kamga',
        place: 'Bonanjo',
        assigneeId: 'admin-1',
        assigneeName: 'Nadine Eyenga',
        resolutionNote: 'Phone returned to the rider at the Akwa hub.',
        events: [{ title: 'Lost phone reported', at: this.dayAt(-1, 18, 5) }],
      },
    ];

    const tx = (
      ref: string,
      kind: TransactionKind,
      booking: string,
      party: string,
      method: string,
      day: number,
      h: number,
      m: number,
      amount: number,
      status: string,
      tone: AdminTransaction['tone'],
      refundable = false,
    ): AdminTransaction => ({
      id: `tx-${ref}`,
      reference: ref,
      kind,
      bookingRef: booking,
      party,
      method,
      at: this.dayAt(day, h, m),
      amount,
      status,
      tone,
      paymentId: refundable ? `tx-${ref}` : undefined,
      refundable,
    });
    // prettier-ignore
    this.txList = [
      tx('TX-8801', 'ride_payment', 'RD-1042', 'Aïcha Ngo Mbappe', 'MTN MoMo •••• 4567', 0, 9, 22, 3100, 'succeeded', 'success', true),
      tx('TX-8800', 'ride_payment', 'RD-1041', 'Grâce Mballa', 'MTN MoMo •••• 2291', 0, 9, 10, 500, 'succeeded', 'success', true),
      tx('TX-8794', 'rental_payment', 'RN-2048', 'Aïcha Ngo Mbappe', 'MTN MoMo •••• 4567', -1, 16, 32, 89000, 'succeeded', 'success'),
      tx('DH-2048', 'deposit_hold', 'RN-2048', 'Aïcha Ngo Mbappe', 'MTN MoMo •••• 4567', -1, 16, 32, 100000, 'held', 'neutral'),
      tx('RF-0214', 'refund', 'RN-2038', 'Samuel Ekane', 'Original method', -1, 14, 10, -55000, 'processing', 'neutral'),
      tx('PO-071', 'payout', '5–11 Oct', 'Jean-Paul Mbarga', 'MTN MoMo •••• 9900', -2, 10, 15, -132800, 'paid', 'success'),
    ];
  }

  // -------------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------------

  private async read<T>(value: T): Promise<T> {
    if (this.latency) await wait(this.latency);
    return structuredClone(value);
  }

  overview(): Promise<AdminOverview> {
    const today = doualaDay(this.now);
    const rides = [1120, 1240, 1180, 1460, 1350, 1580, 1284];
    const rentals = [48, 61, 52, 70, 60, 76, 63];
    return this.read({
      ridesToday: 1284,
      ridesYesterday: 1187,
      activeRentals: this.rentalList.filter((r) => r.status === 'active').length + 84,
      pickupsToday: 12,
      returnsToday: 9,
      revenueToday: 4_936_000,
      revenueYesterday: 4_383_000,
      driversOnline: 248,
      driversOnTrip: 62,
      ridesInProgress: 62,
      daily: rides.map((n, i) => ({ day: addDays(today, i - 6), rides: n, rentals: rentals[i]! })),
      openAlerts: this.caseList.filter((c) => c.status !== 'resolved').length,
      expiring: [{ driverRef: 'DR-027', type: 'insurance', expiresOn: addDays(today, 1) }],
    });
  }

  liveDrivers(): Promise<LiveDriver[]> {
    return this.read<LiveDriver[]>([
      {
        id: 'drv-018',
        name: 'Jean-Paul Mbarga',
        at: { lat: 4.0505, lng: 9.6966 },
        state: 'to_pickup',
      },
      { id: 'drv-021', name: 'Hervé Ngono', at: { lat: 4.044, lng: 9.703 }, state: 'on_trip' },
      { id: 'drv-022', name: 'Serge Talla', at: { lat: 4.064, lng: 9.707 }, state: 'on_trip' },
      { id: 'drv-024', name: 'Eric Mvondo', at: { lat: 4.058, lng: 9.725 }, state: 'on_trip' },
      { id: 'drv-023', name: 'Nadège Abena', at: { lat: 4.033, lng: 9.693 }, state: 'available' },
    ]);
  }

  rides() {
    return this.read(this.rideList);
  }

  rideDetail(rideId: string): Promise<AdminRideDetail> {
    const r = this.rideList.find((x) => x.id === rideId);
    if (!r) return Promise.reject(new BackendError('ride_not_found'));
    const t0 = r.requestedAt.getTime();
    const at = (min: number) => new Date(t0 + min * 60_000);
    const done = r.status === 'completed';
    const tx = this.txList.find((x) => x.bookingRef === r.reference && x.paymentId);
    const timeline: TimelineEntry[] = [
      {
        title: 'Ride requested',
        detail: `${r.riderName} · ${METHOD_LABEL[r.method]} authorised`,
        at: r.requestedAt,
      },
    ];
    if (r.driverName)
      timeline.push({
        title: 'Driver accepted',
        detail: `${r.driverName} · ${r.vehicle} ${r.plate}`,
        at: at(1),
      });
    if (done || r.status === 'in_progress')
      timeline.push({
        title: `Pickup · ${r.pickup.name}`,
        detail: 'Rider PIN verified · Journey started',
        at: at(4),
      });
    if (done)
      timeline.push({
        title: `Drop-off · ${r.dropoff.name}`,
        detail: `${r.dropoff.address} · Payment captured`,
        at: at(22),
      });
    return this.read({
      ride: r,
      rider: {
        name: r.riderName,
        reference: 'RI-0128',
        phone: '+237671234567',
        email: `${r.riderName.split(' ')[0]!.toLowerCase()}@email.cm`,
        rating: 4.9,
      },
      driver: r.driverName
        ? {
            name: r.driverName,
            reference: this.driverList.find((d) => d.name === r.driverName)?.reference ?? 'DR-018',
            phone: '+237677889900',
            rating: 4.9,
            detail: `${r.vehicle} · ${r.plate}`,
          }
        : undefined,
      timeline,
      baseFare: 500,
      distanceTimeFare: r.fare - 700,
      adjustments: 200,
      paymentId: tx?.paymentId,
      paymentReference: tx?.reference,
      capturedAt: done ? at(22) : undefined,
      refundedAmount: this.refunded.get(tx?.paymentId ?? '') ?? 0,
      incidents: this.caseList.filter((c) => c.rideRef === r.reference).length,
      riderRatingGiven: done ? 5 : undefined,
      receiptAt: done ? at(22) : undefined,
    });
  }

  rentals() {
    return this.read(this.rentalList);
  }

  drivers() {
    return this.read(this.driverList);
  }

  async documentUrl() {
    return null;
  }

  fleet() {
    return this.read(this.fleetList);
  }

  safetyCases() {
    return this.read(this.caseList);
  }

  paymentsSummary(): Promise<PaymentsSummary> {
    const rides = [1_850_000, 2_020_000, 2_210_000, 2_390_000, 2_440_000, 2_610_000, 2_700_000];
    const rentals = [420_000, 380_000, 450_000, 410_000, 430_000, 470_000, 445_000];
    const today = doualaDay(this.now);
    return this.read({
      daily: rides.map((n, i) => ({ day: addDays(today, i - 6), rides: n, rentals: rentals[i]! })),
      capturedToday: 4_936_000,
      refundsProcessing: this.txList
        .filter((t) => t.kind === 'refund' && t.status !== 'refunded')
        .reduce((s, t) => s - t.amount, 0),
      depositHolds: 1_680_000,
      nextPayout: 3_684_000,
    });
  }

  transactions() {
    return this.read(this.txList);
  }

  // -------------------------------------------------------------------------
  // Writes
  // -------------------------------------------------------------------------

  async decideDriver(
    driverId: string,
    d: { approve: boolean; note?: string; rejectDocument?: DocumentType },
  ) {
    await wait(this.latency);
    const i = this.driverList.findIndex((x) => x.id === driverId);
    const driver = this.driverList[i];
    if (!driver) throw new BackendError('driver_not_found');
    if (!d.approve && !d.note?.trim()) throw new BackendError('note_required');
    const docs = { ...driver.documents };
    if (d.approve) {
      if (Object.values(docs).some((x) => x?.status === 'rejected')) {
        throw new BackendError('documents_rejected');
      }
      for (const [k, x] of Object.entries(docs)) {
        if (x?.status === 'pending') docs[k as DocumentType] = { ...x, status: 'approved' };
      }
    } else if (d.rejectDocument && docs[d.rejectDocument]) {
      docs[d.rejectDocument] = {
        ...docs[d.rejectDocument]!,
        status: 'rejected',
        rejectionReason: d.note,
      };
    }
    this.driverList[i] = {
      ...driver,
      status: d.approve ? 'approved' : 'action_needed',
      documents: docs,
      reviewNotes: d.note,
    };
  }

  async setVehicleStatus(vehicleId: string, status: RentalVehicleStatus, note?: string) {
    await wait(this.latency);
    const i = this.fleetList.findIndex((v) => v.id === vehicleId);
    const v = this.fleetList[i];
    if (!v) throw new BackendError('vehicle_not_found');
    if (status === 'maintenance' && !note?.trim()) throw new BackendError('note_required');
    this.fleetList[i] = {
      ...v,
      availability: status,
      assignedDriver: undefined,
      bookingRef: undefined,
      bookingStart: undefined,
      bookingEnd: undefined,
      maintenanceNote: status === 'maintenance' ? note : undefined,
    };
  }

  async addVehicle(v: NewRentalVehicle) {
    await wait(this.latency);
    const plate = v.plate.trim().toUpperCase();
    if (this.fleetList.some((x) => x.plate === plate)) throw new BackendError('plate_taken');
    this.fleetList.unshift({
      id: `car-${plate}`,
      plate,
      make: v.make,
      model: v.model,
      category: v.category,
      fuel: v.fuel,
      year: v.year,
      availability: 'available',
      location: v.homeLocation,
      complianceDue: addDays(doualaDay(this.now), 365),
    });
  }

  async updateSafetyCase(
    c: SafetyCase,
    u: { assignTo?: string; status?: AlertStatus; note?: string },
  ) {
    await wait(this.latency);
    if (u.status === 'resolved' && !u.note?.trim()) throw new BackendError('note_required');
    const i = this.caseList.findIndex((x) => x.id === c.id);
    const x = this.caseList[i];
    if (!x) throw new BackendError('case_not_found');
    const assignee = u.assignTo ? TEAM.find((a) => a.id === u.assignTo) : undefined;
    if (u.assignTo && !assignee) throw new BackendError('assignee_not_admin');
    const now = new Date();
    const events = [...x.events];
    if (assignee) events.push({ title: `Assigned to ${assignee.name}`, at: now });
    if (u.status) events.push({ title: `Status: ${u.status}`, detail: u.note, at: now });
    else if (u.note?.trim()) events.push({ title: 'Note added', detail: u.note, at: now });
    this.caseList[i] = {
      ...x,
      status: u.status ?? (assignee && x.status === 'open' ? 'acknowledged' : x.status),
      assigneeId: assignee?.id ?? x.assigneeId,
      assigneeName: assignee?.name ?? x.assigneeName,
      resolutionNote: u.status === 'resolved' ? u.note : x.resolutionNote,
      events,
    };
    if (u.status === 'resolved' && x.rideRef) {
      for (const r of this.rideList) if (r.reference === x.rideRef) r.hasOpenAlert = false;
    }
  }

  async requestRefund(paymentId: string, amount: number, reason: string) {
    await wait(this.latency);
    const t = this.txList.find((x) => x.paymentId === paymentId);
    if (!t) throw new BackendError('payment_not_refundable');
    const already = this.refunded.get(paymentId) ?? 0;
    if (!Number.isInteger(amount) || amount <= 0 || amount > t.amount - already) {
      throw new BackendError('invalid_refund_amount');
    }
    if (reason.trim().length < 3) throw new BackendError('invalid_request');
    this.refunded.set(paymentId, already + amount);
    if (already + amount >= t.amount) t.refundable = false;
    this.txList.unshift({
      id: `rf-${this.txList.length}`,
      reference: `RF-${String(215 + this.txList.length).padStart(4, '0')}`,
      kind: 'refund',
      bookingRef: t.bookingRef,
      party: t.party,
      method: 'Original method',
      at: new Date(),
      amount: -amount,
      status: 'requested',
      tone: 'neutral',
      refundable: false,
    });
  }
}
