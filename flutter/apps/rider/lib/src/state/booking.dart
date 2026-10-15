import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iyo_core/iyo_core.dart';

/// Everything chosen between "Where to?" and the ride request.
@immutable
class BookingState {
  const BookingState({
    this.pickup,
    this.dropoff,
    this.estimate,
    this.selected,
    this.paymentMethod = PaymentMethodType.mtnMomo,
    this.loading = false,
    this.error,
  });

  final Place? pickup;
  final Place? dropoff;
  final FareEstimate? estimate;
  final FareOption? selected;

  /// Mobile money is the default (spec §4).
  final PaymentMethodType paymentMethod;
  final bool loading;
  final String? error;

  BookingState copyWith({
    Place? pickup,
    Place? dropoff,
    FareEstimate? estimate,
    FareOption? selected,
    PaymentMethodType? paymentMethod,
    bool? loading,
    String? error,
    bool clearEstimate = false,
    bool clearError = false,
  }) => BookingState(
    pickup: pickup ?? this.pickup,
    dropoff: dropoff ?? this.dropoff,
    estimate: clearEstimate ? null : (estimate ?? this.estimate),
    selected: clearEstimate ? null : (selected ?? this.selected),
    paymentMethod: paymentMethod ?? this.paymentMethod,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class BookingController extends Notifier<BookingState> {
  @override
  BookingState build() => const BookingState();

  IyoBackend get _backend => ref.read(backendProvider);

  void setPickup(Place place) {
    state = state.copyWith(pickup: place, clearEstimate: true, clearError: true);
    _estimateIfReady();
  }

  void setDropoff(Place place) {
    state = state.copyWith(dropoff: place, clearEstimate: true, clearError: true);
    _estimateIfReady();
  }

  void select(FareOption option) => state = state.copyWith(selected: option);
  void setPayment(PaymentMethodType method) => state = state.copyWith(paymentMethod: method);

  /// Recalculates whenever pickup or destination change (spec Phase 5).
  Future<void> _estimateIfReady() async {
    final pickup = state.pickup, dropoff = state.dropoff;
    if (pickup?.location == null || dropoff?.location == null) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final estimate = await _backend.estimateFares(pickup!, dropoff!);
      // Ignore stale answers if the rider changed a place meanwhile.
      if (state.pickup != pickup || state.dropoff != dropoff) return;
      state = state.copyWith(estimate: estimate, selected: estimate.options.first, loading: false);
    } on BackendException catch (e) {
      state = state.copyWith(loading: false, error: e.code);
    }
  }

  Future<void> refresh() => _estimateIfReady();

  /// Books the selected option. Expired quotes are refreshed and the rider asked again.
  Future<Ride?> request() async {
    final option = state.selected;
    if (option == null) return null;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final ride = await _backend.requestRide(option, state.paymentMethod);
      state = state.copyWith(loading: false);
      return ride;
    } on BackendException catch (e) {
      state = state.copyWith(loading: false, error: e.code);
      if (e.code == 'quote_expired' || e.code == 'quote_already_used') await _estimateIfReady();
      return null;
    }
  }

  void reset() => state = BookingState(pickup: state.pickup);
}

final bookingProvider = NotifierProvider<BookingController, BookingState>(BookingController.new);

/// Places session token (UUID v4): one per search session, ended by place details.
String newSessionToken() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String hex(int from, int to) =>
      b.sublist(from, to).map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
