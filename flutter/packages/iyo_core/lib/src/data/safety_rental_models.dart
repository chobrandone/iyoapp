// Safety and rental models (spec §9.5, §9.7). Field names follow supabase/migrations.
import 'package:flutter/foundation.dart';

import '../supabase/db_enums.dart';
import 'models.dart';

@immutable
class TrustedContact {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship,
    this.notifyOnAlert = true,
  });

  final String id;
  final String name;

  /// E.164.
  final String phone;
  final String? relationship;
  final bool notifyOnAlert;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
}

/// From app_config.emergency_numbers (police / fire / ambulance; values to be verified by the owner).
@immutable
class EmergencyNumber {
  const EmergencyNumber({required this.service, required this.number});

  final String service;
  final String number;
}

const defaultEmergencyNumbers = [
  EmergencyNumber(service: 'police', number: '117'),
  EmergencyNumber(service: 'fire', number: '118'),
  EmergencyNumber(service: 'ambulance', number: '119'),
];

@immutable
class SafetyAlert {
  const SafetyAlert({required this.id, required this.createdAt, this.rideId});

  final String id;
  final DateTime createdAt;
  final String? rideId;
}

@immutable
class TripShare {
  const TripShare({required this.token, required this.expiresAt, required this.url});

  final String token;
  final DateTime expiresAt;

  /// Public link opening the live trip page (TRIP_SHARE_BASE_URL + token).
  final String url;
}

@immutable
class IncidentReport {
  const IncidentReport({required this.id, required this.createdAt, required this.category});

  final String id;
  final DateTime createdAt;
  final String category;
}

@immutable
class RentalVehicle {
  const RentalVehicle({
    required this.id,
    required this.cityCode,
    required this.make,
    required this.model,
    required this.category,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.plate,
    required this.dailyRate,
    required this.depositAmount,
    required this.kmPerDay,
    this.year,
    this.color,
    this.extraKmRate = 0,
    this.features = const [],
    this.airportPickupAvailable = false,
    this.imagePaths = const [],
    this.isPlaceholderPricing = true,
  });

  final String id;
  final String cityCode;
  final String make;
  final String model;
  final String category;
  final TransmissionType transmission;
  final int seats;
  final FuelType fuelType;
  final String plate;
  final int dailyRate;
  final int depositAmount;
  final int kmPerDay;
  final int? year;
  final String? color;
  final int extraKmRate;
  final List<String> features;
  final bool airportPickupAvailable;
  final List<String> imagePaths;
  final bool isPlaceholderPricing;

  String get name => '$make $model';
}

@immutable
class Airport {
  const Airport({
    required this.code,
    required this.name,
    required this.cityCode,
    required this.pickupFee,
    this.terminals = const [],
  });

  final String code;
  final String name;
  final String cityCode;
  final int pickupFee;
  final List<String> terminals;
}

/// What the rider is about to book (validated server-side by create_rental_booking).
@immutable
class RentalRequest {
  const RentalRequest({
    required this.vehicle,
    required this.startsAt,
    required this.endsAt,
    required this.pickupType,
    required this.paymentMethod,
    this.pickupAddress,
    this.airport,
    this.terminal,
    this.flightNumber,
    this.flightArrivalAt,
    this.protection = false,
    this.protectionDaily = 0,
  });

  final RentalVehicle vehicle;
  final DateTime startsAt;
  final DateTime endsAt;
  final RentalPickupType pickupType;
  final PaymentMethodType paymentMethod;
  final String? pickupAddress;
  final Airport? airport;
  final String? terminal;
  final String? flightNumber;
  final DateTime? flightArrivalAt;
  final bool protection;
  final int protectionDaily;

  /// Whole days, rounded up (same rule as the server).
  int get days => rentalDays(startsAt, endsAt);
  int get rentalAmount => vehicle.dailyRate * days;
  int get airportFee => pickupType == RentalPickupType.airport ? (airport?.pickupFee ?? 0) : 0;
  int get protectionAmount => protection ? protectionDaily * days : 0;
  int get total => rentalAmount + airportFee + protectionAmount;
  int get kmAllowance => vehicle.kmPerDay * days;
}

/// Started 24 h periods between [start] and [end] (create_rental_booking uses the same rule).
int rentalDays(DateTime start, DateTime end) =>
    (end.difference(start).inMinutes / (24 * 60)).ceil().clamp(1, 365);

/// Flight numbers like AF900 / QC 1234 (same pattern as the rental_bookings check).
bool isValidFlightNumber(String input) =>
    RegExp(r'^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$').hasMatch(input.toUpperCase().replaceAll(' ', ''));

@immutable
class RentalInspection {
  const RentalInspection({
    required this.type,
    required this.fuelLevel,
    required this.odometerKm,
    this.photoPaths = const {},
    this.damageNotes,
    this.depositHoldAmount = 0,
    this.inspectorConfirmedAt,
    this.riderConfirmedAt,
  });

  final InspectionType type;

  /// Eighths of a tank (0–8).
  final int fuelLevel;
  final int odometerKm;

  /// front / back / left / right / interior → storage path (or local path in demo).
  final Map<String, String> photoPaths;
  final String? damageNotes;
  final int depositHoldAmount;
  final DateTime? inspectorConfirmedAt;
  final DateTime? riderConfirmedAt;
}

/// Driver input for a handover / return inspection.
@immutable
class InspectionDraft {
  const InspectionDraft({
    required this.fuelLevel,
    required this.odometerKm,
    required this.localPhotos,
    this.damageNotes,
    this.checklist = const {},
    this.depositHoldAmount = 0,
  });

  final int fuelLevel;
  final int odometerKm;

  /// side → local file path; all five sides are required.
  final Map<String, String> localPhotos;
  final String? damageNotes;
  final Map<String, bool> checklist;
  final int depositHoldAmount;
}

const inspectionSides = ['front', 'back', 'left', 'right', 'interior'];

@immutable
class RentalBooking {
  const RentalBooking({
    required this.id,
    required this.reference,
    required this.vehicle,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.pickupType,
    required this.days,
    required this.dailyRate,
    required this.rentalAmount,
    required this.airportFee,
    required this.depositAmount,
    required this.totalAmount,
    required this.kmAllowance,
    required this.paymentMethod,
    this.pickupAddress,
    this.airportCode,
    this.terminal,
    this.flightNumber,
    this.flightArrivalAt,
    this.depositStatus = DepositStatus.notCollected,
    this.depositHeldAmount = 0,
    this.assignedDriverId,
    this.riderName,
    this.riderPhone,
    this.handover,
    this.returnInspection,
    this.protectionAmount = 0,
    this.handoverPin,
    this.driver,
  });

  final String id;
  final String reference;
  final RentalVehicle vehicle;
  final RentalBookingStatus status;
  final DateTime startsAt;
  final DateTime endsAt;
  final RentalPickupType pickupType;
  final int days;
  final int dailyRate;
  final int rentalAmount;
  final int airportFee;
  final int depositAmount;
  final int totalAmount;
  final int kmAllowance;
  final PaymentMethodType paymentMethod;
  final String? pickupAddress;
  final String? airportCode;
  final String? terminal;
  final String? flightNumber;
  final DateTime? flightArrivalAt;
  final DepositStatus depositStatus;
  final int depositHeldAmount;
  final String? assignedDriverId;

  /// Driver app only.
  final String? riderName;
  final String? riderPhone;
  final RentalInspection? handover;
  final RentalInspection? returnInspection;
  final int protectionAmount;

  /// Rider app only: the 4-digit PIN they tell the driver at the car.
  final String? handoverPin;

  /// Rider app only: the driver handing the car over, once assigned.
  final Counterpart? driver;

  bool get isCancellable =>
      const {
        RentalBookingStatus.pendingPayment,
        RentalBookingStatus.confirmed,
        RentalBookingStatus.driverAssigned,
      }.contains(status) &&
      startsAt.isAfter(DateTime.now());

  RentalBooking copyWith({
    RentalBookingStatus? status,
    DepositStatus? depositStatus,
    int? depositHeldAmount,
    String? assignedDriverId,
    RentalInspection? handover,
    RentalInspection? returnInspection,
    Counterpart? driver,
  }) => RentalBooking(
    id: id,
    reference: reference,
    vehicle: vehicle,
    status: status ?? this.status,
    startsAt: startsAt,
    endsAt: endsAt,
    pickupType: pickupType,
    days: days,
    dailyRate: dailyRate,
    rentalAmount: rentalAmount,
    airportFee: airportFee,
    depositAmount: depositAmount,
    totalAmount: totalAmount,
    kmAllowance: kmAllowance,
    paymentMethod: paymentMethod,
    pickupAddress: pickupAddress,
    airportCode: airportCode,
    terminal: terminal,
    flightNumber: flightNumber,
    flightArrivalAt: flightArrivalAt,
    depositStatus: depositStatus ?? this.depositStatus,
    depositHeldAmount: depositHeldAmount ?? this.depositHeldAmount,
    assignedDriverId: assignedDriverId ?? this.assignedDriverId,
    riderName: riderName,
    riderPhone: riderPhone,
    handover: handover ?? this.handover,
    returnInspection: returnInspection ?? this.returnInspection,
    protectionAmount: protectionAmount,
    handoverPin: handoverPin,
    driver: driver ?? this.driver,
  );
}
