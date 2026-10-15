import 'package:flutter/widgets.dart';
import 'package:iyo_core/iyo_core.dart';

/// Figma sample content for the driver design previews, with Cameroon equivalents of the
/// London placeholders (owner decision: Cameroon content, Figma layout).
abstract final class DriverSample {
  static const driverFirstName = 'Patrick';
  static const driverName = 'Patrick Essomba';
  static const driverRef = 'DR-018';
  static const driverRating = '4.9';
  static const driverTrips = 248;

  static const riderName = 'Aïcha Ngo Mbappe';
  static const riderFirstName = 'Aïcha';
  static const riderRating = '4.9';
  static const riderPhone = '+237671234567';
  static const riderPhoto = AssetImage('assets/images/sample_rider.jpg');

  static const pickupName = '12 Rue Joss';
  static const pickupArea = 'Akwa, Douala';
  static const dropoffName = 'Gare de Bessengué';
  static const dropoffArea = 'Bessengué, Douala';
  static const pickupNote = 'Je suis devant la pharmacie.';

  static const estEarnings = 2450;
  static const tripRef = 'IYO-4826';
  static const pin = '4826';

  static const todayEarnings = 18600;
  static const todayTrips = 7;
  static const todayOnline = 2 * 3600 + 18 * 60;

  static const busyArea = 'Akwa & Bonanjo';

  static const vehicleMake = 'Toyota';
  static const vehicleModel = 'Corolla';
  static const vehicleColor = 'Blanc';
  static const vehicleYear = 2018;
  static const vehiclePlate = 'LT 123 AB';

  static const payoutAccount = 'MTN MoMo •••• 4455';

  static const rentalCar = 'Toyota Corolla';
  static const rentalPlate = 'LT 211 RB';
  static const rentalRef = 'RN-2048';
  static const rentalFlight = 'AF900';
  static const rentalFlightRoute = 'Paris CDG → Douala';
  static const rentalDays = 3;
  static const rentalDailyRate = 25000;
  static const rentalDeposit = 100000;

  /// Rental start in the sample: 17 Oct 2026, 10:00 (Douala).
  static final rentalStart = DateTime.utc(2026, 10, 17, 9);
  static final rentalEnd = DateTime.utc(2026, 10, 20, 9);
  static final flightLanding = DateTime.utc(2026, 10, 17, 8, 15);

  /// Week of 12–18 Oct 2026: Monday to Sunday net earnings, today Thursday.
  static const weekBuckets = [26400, 25800, 13900, 9800, 0, 0, 0];
  static const weekTotal = 75900;
  static const weekTrips = 32;
  static const weekDriveSeconds = 18 * 3600 + 20 * 60;

  static const rider = Counterpart(
    id: 'sample-rider',
    firstName: riderFirstName,
    fullName: riderName,
    phone: riderPhone,
    rating: 4.9,
  );

  static Ride ride(RideStatus status) => Ride(
    id: 'sample-ride',
    status: status,
    pickup: const Place(
      name: pickupName,
      address: '12 Rue Joss, Akwa, Douala',
      location: GeoPoint(4.0505, 9.6966),
    ),
    dropoff: const Place(
      name: dropoffName,
      address: 'Bessengué, Douala',
      location: GeoPoint(4.0610, 9.7140),
    ),
    categoryCode: 'standard',
    fareAmount: 3060,
    paymentMethod: PaymentMethodType.mtnMomo,
    distanceMeters: 3200,
    durationSeconds: 720,
    requestedAt: DateTime.utc(2026, 10, 15, 8, 40),
  );

  static List<CompletedTrip> todaysRides() {
    final day = DateTime(2026, 10, 15);
    CompletedTrip trip(
      String id,
      String from,
      String to,
      String rider,
      int net,
      int h,
      int m,
      int min,
    ) => CompletedTrip(
      rideId: id,
      pickupName: from,
      dropoffName: to,
      riderFirstName: rider,
      fareAmount: (net / 0.8).round(),
      earnings: net,
      startedAt: day.add(Duration(hours: h, minutes: m)),
      completedAt: day.add(Duration(hours: h, minutes: m + min)),
      durationSeconds: min * 60,
    );
    return [
      trip('RD-1042', 'Akwa', 'Bessengué', 'Aïcha', 3100, 9, 4, 18),
      trip('RD-1038', 'Deido', 'Bonapriso', 'Christian', 2600, 8, 20, 19),
      trip('RD-1034', 'Bali', 'Akwa', 'Mireille', 2450, 7, 45, 17),
    ];
  }
}
