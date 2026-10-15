import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iyo_core/iyo_core.dart';

/// Everything chosen between "Browse cars" and the booking (R27–R31).
@immutable
class RentalDraft {
  const RentalDraft({
    this.cityCode = 'douala',
    this.vehicle,
    this.startsAt,
    this.endsAt,
    this.pickupType = RentalPickupType.address,
    this.address = '',
    this.airport,
    this.terminal,
    this.flightNumber = '',
    this.flightArrivalAt,
    this.paymentMethod = PaymentMethodType.mtnMomo,
  });

  final String cityCode;
  final RentalVehicle? vehicle;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final RentalPickupType pickupType;
  final String address;
  final Airport? airport;
  final String? terminal;
  final String flightNumber;
  final DateTime? flightArrivalAt;

  /// Mobile money is the default (spec §4).
  final PaymentMethodType paymentMethod;

  bool get isAirport => pickupType == RentalPickupType.airport;

  bool get periodValid =>
      startsAt != null &&
      endsAt != null &&
      endsAt!.isAfter(startsAt!) &&
      startsAt!.isAfter(DateTime.now());

  bool get pickupValid =>
      isAirport
          ? airport != null && isValidFlightNumber(flightNumber) && flightArrivalAt != null
          : address.trim().length >= 3;

  /// The request create_rental_booking validates again server-side; null until complete.
  RentalRequest? get request {
    final v = vehicle;
    if (v == null || !periodValid || !pickupValid) return null;
    return RentalRequest(
      vehicle: v,
      startsAt: startsAt!,
      endsAt: endsAt!,
      pickupType: pickupType,
      paymentMethod: paymentMethod,
      pickupAddress: isAirport ? null : address.trim(),
      airport: isAirport ? airport : null,
      terminal: isAirport ? terminal : null,
      flightNumber: isAirport ? flightNumber : null,
      flightArrivalAt: isAirport ? flightArrivalAt : null,
    );
  }

  RentalDraft copyWith({
    String? cityCode,
    RentalVehicle? vehicle,
    DateTime? startsAt,
    DateTime? endsAt,
    RentalPickupType? pickupType,
    String? address,
    Airport? airport,
    String? terminal,
    String? flightNumber,
    DateTime? flightArrivalAt,
    PaymentMethodType? paymentMethod,
  }) => RentalDraft(
    cityCode: cityCode ?? this.cityCode,
    vehicle: vehicle ?? this.vehicle,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    pickupType: pickupType ?? this.pickupType,
    address: address ?? this.address,
    airport: airport ?? this.airport,
    terminal: terminal ?? this.terminal,
    flightNumber: flightNumber ?? this.flightNumber,
    flightArrivalAt: flightArrivalAt ?? this.flightArrivalAt,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );
}

class RentalDraftController extends Notifier<RentalDraft> {
  @override
  RentalDraft build() => const RentalDraft();

  void update(RentalDraft Function(RentalDraft d) change) => state = change(state);

  /// A new car keeps the city and dates but not a pickup the car may not support.
  void chooseVehicle(RentalVehicle v) =>
      state = RentalDraft(
        cityCode: state.cityCode,
        vehicle: v,
        startsAt: state.startsAt,
        endsAt: state.endsAt,
        address: state.address,
        paymentMethod: state.paymentMethod,
      );

  void reset() => state = RentalDraft(cityCode: state.cityCode);
}

final rentalDraftProvider = NotifierProvider<RentalDraftController, RentalDraft>(
  RentalDraftController.new,
);
