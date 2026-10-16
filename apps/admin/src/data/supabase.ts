// Operations dashboard on Supabase: reads under the "admins read all" RLS policies, writes through
// the admin_* RPCs (which call _require_admin). Lists load the latest 200 rows; filtering and
// paging happen in the browser.
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@iyodriver/core/src/supabase/database.types';

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
  type CaseSeverity,
  type DocumentType,
  type FleetAvailability,
  type LiveDriver,
  type NewRentalVehicle,
  type PaymentsSummary,
  type Place,
  type RentalVehicleStatus,
  type SafetyCase,
  type TransactionKind,
} from './models';
import type { AdminRepository, ChangeTopic } from './repository';
import { fromIsoDay, isoDay, sameDoualaDay } from './time';

type Row = Record<string, unknown>;

const obj = (v: unknown): Row | undefined =>
  Array.isArray(v)
    ? (v[0] as Row | undefined)
    : v && typeof v === 'object'
      ? (v as Row)
      : undefined;
const list = (v: unknown): Row[] => (Array.isArray(v) ? (v as Row[]) : []);
const str = (v: unknown): string | undefined => (typeof v === 'string' ? v : undefined);
const num = (v: unknown): number => (typeof v === 'number' ? v : Number(v ?? 0) || 0);
const date = (v: unknown): Date | undefined => (typeof v === 'string' ? new Date(v) : undefined);
const name = (v: unknown) => str(obj(v)?.full_name);

/** `raise exception 'note_required: …'` → `note_required`. */
function toBackendError(e: unknown): BackendError {
  if (e instanceof BackendError) return e;
  const message =
    e && typeof e === 'object' && 'message' in e && typeof e.message === 'string' ? e.message : '';
  const code = message.split(':')[0]?.trim() ?? '';
  return new BackendError(/^[a-z_]+$/.test(code) ? code : 'internal_error', message);
}

async function run<T>(f: () => PromiseLike<{ data: T; error: unknown }>): Promise<T> {
  const { data, error } = await f();
  if (error) throw toBackendError(error);
  return data;
}

const METHOD: Record<string, string> = {
  mtn_momo: 'MTN MoMo',
  orange_money: 'Orange Money',
  cash: 'Cash',
  card: 'Card',
};

const RIDE_SELECT =
  'id, reference, requested_at, status, pickup_address, pickup_lat, pickup_lng, dropoff_address, ' +
  'dropoff_lat, dropoff_lng, fare_amount, payment_method, category_code, distance_m, duration_s, ' +
  'driver_earnings, rider:profiles!rides_rider_id_fkey(full_name), ' +
  'driver:driver_profiles!rides_driver_id_fkey(reference, profile:profiles!driver_profiles_user_id_fkey(full_name)), ' +
  'vehicle:vehicles(plate, make, model), payments(id, reference, status, purpose, confirmed_at), ' +
  'alerts:safety_alerts(status)';

function place(address: unknown, lat: unknown, lng: unknown): Place {
  const a = str(address) ?? '';
  return {
    name: a.split(',')[0]?.trim() ?? a,
    address: a,
    location: lat == null ? undefined : { lat: num(lat), lng: num(lng) },
  };
}

function rideFrom(r: Row): AdminRide {
  const vehicle = obj(r.vehicle);
  const fare = list(r.payments).find((p) => p.purpose === 'ride_fare');
  return {
    id: str(r.id)!,
    reference: str(r.reference)!,
    requestedAt: date(r.requested_at)!,
    riderName: name(r.rider) ?? '',
    driverName: name(obj(r.driver)?.profile),
    plate: str(vehicle?.plate),
    vehicle: vehicle ? `${vehicle.make} ${vehicle.model}` : undefined,
    pickup: place(r.pickup_address, r.pickup_lat, r.pickup_lng),
    dropoff: place(r.dropoff_address, r.dropoff_lat, r.dropoff_lng),
    status: r.status as AdminRide['status'],
    fare: num(r.fare_amount),
    method: r.payment_method as AdminRide['method'],
    paymentStatus: fare ? (fare.status as AdminRide['paymentStatus']) : undefined,
    categoryCode: str(r.category_code) ?? '',
    distanceMeters: num(r.distance_m),
    durationSeconds: num(r.duration_s),
    driverEarnings: num(r.driver_earnings),
    hasOpenAlert: list(r.alerts).some((a) => a.status !== 'resolved'),
  };
}

const URGENT = ['accident', 'theft_or_aggression', 'pickup_pin_locked', 'handover_pin_locked'];

export class SupabaseAdminBackend implements AdminRepository {
  readonly isDemo = false;
  private readonly db: SupabaseClient<Database>;

  constructor(url: string, anonKey: string) {
    this.db = createClient<Database>(url, anonKey, {
      auth: { persistSession: true, autoRefreshToken: true },
      global: { headers: { 'x-client-info': 'iyodriver-admin' } },
    });
  }

  /** Untyped query builder: the embeds below are checked by the database, not by TypeScript. */
  private from(table: string) {
    return (this.db as unknown as SupabaseClient).from(table);
  }

  private rpc(fn: string, params?: Row) {
    return run(() => (this.db as unknown as SupabaseClient).rpc(fn, params));
  }

  // -------------------------------------------------------------------------
  // Auth: email + password; only profiles with role 'admin' get in.
  // -------------------------------------------------------------------------

  private async loadAdmin(): Promise<AdminProfile | null> {
    const { data } = await this.db.auth.getSession();
    const uid = data.session?.user.id;
    if (!uid) return null;
    const p = await run(() =>
      this.from('profiles').select('id, full_name, role').eq('id', uid).maybeSingle(),
    );
    if (!p || (p as Row).role !== 'admin') return null;
    return { id: uid, name: str((p as Row).full_name) ?? '' };
  }

  watchAdmin(listener: (a: AdminProfile | null) => void) {
    let alive = true;
    const push = () =>
      void this.loadAdmin()
        .catch(() => null)
        .then((a) => alive && listener(a));
    push();
    const { data } = this.db.auth.onAuthStateChange((event) => {
      // Defer: Supabase must finish its own auth work before we query.
      if (event !== 'TOKEN_REFRESHED') setTimeout(push, 0);
    });
    return () => {
      alive = false;
      data.subscription.unsubscribe();
    };
  }

  async signIn(email: string, password: string) {
    const { error } = await this.db.auth.signInWithPassword({ email: email.trim(), password });
    if (error) throw new BackendError('invalid_credentials', error.message);
    if (!(await this.loadAdmin())) {
      await this.db.auth.signOut();
      throw new BackendError('wrong_role');
    }
  }

  async signOut() {
    await this.db.auth.signOut();
  }

  async admins() {
    const rows = await run(() =>
      this.from('profiles').select('id, full_name').eq('role', 'admin').order('full_name'),
    );
    return list(rows).map((r) => ({ id: str(r.id)!, name: str(r.full_name) ?? '' }));
  }

  // -------------------------------------------------------------------------
  // Overview and live operations
  // -------------------------------------------------------------------------

  async overview(): Promise<AdminOverview> {
    const o = (await this.rpc('admin_overview')) as Row;
    return {
      ridesToday: num(o.rides_today),
      ridesYesterday: num(o.rides_yesterday),
      activeRentals: num(o.active_rentals),
      pickupsToday: num(o.pickups_today),
      returnsToday: num(o.returns_today),
      revenueToday: num(o.revenue_today),
      revenueYesterday: num(o.revenue_yesterday),
      driversOnline: num(o.drivers_online),
      driversOnTrip: num(o.drivers_on_trip),
      ridesInProgress: num(o.rides_in_progress),
      openAlerts: num(o.open_alerts),
      daily: list(o.daily).map((d) => ({
        day: fromIsoDay(str(d.day)!),
        rides: num(d.rides),
        rentals: num(d.rentals),
      })),
      expiring: list(o.documents_expiring).map((d) => ({
        driverRef: str(d.driver_ref) ?? '',
        type: d.type as DocumentType,
        expiresOn: fromIsoDay(str(d.expires_on)!),
      })),
    };
  }

  async liveDrivers(): Promise<LiveDriver[]> {
    const locs = await run(() =>
      this.from('driver_locations')
        .select(
          'driver_id, lat, lng, driver:driver_profiles(profile:profiles!driver_profiles_user_id_fkey(full_name))',
        )
        .eq('is_online', true)
        .limit(500),
    );
    const active = await run(() =>
      this.from('rides')
        .select('driver_id, status')
        .in('status', ['driver_assigned', 'driver_arriving', 'driver_arrived', 'in_progress']),
    );
    const state = new Map(
      list(active).map(
        (r) => [str(r.driver_id), r.status === 'in_progress' ? 'on_trip' : 'to_pickup'] as const,
      ),
    );
    return list(locs).map((l) => ({
      id: str(l.driver_id)!,
      name: name(obj(l.driver)?.profile) ?? '',
      at: { lat: num(l.lat), lng: num(l.lng) },
      state: state.get(str(l.driver_id)) ?? 'available',
    }));
  }

  // -------------------------------------------------------------------------
  // Rides
  // -------------------------------------------------------------------------

  async rides() {
    const rows = await run(() =>
      this.from('rides').select(RIDE_SELECT).order('requested_at', { ascending: false }).limit(200),
    );
    return list(rows).map(rideFrom);
  }

  async rideDetail(rideId: string): Promise<AdminRideDetail> {
    const r = (await run(() =>
      this.from('rides')
        .select(
          `${RIDE_SELECT}, completed_at, quote:fare_quotes(breakdown), ` +
            'rider_profile:profiles!rides_rider_id_fkey(phone, rating), ' +
            'driver_profile:driver_profiles!rides_driver_id_fkey(profile:profiles!driver_profiles_user_id_fkey(phone, rating)), ' +
            'events:ride_events(to_status, created_at), ratings(rater_role, stars)',
        )
        .eq('id', rideId)
        .single(),
    )) as Row;
    const ride = rideFrom(r);
    const b = obj(obj(r.quote)?.breakdown) ?? {};
    const base = Math.round(num(b.base_fare));
    const distTime = Math.round(num(b.distance_amount)) + Math.round(num(b.duration_amount));
    const pay = list(r.payments).find((p) => p.purpose === 'ride_fare');
    const refunds = pay
      ? list(
          await run(() =>
            this.from('refunds').select('amount, status').eq('payment_id', str(pay.id)!),
          ),
        )
      : [];
    const alerts = list(
      await run(() => this.from('safety_alerts').select('id').eq('ride_id', rideId)),
    );
    const incidents = list(
      await run(() => this.from('incident_reports').select('id').eq('ride_id', rideId)),
    );
    const riderP = obj(r.rider_profile);
    const driverP = obj(obj(r.driver_profile)?.profile);
    const title = (s: string) =>
      ({
        requested: 'Ride requested',
        driver_assigned: 'Driver accepted',
        driver_arriving: 'Driver on the way',
        driver_arrived: 'Driver at pickup',
        in_progress: `Pickup · ${ride.pickup.name}`,
        completed: `Drop-off · ${ride.dropoff.name}`,
        cancelled_by_rider: 'Cancelled by rider',
        cancelled_by_driver: 'Cancelled by driver',
        no_drivers_found: 'No driver found',
      })[s] ?? s;
    const rating = list(r.ratings).find((x) => x.rater_role === 'rider');
    return {
      ride,
      rider: {
        name: ride.riderName,
        reference: `RI-${rideId.slice(0, 4).toUpperCase()}`,
        phone: str(riderP?.phone),
        rating: riderP?.rating == null ? undefined : num(riderP.rating),
      },
      driver: ride.driverName
        ? {
            name: ride.driverName,
            reference: str(obj(r.driver)?.reference) ?? '',
            phone: str(driverP?.phone),
            rating: driverP?.rating == null ? undefined : num(driverP.rating),
            detail: `${ride.vehicle ?? ''} · ${ride.plate ?? ''}`,
          }
        : undefined,
      timeline: list(r.events)
        .sort((a, c) => String(a.created_at).localeCompare(String(c.created_at)))
        .map((e) => ({ title: title(str(e.to_status) ?? ''), at: date(e.created_at)! })),
      baseFare: base,
      distanceTimeFare: distTime,
      adjustments: ride.fare - base - distTime,
      paymentId: str(pay?.id),
      paymentReference: str(pay?.reference),
      capturedAt: date(pay?.confirmed_at),
      refundedAmount: refunds
        .filter((x) => x.status !== 'rejected')
        .reduce((s, x) => s + num(x.amount), 0),
      incidents: alerts.length + incidents.length,
      riderRatingGiven: rating ? num(rating.stars) : undefined,
      receiptAt: date(r.completed_at),
    };
  }

  // -------------------------------------------------------------------------
  // Rentals
  // -------------------------------------------------------------------------

  async rentals(): Promise<AdminRental[]> {
    const rows = await run(() =>
      this.from('rental_bookings')
        .select(
          'id, reference, status, starts_at, ends_at, pickup_address, airport_code, terminal, flight_number, ' +
            'flight_arrival_at, total_amount, deposit_amount, vehicle_id, ' +
            'rider:profiles!rental_bookings_rider_id_fkey(full_name), vehicle:rental_vehicles(make, model, plate), ' +
            'driver:driver_profiles!rental_bookings_assigned_driver_id_fkey(profile:profiles!driver_profiles_user_id_fkey(full_name)), ' +
            'payments(id, refunds(status))',
        )
        .order('starts_at', { ascending: false })
        .limit(200),
    );
    return list(rows).map((r) => {
      const v = obj(r.vehicle);
      return {
        id: str(r.id)!,
        reference: str(r.reference)!,
        customer: name(r.rider) ?? '',
        vehicle: `${v?.make ?? ''} ${v?.model ?? ''}`.trim(),
        plate: str(v?.plate) ?? '',
        startsAt: date(r.starts_at)!,
        endsAt: date(r.ends_at)!,
        place: str(r.pickup_address) ?? '',
        airportCode: str(r.airport_code),
        terminal: str(r.terminal),
        flightNumber: str(r.flight_number),
        flightArrivalAt: date(r.flight_arrival_at),
        status: r.status as AdminRental['status'],
        totalAmount: num(r.total_amount),
        depositAmount: num(r.deposit_amount),
        assignedDriver: name(obj(r.driver)?.profile),
        refunded: list(r.payments).some((p) =>
          list(p.refunds).some((x) => x.status === 'refunded'),
        ),
        vehicleId: str(r.vehicle_id),
      };
    });
  }

  // -------------------------------------------------------------------------
  // Drivers
  // -------------------------------------------------------------------------

  async drivers(): Promise<AdminDriver[]> {
    const rows = await run(() =>
      this.from('driver_profiles')
        .select(
          'user_id, reference, verification_status, submitted_at, review_notes, ' +
            'profile:profiles!driver_profiles_user_id_fkey(full_name, phone), ' +
            'vehicles(make, model, plate, status), ' +
            'documents:driver_documents(type, status, expires_on, storage_path, created_at, updated_at, rejection_reason), ' +
            'location:driver_locations(is_online)',
        )
        .order('submitted_at', { ascending: false, nullsFirst: false })
        .limit(200),
    );
    return list(rows).map((r) => {
      const v = list(r.vehicles)[0];
      const documents: AdminDriver['documents'] = {};
      for (const d of list(r.documents)) {
        const doc: AdminDocument = {
          type: d.type as DocumentType,
          status: d.status as AdminDocument['status'],
          expiresOn: d.expires_on ? fromIsoDay(str(d.expires_on)!) : undefined,
          storagePath: str(d.storage_path),
          fileName: str(d.storage_path)?.split('/').pop(),
          uploadedAt: date(d.updated_at ?? d.created_at),
          rejectionReason: str(d.rejection_reason),
        };
        documents[doc.type] = doc;
      }
      return {
        id: str(r.user_id)!,
        reference: str(r.reference)!,
        name: name(r.profile) ?? '',
        phone: str(obj(r.profile)?.phone),
        submittedAt: date(r.submitted_at),
        status: r.verification_status as AdminDriver['status'],
        reviewNotes: str(r.review_notes),
        vehicle: v ? `${v.make} ${v.model}` : undefined,
        plate: str(v?.plate),
        online: obj(r.location)?.is_online === true,
        documents,
      };
    });
  }

  async decideDriver(
    driverId: string,
    d: { approve: boolean; note?: string; rejectDocument?: DocumentType },
  ) {
    await this.rpc('admin_decide_driver', {
      p_driver_id: driverId,
      p_approve: d.approve,
      p_note: d.note ?? null,
      p_reject_document: d.rejectDocument ?? null,
    });
  }

  async documentUrl(storagePath: string) {
    const { data, error } = await this.db.storage
      .from('driver-documents')
      .createSignedUrl(storagePath, 300);
    if (error) throw toBackendError(error);
    return data.signedUrl;
  }

  // -------------------------------------------------------------------------
  // Fleet
  // -------------------------------------------------------------------------

  async fleet(): Promise<AdminFleetVehicle[]> {
    const rows = await run(() =>
      this.from('rental_vehicles')
        .select(
          'id, plate, make, model, category, fuel_type, year, status, home_location, compliance_due, ' +
            'maintenance_note, bookings:rental_bookings(reference, status, starts_at, ends_at, ' +
            'driver:driver_profiles!rental_bookings_assigned_driver_id_fkey(profile:profiles!driver_profiles_user_id_fkey(full_name)))',
        )
        .order('plate'),
    );
    const now = new Date();
    return list(rows).map((r) => {
      const b = list(r.bookings)
        .filter(
          (x) => !['cancelled', 'completed'].includes(String(x.status)) && date(x.ends_at)! > now,
        )
        .sort((a, c) => String(a.starts_at).localeCompare(String(c.starts_at)))[0];
      let availability: FleetAvailability;
      if (r.status === 'maintenance') availability = 'maintenance';
      else if (r.status === 'retired') availability = 'retired';
      else if (!b) availability = 'available';
      else if (b.status === 'active' || b.status === 'return_pending')
        availability = sameDoualaDay(date(b.ends_at)!, now) ? 'return_today' : 'on_rental';
      else availability = 'reserved';
      return {
        id: str(r.id)!,
        plate: str(r.plate)!,
        make: str(r.make)!,
        model: str(r.model)!,
        category: str(r.category) ?? '',
        fuel: r.fuel_type as AdminFleetVehicle['fuel'],
        year: r.year == null ? undefined : num(r.year),
        availability,
        location: availability === 'on_rental' ? 'Customer use' : str(r.home_location),
        assignedDriver: name(obj(b?.driver)?.profile),
        bookingRef: str(b?.reference),
        bookingStart: date(b?.starts_at),
        bookingEnd: date(b?.ends_at),
        complianceDue: r.compliance_due ? fromIsoDay(str(r.compliance_due)!) : undefined,
        maintenanceNote: str(r.maintenance_note),
      };
    });
  }

  async setVehicleStatus(vehicleId: string, status: RentalVehicleStatus, note?: string) {
    await this.rpc('admin_set_rental_vehicle_status', {
      p_vehicle_id: vehicleId,
      p_status: status,
      p_note: note ?? null,
    });
  }

  async addVehicle(v: NewRentalVehicle) {
    await this.rpc('admin_add_rental_vehicle', {
      p_city_code: v.cityCode,
      p_make: v.make,
      p_model: v.model,
      p_year: v.year,
      p_category: v.category,
      p_transmission: v.transmission,
      p_seats: v.seats,
      p_fuel_type: v.fuel,
      p_plate: v.plate,
      p_color: v.color,
      p_daily_rate: v.dailyRate,
      p_deposit_amount: v.deposit,
      p_km_per_day: v.kmPerDay,
      p_airport_pickup: v.airportPickup,
      p_home_location: v.homeLocation ?? null,
    });
  }

  // -------------------------------------------------------------------------
  // Safety
  // -------------------------------------------------------------------------

  async safetyCases(): Promise<SafetyCase[]> {
    const people = (t: string) =>
      `rider:profiles!${t}_rider_id_fkey(full_name, phone), driver:profiles!${t}_driver_id_fkey(full_name, phone), ` +
      `assignee:profiles!${t}_assigned_to_fkey(id, full_name)`;
    const events = 'events:safety_case_events(kind, status, note, created_at)';
    const alerts = await run(() =>
      this.from('safety_alerts')
        .select(
          'id, reference, reason, note, status, created_at, resolution_note, ' +
            `ride:rides(reference, pickup_address, pickup_lat, pickup_lng), ${people('safety_alerts')}, ${events}`,
        )
        .order('created_at', { ascending: false })
        .limit(100),
    );
    const incidents = await run(() =>
      this.from('incident_reports')
        .select(
          'id, reference, category, description, is_urgent, status, created_at, resolution_note, ' +
            'ride:rides(reference, pickup_address, pickup_lat, pickup_lng), rental:rental_bookings(reference, pickup_address), ' +
            `${people('incident_reports')}, ${events}`,
        )
        .order('created_at', { ascending: false })
        .limit(100),
    );

    const build = (r: Row, kind: 'alert' | 'incident'): SafetyCase => {
      const ride = obj(r.ride);
      const rental = obj(r.rental);
      const rider = obj(r.rider);
      const driver = obj(r.driver);
      const assignee = obj(r.assignee);
      const category = kind === 'alert' ? (str(r.reason) ?? 'rider_sos') : str(r.category)!;
      const severity: CaseSeverity =
        kind === 'alert' || r.is_urgent === true || URGENT.includes(category)
          ? 'high'
          : ['lost_item', 'payment'].includes(category)
            ? 'low'
            : 'medium';
      const note = kind === 'alert' ? str(r.note) : str(r.description);
      const created = date(r.created_at)!;
      return {
        id: str(r.id)!,
        kind,
        reference: str(r.reference)!,
        severity,
        category,
        createdAt: created,
        status: r.status as AlertStatus,
        rideRef: str(ride?.reference),
        rentalRef: str(rental?.reference),
        personName: str((kind === 'alert' ? rider : driver)?.full_name),
        place: str(ride?.pickup_address ?? rental?.pickup_address),
        note,
        assigneeId: str(assignee?.id),
        assigneeName: str(assignee?.full_name),
        riderName: str(rider?.full_name),
        riderPhone: str(rider?.phone),
        driverName: str(driver?.full_name),
        driverPhone: str(driver?.phone),
        location:
          ride?.pickup_lat == null
            ? undefined
            : { lat: num(ride.pickup_lat), lng: num(ride.pickup_lng) },
        resolutionNote: str(r.resolution_note),
        events: [
          {
            title: kind === 'alert' ? 'Rider raised a safety alert' : 'Incident reported',
            detail: note ? `“${note}”` : undefined,
            at: created,
          },
          ...list(r.events)
            .sort((a, b) => String(a.created_at).localeCompare(String(b.created_at)))
            .map((e) => ({
              title:
                e.kind === 'assigned'
                  ? `Assigned to ${str(e.note) ?? ''}`
                  : e.kind === 'status'
                    ? `Status: ${str(e.status)}`
                    : 'Note added',
              detail: e.kind === 'assigned' ? undefined : str(e.note),
              at: date(e.created_at)!,
            })),
        ],
      };
    };

    return [
      ...list(alerts).map((r) => build(r, 'alert')),
      ...list(incidents).map((r) => build(r, 'incident')),
    ].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  async updateSafetyCase(
    c: SafetyCase,
    u: { assignTo?: string; status?: AlertStatus; note?: string },
  ) {
    await this.rpc('admin_update_safety_case', {
      p_kind: c.kind,
      p_id: c.id,
      p_assign_to: u.assignTo ?? null,
      p_status: u.status ?? null,
      p_note: u.note ?? null,
    });
  }

  // -------------------------------------------------------------------------
  // Payments
  // -------------------------------------------------------------------------

  async paymentsSummary(from: Date, to: Date): Promise<PaymentsSummary> {
    const s = (await this.rpc('admin_payments_summary', {
      p_from: isoDay(from),
      p_to: isoDay(to),
    })) as Row;
    return {
      daily: list(s.daily).map((d) => ({
        day: fromIsoDay(str(d.day)!),
        rides: num(d.rides),
        rentals: num(d.rentals),
      })),
      capturedToday: num(s.captured_today),
      refundsProcessing: num(s.refunds_processing),
      depositHolds: num(s.deposit_holds),
      nextPayout: num(s.next_payout),
    };
  }

  async transactions(): Promise<AdminTransaction[]> {
    const pays = await run(() =>
      this.from('payments')
        .select(
          'id, reference, purpose, method, amount, status, confirmed_at, created_at, ' +
            'payer:profiles!payments_payer_id_fkey(full_name), ride:rides(reference), rental:rental_bookings(reference)',
        )
        .order('created_at', { ascending: false })
        .limit(100),
    );
    const refunds = await run(() =>
      this.from('refunds')
        .select(
          'id, reference, amount, status, created_at, payment:payments(method, payer:profiles!payments_payer_id_fkey(full_name), ride:rides(reference), rental:rental_bookings(reference))',
        )
        .order('created_at', { ascending: false })
        .limit(100),
    );
    const payouts = await run(() =>
      this.from('driver_payouts')
        .select(
          'id, reference, amount, method, phone, status, period_start, period_end, requested_at, paid_at, driver:driver_profiles(profile:profiles!driver_profiles_user_id_fkey(full_name))',
        )
        .order('requested_at', { ascending: false })
        .limit(100),
    );
    const tone = (s: unknown): AdminTransaction['tone'] =>
      ['succeeded', 'paid', 'refunded'].includes(String(s))
        ? 'success'
        : ['failed', 'rejected'].includes(String(s))
          ? 'danger'
          : 'neutral';
    const ref = (p?: Row) => str(obj(p?.ride)?.reference) ?? str(obj(p?.rental)?.reference) ?? '';
    const kindOf = (purpose: unknown): TransactionKind =>
      purpose === 'ride_fare'
        ? 'ride_payment'
        : purpose === 'rental_deposit'
          ? 'deposit_hold'
          : 'rental_payment';

    return [
      ...list(pays).map((p) => ({
        id: str(p.id)!,
        reference: str(p.reference)!,
        kind: kindOf(p.purpose),
        bookingRef: ref(p),
        party: name(p.payer) ?? '',
        method: METHOD[String(p.method)] ?? String(p.method),
        at: date(p.confirmed_at ?? p.created_at)!,
        amount: num(p.amount),
        status:
          p.purpose === 'rental_deposit' && p.status === 'succeeded' ? 'held' : String(p.status),
        tone: tone(p.status),
        paymentId: str(p.id),
        refundable: p.status === 'succeeded' && p.purpose !== 'rental_deposit',
      })),
      ...list(refunds).map((r) => {
        const p = obj(r.payment);
        return {
          id: str(r.id)!,
          reference: str(r.reference)!,
          kind: 'refund' as const,
          bookingRef: ref(p),
          party: name(p?.payer) ?? '',
          method: 'Original method',
          at: date(r.created_at)!,
          amount: -num(r.amount),
          status: String(r.status),
          tone: tone(r.status),
          refundable: false,
        };
      }),
      ...list(payouts).map((o) => {
        const phone = str(o.phone) ?? '';
        return {
          id: str(o.id)!,
          reference: str(o.reference)!,
          kind: 'payout' as const,
          bookingRef: `${o.period_start ?? ''} – ${o.period_end ?? ''}`,
          party: name(obj(o.driver)?.profile) ?? '',
          method: `${METHOD[String(o.method)] ?? String(o.method)} •••• ${phone.slice(-4)}`,
          at: date(o.paid_at ?? o.requested_at)!,
          amount: -num(o.amount),
          status: String(o.status),
          tone: tone(o.status),
          refundable: false,
        };
      }),
    ].sort((a, b) => b.at.getTime() - a.at.getTime());
  }

  async requestRefund(paymentId: string, amount: number, reason: string) {
    await this.rpc('admin_request_refund', {
      p_payment_id: paymentId,
      p_amount: amount,
      p_reason: reason,
    });
  }

  // -------------------------------------------------------------------------
  // Places (Google, through the same Edge Functions the rider app uses)
  // -------------------------------------------------------------------------

  async searchPlaces(query: string): Promise<Place[]> {
    const input = query.trim();
    if (input.length < 2) return [];
    const sessionToken = crypto.randomUUID();
    const { data, error } = await this.db.functions.invoke<{
      suggestions: { placeId: string; primaryText: string; secondaryText?: string }[];
    }>('places-autocomplete', {
      body: { input, sessionToken, bias: { lat: 4.0511, lng: 9.7085 } },
    });
    if (error) throw toBackendError(error);
    const top = data?.suggestions.slice(0, 3) ?? [];
    const places = await Promise.all(
      top.map(async (s) => {
        const { data: d } = await this.db.functions.invoke<{
          place: { name: string; address: string; location: { lat: number; lng: number } };
        }>('place-details', { body: { placeId: s.placeId, sessionToken } });
        return d?.place;
      }),
    );
    return places.filter((p): p is NonNullable<typeof p> => Boolean(p?.location));
  }

  // -------------------------------------------------------------------------
  // Live updates from the rider and driver apps (Supabase Realtime, RLS applies)
  // -------------------------------------------------------------------------

  subscribe(onChange: (topic: ChangeTopic) => void) {
    const tables: Record<string, ChangeTopic> = {
      rides: 'rides',
      driver_locations: 'rides',
      driver_profiles: 'drivers',
      driver_documents: 'drivers',
      rental_bookings: 'rentals',
      rental_vehicles: 'fleet',
      safety_alerts: 'safety',
      incident_reports: 'safety',
      safety_case_events: 'safety',
      payments: 'payments',
      refunds: 'payments',
    };
    let channel = this.db.channel('admin-dashboard');
    for (const [table, topic] of Object.entries(tables)) {
      channel = channel.on('postgres_changes', { event: '*', schema: 'public', table }, () =>
        onChange(topic),
      );
    }
    channel.subscribe();
    return () => void this.db.removeChannel(channel);
  }
}
