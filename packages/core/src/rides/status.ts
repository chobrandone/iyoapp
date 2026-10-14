/**
 * Ride lifecycle shared by both apps. The server is the only authority on transitions;
 * these types let both apps agree on the contract and render the right screen.
 * Generated DB enums (Phase 3) must stay in sync with this list.
 */
export const RIDE_STATUSES = [
  'requested',
  'searching',
  'driver_assigned',
  'driver_arriving',
  'driver_arrived',
  'in_progress',
  'completed',
  'cancelled_by_rider',
  'cancelled_by_driver',
  'no_drivers_found',
] as const;

export type RideStatus = (typeof RIDE_STATUSES)[number];

export type RideActor = 'rider' | 'driver' | 'server';

export const TERMINAL_RIDE_STATUSES: readonly RideStatus[] = [
  'completed',
  'cancelled_by_rider',
  'cancelled_by_driver',
  'no_drivers_found',
];

/** Allowed transitions and which actor may trigger them. */
export const RIDE_TRANSITIONS: Readonly<
  Record<RideStatus, readonly { to: RideStatus; actor: RideActor }[]>
> = {
  requested: [
    { to: 'searching', actor: 'server' },
    { to: 'cancelled_by_rider', actor: 'rider' },
  ],
  searching: [
    { to: 'driver_assigned', actor: 'driver' },
    { to: 'no_drivers_found', actor: 'server' },
    { to: 'cancelled_by_rider', actor: 'rider' },
  ],
  driver_assigned: [
    { to: 'driver_arriving', actor: 'driver' },
    { to: 'cancelled_by_rider', actor: 'rider' },
    { to: 'cancelled_by_driver', actor: 'driver' },
  ],
  driver_arriving: [
    { to: 'driver_arrived', actor: 'driver' },
    { to: 'cancelled_by_rider', actor: 'rider' },
    { to: 'cancelled_by_driver', actor: 'driver' },
  ],
  driver_arrived: [
    { to: 'in_progress', actor: 'driver' },
    { to: 'cancelled_by_rider', actor: 'rider' },
    { to: 'cancelled_by_driver', actor: 'driver' },
  ],
  in_progress: [{ to: 'completed', actor: 'driver' }],
  completed: [],
  cancelled_by_rider: [],
  cancelled_by_driver: [],
  no_drivers_found: [],
};

export function canTransition(from: RideStatus, to: RideStatus, actor: RideActor): boolean {
  return RIDE_TRANSITIONS[from].some((t) => t.to === to && t.actor === actor);
}

export function isTerminalStatus(status: RideStatus): boolean {
  return TERMINAL_RIDE_STATUSES.includes(status);
}
