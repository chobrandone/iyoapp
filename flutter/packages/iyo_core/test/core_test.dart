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
    test('Cameroon: common ways of typing a +237 mobile', () {
      for (final input in ['671234567', '6 71 23 45 67', '+237 671 23 45 67', '00237671234567']) {
        expect(toE164(input, country: cameroon), '+237671234567', reason: input);
      }
    });
    test('Central African Republic: 8 digits, the default country', () {
      expect(toE164('75 12 34 56', country: centralAfricanRepublic), '+23675123456');
      expect(defaultPhoneCountry(localeName: 'fr'), centralAfricanRepublic);
      expect(defaultPhoneCountry(localeName: 'fr_CM'), cameroon);
      expect(defaultPhoneCountry(localeName: 'en_US'), centralAfricanRepublic);
    });
    test('detects the country from a typed or pasted code', () {
      final ng = parsePhone('+234 803 123 4567', country: cameroon);
      expect(ng.country.iso, 'NG');
      expect(ng.e164, '+2348031234567');
      expect(parsePhone('00236 75123456').country, centralAfricanRepublic);
      expect(parsePhone('+27 82 123 4567').country.iso, 'ZA');
      // Typed with the code but no "+".
      expect(parsePhone('237671234567', country: centralAfricanRepublic).e164, '+237671234567');
      expect(parsePhone('23675123456', country: cameroon).e164, '+23675123456');
      // A valid local number is never mistaken for a code.
      expect(parsePhone('75123456', country: centralAfricanRepublic).e164, '+23675123456');
      // Trunk 0 written nationally is dropped.
      expect(toE164('0803 123 4567', country: countryByIso('NG')), '+2348031234567');
    });
    test('rejects numbers of the wrong length', () {
      expect(isValidPhone('67123456', country: cameroon), isFalse);
      expect(isValidPhone('751234', country: centralAfricanRepublic), isFalse);
      expect(validatePhone('6712', country: cameroon), ValidationError.phoneInvalid);
    });
    test('formats for display', () {
      expect(formatPhone('671234567'), '+237 6 71 23 45 67');
      expect(formatPhone('+23675123456'), '+236 75 12 34 56');
    });
    test('every country has a unique dial code and a flag', () {
      final codes = africanCountries.map((c) => c.iso).toSet();
      expect(codes.length, africanCountries.length);
      expect(africanCountries.length, 54);
      expect(centralAfricanRepublic.flag, '🇨🇫');
    });
  });

  group('fares (demo, same as public.compute_fare)', () {
    test('every city starts from a 350 XAF base', () {
      for (final t in demoTariffs.values) {
        expect(t.base, 350);
      }
    });
    test('Bangui: 3.4 km / 14 min = 950 XAF, short trips pay the 600 minimum', () {
      expect(demoFare(3400, 840, 1, cityCode: 'bangui'), 950);
      expect(demoFare(500, 60, 1, cityCode: 'bangui'), 600);
      expect(demoFare(3400, 840, 1, cityCode: 'douala'), 1200);
    });
    test('the tariff follows the pickup city', () {
      expect(demoCityFor(const GeoPoint(4.3647, 18.5839)), 'bangui');
      expect(demoCityFor(const GeoPoint(4.0469, 9.6953)), 'douala');
      expect(demoCityFor(null), 'bangui');
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
