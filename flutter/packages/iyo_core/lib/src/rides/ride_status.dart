import '../supabase/db_enums.dart';

/// Ride lifecycle shared by both apps. The server is the only authority on transitions;
/// this lets both apps agree on the contract and render the right screen.
/// [rideStatusTransitions] is generated from `public.ride_status_transitions`.
const Set<RideStatus> terminalRideStatuses = {
  RideStatus.completed,
  RideStatus.cancelledByRider,
  RideStatus.cancelledByDriver,
  RideStatus.noDriversFound,
};

/// Statuses during which a driver is attached to the ride.
const Set<RideStatus> activeRideStatuses = {
  RideStatus.driverAssigned,
  RideStatus.driverArriving,
  RideStatus.driverArrived,
  RideStatus.inProgress,
};

bool canTransition(RideStatus from, RideStatus to, RideActor actor) =>
    rideStatusTransitions.any((t) => t.$1 == from && t.$2 == to && t.$3 == actor);

bool isTerminalStatus(RideStatus status) => terminalRideStatuses.contains(status);

/// Next statuses [actor] may move a ride to from [from].
List<RideStatus> allowedTransitions(RideStatus from, RideActor actor) => [
  for (final t in rideStatusTransitions)
    if (t.$1 == from && t.$3 == actor) t.$2,
];
