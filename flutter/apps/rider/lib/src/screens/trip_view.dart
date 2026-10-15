import 'package:flutter/widgets.dart';
import 'package:iyo_core/iyo_core.dart';

import '../sample/sample_data.dart';
import '../widgets/rider_widgets.dart';

/// Short, stable trip reference shown to people (support, shares): IYO-#### from the ride id.
String tripRefOf(String rideId) {
  var h = 0;
  for (final c in rideId.codeUnits) {
    h = (h * 31 + c) % 10000;
  }
  return 'IYO-${h.toString().padLeft(4, '0')}';
}

/// Everything the trip screens print, from a live ride or from the Figma sample (design preview).
class TripView {
  const TripView({
    required this.driverFirst,
    required this.driverFull,
    required this.driverMeta,
    required this.vehicle,
    required this.vehicleShort,
    required this.pin,
    required this.etaMinutes,
    required this.etaDistance,
    required this.pickupName,
    required this.dropoffName,
    required this.dropoffDetail,
    required this.fare,
    required this.paymentLabel,
    required this.tripRef,
    required this.arriveTime,
    required this.tripDate,
    this.rideFare,
    this.bookingFee,
    this.driverPhone,
    this.pickup,
    this.dropoff,
    this.car,
    this.carHeading = 0,
    this.routePoints = const [],
  });

  final String driverFirst;
  final String driverFull;
  final String driverMeta;
  final String vehicle;
  final String vehicleShort;
  final String pin;
  final String etaMinutes;
  final String etaDistance;
  final String pickupName;
  final String dropoffName;
  final String dropoffDetail;
  final String fare;
  final String? rideFare;
  final String? bookingFee;
  final String paymentLabel;
  final String tripRef;
  final String arriveTime;
  final String tripDate;
  final String? driverPhone;
  final GeoPoint? pickup;
  final GeoPoint? dropoff;
  final GeoPoint? car;
  final double carHeading;
  final List<GeoPoint> routePoints;

  /// The Figma frame content (design review and snapshot tests).
  factory TripView.sample(BuildContext context) => TripView(
    driverFirst: Sample.driverFirstName,
    driverFull: Sample.driverFullName,
    driverMeta: context.t.ratingTrips(Sample.driverRating, Sample.driverTrips),
    vehicle: Sample.vehicle(context),
    vehicleShort: Sample.vehicleShort,
    pin: Sample.pin,
    etaMinutes: Sample.etaMinutes,
    etaDistance: Sample.etaDistance,
    pickupName: Sample.pickupShort,
    dropoffName: Sample.destination,
    dropoffDetail: Sample.destinationDetail(context),
    fare: Sample.fare,
    rideFare: Sample.rideFare,
    bookingFee: Sample.bookingFee,
    paymentLabel: Sample.paymentMethod,
    tripRef: Sample.tripId,
    arriveTime: Sample.arriveTime,
    tripDate: Sample.tripDate,
  );

  factory TripView.live(BuildContext context, Ride ride, Counterpart? driver) {
    final t = context.t;
    final eta = ride.etaSeconds;
    final toDropoff = ride.status == RideStatus.inProgress;
    final remaining =
        ride.driverLocation == null
            ? null
            : demoRoute(
              ride.driverLocation!,
              (toDropoff ? ride.dropoff : ride.pickup).location!,
            ).distanceMeters;
    final v = driver?.vehicle;
    return TripView(
      driverFirst: driver?.firstName ?? '',
      driverFull: driver?.displayName ?? '',
      driverMeta: t.ratingTrips(
        driver?.rating?.toStringAsFixed(1) ?? '–',
        formatNumberGrouped(driver?.ratingCount ?? 0),
      ),
      vehicle: v == null ? '' : '${v.label} · ${v.color} · ${v.plate}',
      vehicleShort: v == null ? '' : '${v.label} · ${v.plate}',
      driverPhone: driver?.phone,
      pin: ride.pin ?? '',
      etaMinutes: eta == null ? '–' : '${(eta / 60).ceil()}',
      etaDistance: remaining == null ? '–' : formatDistance(remaining),
      pickupName: ride.pickup.name,
      dropoffName: ride.dropoff.name,
      dropoffDetail: ride.dropoff.address,
      fare: formatFcfa(ride.fareAmount),
      paymentLabel: paymentMethodLabel(context, ride.paymentMethod),
      tripRef: tripRefOf(ride.id),
      arriveTime: formatTime(DateTime.now().add(Duration(seconds: eta ?? ride.durationSeconds))),
      tripDate:
          '${formatDateTime(ride.startedAt ?? ride.requestedAt)} · ${formatDistance(ride.distanceMeters)}',
      pickup: ride.pickup.location,
      dropoff: ride.dropoff.location,
      car: ride.driverLocation,
      carHeading: ride.driverHeading ?? 0,
    );
  }
}

String paymentMethodLabel(BuildContext context, PaymentMethodType method) {
  final t = context.t;
  return switch (method) {
    PaymentMethodType.mtnMomo => t.paymentMtn,
    PaymentMethodType.orangeMoney => t.paymentOrange,
    PaymentMethodType.cash => t.paymentCash,
    PaymentMethodType.card => t.paymentCard,
  };
}
