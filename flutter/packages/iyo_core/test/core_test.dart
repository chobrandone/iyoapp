import 'package:flutter_test/flutter_test.dart';
import 'package:iyo_core/iyo_core.dart';

void main() {
  group('currency', () {
    test('groups thousands with a non-breaking space', () {
      expect(formatFcfa(2500), '2\u00A0500\u00A0FCFA');
      expect(formatFcfa(1250000), '1\u00A0250\u00A0000\u00A0FCFA');
      expect(formatFcfa(950), '950\u00A0FCFA');
    });
    test('rounds fares to 50', () {
      expect(roundToNearest50(1360), 1350);
      expect(roundToNearest50(1375), 1400);
    });
  });

  group('datetime', () {
    final utc = DateTime.utc(2026, 10, 14, 23, 30);
    test('uses Africa/Douala (UTC+1) regardless of device zone', () {
      expect(formatDate(utc), '15/10/2026');
      expect(formatTime(utc), '00:30');
    });
    test('durations and distances', () {
      expect(formatDuration(84), '01:24');
      expect(formatDistance(850), '850 m');
      expect(formatDistance(4230), '4.2 km');
    });
  });

  group('phone', () {
    test('accepts common ways of typing a +237 mobile', () {
      for (final input in ['671234567', '6 71 23 45 67', '+237 671 23 45 67', '00237671234567']) {
        expect(toE164(input), '+237671234567', reason: input);
      }
    });
    test('rejects non-mobiles', () {
      expect(isCameroonMobile('233421234'), isFalse);
      expect(isCameroonMobile('67123456'), isFalse);
      expect(validatePhone('6712'), ValidationError.phoneInvalid);
    });
    test('formats for display', () {
      expect(formatPhone('671234567'), '+237 6 71 23 45 67');
    });
  });

  group('ride state machine (generated from the migrations)', () {
    test('rider can cancel before the trip starts but not during it', () {
      expect(
        canTransition(RideStatus.driverArrived, RideStatus.cancelledByRider, RideActor.rider),
        isTrue,
      );
      expect(
        canTransition(RideStatus.inProgress, RideStatus.cancelledByRider, RideActor.rider),
        isFalse,
      );
    });
    test('only the server ends a search without drivers', () {
      expect(allowedTransitions(RideStatus.searching, RideActor.server), [
        RideStatus.noDriversFound,
      ]);
    });
    test('terminal statuses have no exits', () {
      for (final status in terminalRideStatuses) {
        expect(rideStatusTransitions.where((t) => t.$1 == status), isEmpty);
      }
    });
    test('enum values round-trip to the database strings', () {
      expect(RideStatus.fromValue('driver_assigned'), RideStatus.driverAssigned);
      expect(InspectionType.return_.value, 'return');
    });
  });

  test('server error codes are extracted from RPC messages', () {
    expect(serverErrorCode('wrong_role: rider required'), 'wrong_role');
    expect(serverErrorCode('something else'), isNull);
  });
}
