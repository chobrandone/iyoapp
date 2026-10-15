import 'package:flutter_test/flutter_test.dart';
import 'package:iyo_core/iyo_core.dart';

const _fast = DemoTiming(matching: Duration(milliseconds: 20));

Future<DemoBackend> _signedIn(AppRole role) async {
  final b = DemoBackend(role: role, timing: _fast);
  await b.verifyOtp(
    role == AppRole.rider ? '+237671234567' : '+237699112233',
    demoOtpCode,
    signUp: SignUpDetails(fullName: 'Test User', role: role),
  );
  return b;
}

Future<RentalBooking> _until(DemoBackend b, String id, bool Function(RentalBooking) ok) =>
    b.watchRental(id).firstWhere(ok).timeout(const Duration(seconds: 2));

void main() {
  test('flight numbers follow the rental_bookings check', () {
    for (final ok in ['AF900', 'qc 1234', 'ET9081', 'KQ1234A']) {
      expect(isValidFlightNumber(ok), isTrue, reason: ok);
    }
    for (final bad in ['AF', 'AF12345', 'AF-900', '']) {
      expect(isValidFlightNumber(bad), isFalse, reason: bad);
    }
  });

  test('rental totals round days up and add the airport fee', () {
    final start = DateTime(2026, 11, 1, 10);
    final r = RentalRequest(
      vehicle: demoRentalFleet.first,
      startsAt: start,
      endsAt: start.add(const Duration(days: 2, hours: 1)),
      pickupType: RentalPickupType.airport,
      paymentMethod: PaymentMethodType.mtnMomo,
      airport: demoAirports.first,
    );
    expect(r.days, 3);
    expect(r.total, 3 * demoRentalFleet.first.dailyRate + demoAirports.first.pickupFee);
    expect(r.kmAllowance, 3 * demoRentalFleet.first.kmPerDay);
  });

  test('trusted contacts are capped at five', () async {
    final b = await _signedIn(AppRole.rider);
    addTearDown(b.dispose);
    for (var i = 0; i < 5; i++) {
      await b.addTrustedContact(name: 'Contact $i', phoneE164: '+23767000000$i');
    }
    await expectLater(
      b.addTrustedContact(name: 'Six', phoneE164: '+237670000006'),
      throwsA(
        isA<BackendException>().having((e) => e.code, 'code', 'trusted_contacts_limit_reached'),
      ),
    );
    final alert = await b.raiseAlert(reason: 'test');
    expect(await b.notifyTrustedContacts(alert.id), 5);
  });

  test('rider rental: pay → driver assigned → handover → active → return → deposit back', () async {
    final b = await _signedIn(AppRole.rider);
    addTearDown(b.dispose);
    final start = DateTime.now().add(const Duration(days: 1));
    final booking = await b.bookRental(
      RentalRequest(
        vehicle: demoRentalFleet.first,
        startsAt: start,
        endsAt: start.add(const Duration(days: 2)),
        pickupType: RentalPickupType.airport,
        paymentMethod: PaymentMethodType.mtnMomo,
        airport: demoAirports.first,
        terminal: 'Arrivals',
        flightNumber: 'af 900',
        flightArrivalAt: start,
      ),
    );
    expect(booking.status, RentalBookingStatus.pendingPayment);
    expect(booking.flightNumber, 'AF900');
    final ready = await _until(b, booking.id, (x) => x.handover != null);
    expect(ready.status, RentalBookingStatus.driverAssigned);
    await b.confirmInspection(booking.id, InspectionType.handover);
    final active = await _until(b, booking.id, (x) => x.status == RentalBookingStatus.active);
    expect(active.depositStatus, DepositStatus.held);
    await expectLater(
      b.cancelRental(booking.id),
      throwsA(isA<BackendException>().having((e) => e.code, 'code', 'booking_not_cancellable')),
    );
    await b.requestReturn(booking.id);
    await _until(b, booking.id, (x) => x.status == RentalBookingStatus.returnPending);
    await b.confirmInspection(booking.id, InspectionType.return_);
    final done = await _until(b, booking.id, (x) => x.status == RentalBookingStatus.completed);
    expect(done.depositStatus, DepositStatus.released);
  });

  test('cash rentals are confirmed at once and the same car cannot be double-booked', () async {
    final b = await _signedIn(AppRole.rider);
    addTearDown(b.dispose);
    final start = DateTime.now().add(const Duration(days: 3));
    RentalRequest req(DateTime s) => RentalRequest(
      vehicle: demoRentalFleet[2],
      startsAt: s,
      endsAt: s.add(const Duration(days: 2)),
      pickupType: RentalPickupType.address,
      pickupAddress: 'Akwa, Douala',
      paymentMethod: PaymentMethodType.cash,
    );
    final first = await b.bookRental(req(start));
    expect(first.status, RentalBookingStatus.confirmed);
    await expectLater(
      b.bookRental(req(start.add(const Duration(days: 1)))),
      throwsA(
        isA<BackendException>().having((e) => e.code, 'code', 'vehicle_unavailable_for_dates'),
      ),
    );
    final cancelled = await b.cancelRental(first.id);
    expect(cancelled.status, RentalBookingStatus.cancelled);
  });

  test(
    'driver handover needs all five photos; the rider confirmation activates the rental',
    () async {
      final b = await _signedIn(AppRole.driver);
      addTearDown(b.dispose);
      b.approveDemoDriver();
      final assigned = await b.watchAssignedRentals().firstWhere((l) => l.isNotEmpty);
      final r = assigned.single;
      expect(r.airportCode, 'DLA');
      expect(r.riderName, isNotNull);
      const photos = {'front': 'f', 'back': 'b', 'left': 'l', 'right': 'r'};
      await expectLater(
        b.submitInspection(
          r.id,
          InspectionType.handover,
          const InspectionDraft(fuelLevel: 8, odometerKm: 41200, localPhotos: photos),
        ),
        throwsA(isA<BackendException>().having((e) => e.code, 'code', 'photos_missing')),
      );
      final progress = <double>[];
      await b.submitInspection(
        r.id,
        InspectionType.handover,
        const InspectionDraft(
          fuelLevel: 8,
          odometerKm: 41200,
          localPhotos: {...photos, 'interior': 'i'},
        ),
        onProgress: progress.add,
      );
      expect(progress.last, 1);
      final active = await _until(b, r.id, (x) => x.status == RentalBookingStatus.active);
      expect(active.handover!.odometerKm, 41200);
    },
  );
}
