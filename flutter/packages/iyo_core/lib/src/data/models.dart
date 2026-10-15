// Domain models shared by both apps. Field names follow the Supabase schema
// (supabase/migrations) so the Supabase backend maps rows 1:1.
import 'package:flutter/foundation.dart';

import '../supabase/db_enums.dart';

@immutable
class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) => other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'GeoPoint($lat, $lng)';
}

/// A searchable / saved place.
@immutable
class Place {
  const Place({required this.name, required this.address, this.location, this.placeId});

  final String name;
  final String address;

  /// Null for autocomplete suggestions until place details are fetched.
  final GeoPoint? location;
  final String? placeId;

  Place withLocation(GeoPoint point) =>
      Place(name: name, address: address, location: point, placeId: placeId);
}

@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phone,
    this.email,
    this.language = AppLanguage.fr,
    this.rating,
    this.ratingCount = 0,
  });

  final String id;
  final AppRole role;
  final String fullName;

  /// E.164, e.g. +237671234567.
  final String phone;
  final String? email;
  final AppLanguage language;
  final double? rating;
  final int ratingCount;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;
}

/// Route between two points (Routes API through compute-route / estimate-fares).
@immutable
class RouteInfo {
  const RouteInfo({
    required this.distanceMeters,
    required this.durationSeconds,
    this.points = const [],
  });

  final int distanceMeters;
  final int durationSeconds;

  /// Decoded polyline; empty in demo mode (the map illustration draws the route).
  final List<GeoPoint> points;
}

/// One upfront price for one category (a row of fare_quotes).
@immutable
class FareOption {
  const FareOption({
    required this.quoteId,
    required this.categoryCode,
    required this.nameEn,
    required this.nameFr,
    required this.seats,
    required this.fareAmount,
    required this.expiresAt,
    this.etaMinutes,
    this.isPlaceholder = false,
  });

  final String quoteId;
  final String categoryCode;
  final String nameEn;
  final String nameFr;
  final int seats;

  /// FCFA, integer.
  final int fareAmount;
  final DateTime expiresAt;
  final int? etaMinutes;
  final bool isPlaceholder;

  String name(String languageCode) => languageCode == 'fr' ? nameFr : nameEn;
}

@immutable
class FareEstimate {
  const FareEstimate({required this.route, required this.options});

  final RouteInfo route;
  final List<FareOption> options;
}

@immutable
class VehicleInfo {
  const VehicleInfo({
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
    required this.categoryCode,
    this.year,
    this.seats = 4,
  });

  final String make;
  final String model;
  final String color;
  final String plate;
  final String categoryCode;
  final int? year;
  final int seats;

  String get label => '$make $model';
}

/// The other party of a ride, as returned by get_ride_counterpart().
@immutable
class Counterpart {
  const Counterpart({
    required this.id,
    required this.firstName,
    this.fullName,
    this.phone,
    this.rating,
    this.ratingCount = 0,
    this.vehicle,
    this.avatarUrl,
  });

  final String id;
  final String firstName;

  /// Riders only see the driver's full name; drivers see the rider's once the trip starts.
  final String? fullName;
  final String? phone;
  final double? rating;
  final int ratingCount;
  final VehicleInfo? vehicle;
  final String? avatarUrl;

  String get displayName => fullName ?? firstName;
}

@immutable
class Ride {
  const Ride({
    required this.id,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.categoryCode,
    required this.fareAmount,
    required this.paymentMethod,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.requestedAt,
    this.commissionRate = 0.2,
    this.driverLocation,
    this.driverHeading,
    this.etaSeconds,
    this.pin,
    this.cancelReason,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final RideStatus status;
  final Place pickup;
  final Place dropoff;
  final String categoryCode;
  final int fareAmount;
  final PaymentMethodType paymentMethod;
  final int distanceMeters;
  final int durationSeconds;
  final DateTime requestedAt;
  final double commissionRate;

  /// Live position of the assigned driver (driver_locations), when visible to the caller.
  final GeoPoint? driverLocation;
  final double? driverHeading;

  /// Driver ETA to the pickup (before the trip) or to the destination (during it).
  final int? etaSeconds;

  /// Pickup PIN; only ever present for the rider.
  final String? pin;
  final String? cancelReason;
  final DateTime? startedAt;
  final DateTime? completedAt;

  int get driverEarnings => fareAmount - (fareAmount * commissionRate).round();

  bool get isActive =>
      !const {
        RideStatus.completed,
        RideStatus.cancelledByRider,
        RideStatus.cancelledByDriver,
        RideStatus.noDriversFound,
      }.contains(status);

  Ride copyWith({
    RideStatus? status,
    GeoPoint? driverLocation,
    double? driverHeading,
    int? etaSeconds,
    String? cancelReason,
    DateTime? startedAt,
    DateTime? completedAt,
  }) => Ride(
    id: id,
    status: status ?? this.status,
    pickup: pickup,
    dropoff: dropoff,
    categoryCode: categoryCode,
    fareAmount: fareAmount,
    paymentMethod: paymentMethod,
    distanceMeters: distanceMeters,
    durationSeconds: durationSeconds,
    requestedAt: requestedAt,
    commissionRate: commissionRate,
    driverLocation: driverLocation ?? this.driverLocation,
    driverHeading: driverHeading ?? this.driverHeading,
    etaSeconds: etaSeconds ?? this.etaSeconds,
    pin: pin,
    cancelReason: cancelReason ?? this.cancelReason,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
  );
}

/// A ride offered to the driver, with a 15 s accept window.
@immutable
class RideOffer {
  const RideOffer({
    required this.id,
    required this.ride,
    required this.rider,
    required this.expiresAt,
    this.pickupDistanceMeters,
    this.pickupEtaSeconds,
  });

  final String id;
  final Ride ride;
  final Counterpart rider;
  final DateTime expiresAt;
  final int? pickupDistanceMeters;
  final int? pickupEtaSeconds;
}

@immutable
class ChatEntry {
  const ChatEntry({
    required this.id,
    required this.body,
    required this.senderId,
    required this.sentAt,
    this.readAt,
  });

  final String id;
  final String body;
  final String senderId;
  final DateTime sentAt;
  final DateTime? readAt;
}

/// Outcome of verify_pickup_pin().
@immutable
class PinCheck {
  const PinCheck({required this.ok, required this.locked, required this.attemptsLeft});

  final bool ok;
  final bool locked;
  final int attemptsLeft;
}

@immutable
class DriverDocument {
  const DriverDocument({
    required this.type,
    required this.status,
    this.localPath,
    this.rejectionReason,
  });

  final DocumentType type;
  final ReviewStatus status;
  final String? localPath;
  final String? rejectionReason;
}

@immutable
class DriverAccount {
  const DriverAccount({
    required this.status,
    this.cityCode,
    this.licenceNumber,
    this.nationalIdNumber,
    this.payoutMethod,
    this.payoutPhone,
    this.vehicle,
    this.documents = const {},
    this.reviewNotes,
  });

  final VerificationStatus status;
  final String? cityCode;
  final String? licenceNumber;
  final String? nationalIdNumber;
  final PaymentMethodType? payoutMethod;
  final String? payoutPhone;
  final VehicleInfo? vehicle;
  final Map<DocumentType, DriverDocument> documents;
  final String? reviewNotes;

  bool get identityComplete =>
      cityCode != null &&
      (licenceNumber?.isNotEmpty ?? false) &&
      (nationalIdNumber?.isNotEmpty ?? false);

  DriverAccount copyWith({
    VerificationStatus? status,
    String? cityCode,
    String? licenceNumber,
    String? nationalIdNumber,
    PaymentMethodType? payoutMethod,
    String? payoutPhone,
    VehicleInfo? vehicle,
    Map<DocumentType, DriverDocument>? documents,
    String? reviewNotes,
  }) => DriverAccount(
    status: status ?? this.status,
    cityCode: cityCode ?? this.cityCode,
    licenceNumber: licenceNumber ?? this.licenceNumber,
    nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
    payoutMethod: payoutMethod ?? this.payoutMethod,
    payoutPhone: payoutPhone ?? this.payoutPhone,
    vehicle: vehicle ?? this.vehicle,
    documents: documents ?? this.documents,
    reviewNotes: reviewNotes ?? this.reviewNotes,
  );
}

/// Today's totals on the driver home screen.
@immutable
class DriverDaySummary {
  const DriverDaySummary({
    required this.earnings,
    required this.trips,
    required this.onlineSeconds,
  });

  final int earnings;
  final int trips;
  final int onlineSeconds;
}

@immutable
class CompletedTrip {
  const CompletedTrip({
    required this.rideId,
    required this.dropoffName,
    required this.fareAmount,
    required this.earnings,
    required this.completedAt,
  });

  final String rideId;
  final String dropoffName;
  final int fareAmount;
  final int earnings;
  final DateTime completedAt;
}
