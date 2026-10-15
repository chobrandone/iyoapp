import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/db_enums.dart';
import '../supabase/supabase_setup.dart';
import 'demo_backend.dart';
import 'models.dart';
import 'safety_rental_models.dart';
import 'repositories.dart';
import 'supabase_backend.dart';

/// Which app is running. Each app overrides this in its ProviderScope.
final appRoleProvider = Provider<AppRole>(
  (ref) => throw UnimplementedError('override appRoleProvider'),
);

/// Supabase when the app was built with SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY, otherwise the
/// in-memory demo backend.
final backendProvider = Provider<IyoBackend>((ref) {
  final role = ref.watch(appRoleProvider);
  if (SupabaseEnv.isConfigured) {
    return SupabaseBackend(role: role, client: Supabase.instance.client);
  }
  final demo = DemoBackend(role: role);
  ref.onDispose(demo.dispose);
  return demo;
});

/// Signed-in profile (null = signed out). Drives the auth redirects.
final profileProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(backendProvider).watchProfile(),
);

/// A ride being watched live.
final rideProvider = StreamProvider.family<Ride, String>(
  (ref, id) => ref.watch(backendProvider).watchRide(id),
);

final chatProvider = StreamProvider.family<List<ChatEntry>, String>(
  (ref, id) => ref.watch(backendProvider).watchMessages(id),
);

final driverAccountProvider = StreamProvider<DriverAccount>(
  (ref) => ref.watch(backendProvider).watchAccount(),
);
final driverOnlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(backendProvider).watchOnline(),
);
final rideOfferProvider = StreamProvider<RideOffer?>(
  (ref) => ref.watch(backendProvider).watchOffers(),
);

// Safety ----------------------------------------------------------------------

final trustedContactsProvider = FutureProvider<List<TrustedContact>>(
  (ref) => ref.watch(backendProvider).trustedContacts(),
);

final emergencyNumbersProvider = FutureProvider<List<EmergencyNumber>>(
  (ref) => ref.watch(backendProvider).emergencyNumbers(),
);

// Rentals ---------------------------------------------------------------------

final rentalVehiclesProvider = FutureProvider.family<List<RentalVehicle>, String>(
  (ref, cityCode) => ref.watch(backendProvider).rentalVehicles(cityCode),
);

final airportsProvider = FutureProvider<List<Airport>>(
  (ref) => ref.watch(backendProvider).airports(),
);

final myRentalsProvider = StreamProvider<List<RentalBooking>>(
  (ref) => ref.watch(backendProvider).watchMyRentals(),
);

final rentalProvider = StreamProvider.family<RentalBooking, String>(
  (ref, id) => ref.watch(backendProvider).watchRental(id),
);

final assignedRentalsProvider = StreamProvider<List<RentalBooking>>(
  (ref) => ref.watch(backendProvider).watchAssignedRentals(),
);
