// Data contracts used by the screens. Two implementations:
//   * DemoBackend   — in memory, simulates the other app (no network, no Supabase project);
//   * SupabaseBackend — the RPCs / Edge Functions in supabase/ (Phase 3).
import '../supabase/db_enums.dart';
import 'models.dart';
import 'safety_rental_models.dart';

/// Thrown by repositories with a server error code (see server_errors.dart).
class BackendException implements Exception {
  const BackendException(this.code, [this.details]);

  final String code;
  final Object? details;

  @override
  String toString() => 'BackendException($code${details == null ? '' : ': $details'})';
}

abstract interface class AuthRepository {
  /// Current signed-in profile, or null. Emits on sign-in / sign-out.
  Stream<UserProfile?> watchProfile();
  UserProfile? get currentProfile;

  /// Sends a 6-digit SMS code to [phoneE164].
  Future<void> sendOtp(String phoneE164);

  /// Verifies the code. New users are created with [signUp] details and the app's role.
  Future<UserProfile> verifyOtp(String phoneE164, String code, {SignUpDetails? signUp});

  Future<void> signOut();
}

class SignUpDetails {
  const SignUpDetails({required this.fullName, this.email, required this.role, this.language});

  final String fullName;
  final String? email;
  final AppRole role;
  final AppLanguage? language;
}

abstract interface class PlacesRepository {
  /// Cameroon-only suggestions. Reuse [sessionToken] until [details] is called.
  Future<List<Place>> autocomplete(String input, {required String sessionToken, GeoPoint? near});
  Future<Place> details(Place suggestion, {required String sessionToken});
  Future<List<Place>> savedPlaces();
}

abstract interface class RiderRideRepository {
  Future<FareEstimate> estimateFares(Place pickup, Place dropoff);
  Future<Ride> requestRide(FareOption option, PaymentMethodType method);

  /// Live ride row (+ driver position) until the ride ends.
  Stream<Ride> watchRide(String rideId);
  Future<Counterpart?> driverFor(String rideId);
  Future<Ride> cancel(String rideId, {String? reason});
  Future<void> rate(String rideId, int stars, {int tip = 0, String? comment});

  /// The rider's open ride, if any (to resume after an app restart).
  Future<Ride?> openRide();
}

abstract interface class ChatRepository {
  Stream<List<ChatEntry>> watchMessages(String rideId);
  Future<void> send(String rideId, String body);
}

abstract interface class DriverRepository {
  Stream<DriverAccount> watchAccount();
  Future<void> saveIdentity({
    required String cityCode,
    required String licenceNumber,
    required String nationalIdNumber,
    required VehicleInfo vehicle,
  });
  Future<void> uploadDocument(
    DocumentType type,
    String localPath, {
    void Function(double)? onProgress,
  });
  Future<void> submitApplication();

  /// Going online needs an approved account and the current position.
  Future<void> setOnline(bool online, {GeoPoint? at});
  Stream<bool> watchOnline();
  Future<void> updateLocation(GeoPoint at, {double? heading, double? speedMps});

  /// Pending offers for this driver (Realtime on ride_offers + push).
  Stream<RideOffer?> watchOffers();
  Future<Ride?> respond(RideOffer offer, {required bool accept});

  Stream<Ride> watchRide(String rideId);
  Future<Counterpart?> riderFor(String rideId);
  Future<Ride> updateStatus(String rideId, RideStatus status, {String? reason});
  Future<PinCheck> verifyPin(String rideId, String pin);
  Future<void> rateRider(String rideId, int stars);

  Future<DriverDaySummary> today();
  Future<List<CompletedTrip>> recentTrips();
}

abstract interface class SafetyRepository {
  /// Rider's trusted contacts (max 5, +237 numbers).
  Future<List<TrustedContact>> trustedContacts();
  Future<TrustedContact> addTrustedContact({
    required String name,
    required String phoneE164,
    String? relationship,
  });
  Future<void> removeTrustedContact(String id);

  /// Whether the contact is texted when the rider raises a safety alert.
  Future<void> setNotifyOnAlert(String id, {required bool notify});

  /// app_config.emergency_numbers.
  Future<List<EmergencyNumber>> emergencyNumbers();

  /// Rider alert (R13): snapshot of the trip + location for the safety team.
  Future<SafetyAlert> raiseAlert({String? rideId, GeoPoint? at, String? reason, String? note});

  /// Texts the rider's trusted contacts a live-trip link (safety-notify). Returns how many.
  Future<int> notifyTrustedContacts(String alertId);

  /// Tokenised, expiring public link to the live trip (both apps).
  Future<TripShare> shareTrip(String rideId);

  /// Driver incident report (D17).
  Future<IncidentReport> reportIncident({
    required String category,
    String? description,
    String? rideId,
    String? rentalBookingId,
    GeoPoint? at,
    bool urgent = false,
  });
}

abstract interface class RentalRepository {
  Future<List<RentalVehicle>> rentalVehicles(String cityCode);
  Future<List<Airport>> airports();
  Future<RentalBooking> bookRental(RentalRequest request);
  Stream<List<RentalBooking>> watchMyRentals();
  Stream<RentalBooking> watchRental(String bookingId);
  Future<RentalBooking> cancelRental(String bookingId, {String? reason});
  Future<void> confirmInspection(String bookingId, InspectionType type);

  /// Rider tells the team the car is coming back (the assigned driver then inspects it).
  Future<void> requestReturn(String bookingId);

  /// Driver: rentals assigned to me (D15).
  Stream<List<RentalBooking>> watchAssignedRentals();

  /// Driver: handover / return checklist with photos (D16).
  Future<void> submitInspection(
    String bookingId,
    InspectionType type,
    InspectionDraft draft, {
    void Function(double)? onProgress,
  });
}

/// Everything one app talks to. Implemented by DemoBackend and SupabaseBackend.
abstract interface class IyoBackend
    implements
        AuthRepository,
        PlacesRepository,
        RiderRideRepository,
        ChatRepository,
        DriverRepository,
        SafetyRepository,
        RentalRepository {
  /// True for the in-memory demo backend (UI shows the demo SMS code and simulated parties).
  bool get isDemo;
}
