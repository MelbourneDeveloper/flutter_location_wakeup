import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationResult', () {
    const location1 = Location(latitude: 40.7128, longitude: 74.0060);
    const location2 = Location(latitude: 34.0522, longitude: 118.2437);
    const error1 = Error(
      message: 'Something went wrong',
      errorCode: ErrorCode.unknown,
    );
    const error2 = Error(
      message: 'Another issue',
      errorCode: ErrorCode.unknown,
    );

    test('equality and hash code tests', () {
      const result1 = LocationResult(
        location1,
        permissionStatus: PermissionStatus.notSpecified,
      );
      const result2 = LocationResult(
        location1,
        permissionStatus: PermissionStatus.notSpecified,
      );
      const result3 = LocationResult.error(
        error1,
        permissionStatus: PermissionStatus.notSpecified,
      );
      const result4 = LocationResult.error(
        error1,
        permissionStatus: PermissionStatus.notSpecified,
      );
      const result5 = LocationResult(
        location2,
        permissionStatus: PermissionStatus.notSpecified,
      );
      const result6 = LocationResult.error(
        error2,
        permissionStatus: PermissionStatus.notSpecified,
      );

      expect(result1, result2);
      expect(result3, result4);
      expect(result1, isNot(result5));
      expect(result3, isNot(result6));
      expect(result1.hashCode, result2.hashCode);
      expect(result3.hashCode, result4.hashCode);

      // Additional assertions for the new code
      expect(result1.locationOrEmpty, location1);
      expect(result3.locationOrEmpty, Location.empty);
    });

    test('match() and locationOr() tests', () {
      const result1 = LocationResult(
        location1,
        permissionStatus: PermissionStatus.notSpecified,
      );
      const result2 = LocationResult.error(
        error1,
        permissionStatus: PermissionStatus.notSpecified,
      );

      expect(
        result1.match(onSuccess: (l) => 'Success', onError: (e) => 'Error'),
        'Success',
      );
      expect(
        result2.match(onSuccess: (l) => 'Success', onError: (e) => 'Error'),
        'Error',
      );
      expect(result1.locationOr((e) => location2), location1);
      expect(result2.locationOr((e) => location2), location2);
      expect(result1.permissionStatus, PermissionStatus.notSpecified);
    });
  });

  group('LocationExtensions', () {
    const expectedError = Error(
      message: 'Latitude or longitude is missing',
      errorCode: ErrorCode.unknown,
    );

    test('toLocationResult with both latitude and longitude', () {
      final mapWithBoth = {'latitude': 40.7128, 'longitude': 74.0060};
      final result = toLocationResult(mapWithBoth);

      expect(result.isSuccess, true);
      expect(result.isError, false);
      expect(
        result.match(onSuccess: (l) => l, onError: (e) => null),
        const Location(latitude: 40.7128, longitude: 74.0060),
      );
    });

    test('toLocationResult with missing latitude', () {
      final mapWithLongitudeOnly = {'longitude': 74.0060};
      final result = toLocationResult(mapWithLongitudeOnly);

      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(
        result.match(onSuccess: (l) => null, onError: (e) => e),
        expectedError,
      );
    });

    test('toLocationResult with missing longitude', () {
      final mapWithLatitudeOnly = {'latitude': 40.7128};
      final result = toLocationResult(mapWithLatitudeOnly);

      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(
        result.match(onSuccess: (l) => null, onError: (e) => e),
        expectedError,
      );
    });

    test('toLocationResult with both missing', () {
      final emptyMap = <String, double>{};
      final result = toLocationResult(emptyMap);

      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(
        result.match(onSuccess: (l) => null, onError: (e) => e),
        expectedError,
      );
    });
  });

  group('toLocationResult', () {
    test('returns unknown error when latitude or longitude is missing', () {
      // Scenario 1: Only latitude is provided
      final dataWithLatitudeOnly = {'latitude': 40.7128};
      final result1 = toLocationResult(dataWithLatitudeOnly);
      expect(result1.isError, true);
      expect(
        result1.match(onSuccess: (l) => null, onError: (e) => e.errorCode),
        ErrorCode.unknown,
      );

      // Scenario 2: Only longitude is provided
      final dataWithLongitudeOnly = {'longitude': 74.0060};
      final result2 = toLocationResult(dataWithLongitudeOnly);
      expect(result2.isError, true);
      expect(
        result2.match(onSuccess: (l) => null, onError: (e) => e.errorCode),
        ErrorCode.unknown,
      );

      // Scenario 3: Neither latitude nor longitude is provided
      final dataWithoutLatLong = {};
      final result3 = toLocationResult(dataWithoutLatLong);
      expect(result3.isError, true);
      expect(
        result3.match(onSuccess: (l) => null, onError: (e) => e.errorCode),
        ErrorCode.unknown,
      );

      // Scenario 4: Latitude and longitude are not doubles
      final dataWithInvalidLatLong = {
        'latitude': '40.7128',
        'longitude': '74.0060',
      };
      final result4 = toLocationResult(dataWithInvalidLatLong);
      expect(result4.isError, true);
      expect(
        result4.match(onSuccess: (l) => null, onError: (e) => e.errorCode),
        ErrorCode.unknown,
      );
    });
  });
}
