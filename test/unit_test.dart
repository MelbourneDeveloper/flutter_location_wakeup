import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationResult', () {
    const location1 =
        Location(40.7128, 74.0060); // Replace with your actual Location class
    const location2 = Location(34.0522, 118.2437);
    const error1 = Error(
      message: 'Something went wrong',
      errorCode: ErrorCode.unknown,
    );
    const error2 = Error(
      message: 'Another issue',
      errorCode: ErrorCode.unknown,
    );

    test('should be equal if both location and error are the same', () {
      final result1 = LocationResult(location1);
      final result2 = LocationResult(location1);
      final result3 = LocationResult.error(error1);
      final result4 = LocationResult.error(error1);

      expect(result1, result2);
      expect(result3, result4);
    });

    test('should not be equal if either location or error is different', () {
      final result1 = LocationResult(location1);
      final result2 = LocationResult(location2);
      final result3 = LocationResult.error(error1);
      final result4 = LocationResult.error(error2);

      expect(result1, isNot(result2));
      expect(result3, isNot(result4));
    });

    test(
        'should have the same hash code if both '
        'location and error are the same', () {
      final result1 = LocationResult(location1);
      final result2 = LocationResult(location1);
      final result3 = LocationResult.error(error1);
      final result4 = LocationResult.error(error1);

      expect(result1.hashCode, result2.hashCode);
      expect(result3.hashCode, result4.hashCode);
    });

    test('should return the correct value from match()', () {
      final result1 = LocationResult(location1);
      final result2 = LocationResult.error(error1);

      expect(
        result1.match(
          onSuccess: (location) => 'Success',
          onError: (error) => 'Error',
        ),
        'Success',
      );

      expect(
        result2.match(
          onSuccess: (location) => 'Success',
          onError: (error) => 'Error',
        ),
        'Error',
      );
    });

    test('should return the correct value from locationOr()', () {
      final result1 = LocationResult(location1);
      final result2 = LocationResult.error(error1);

      expect(
        result1.locationOr((error) => location2),
        location1,
      );

      expect(
        result2.locationOr((error) => location2),
        location2,
      );
    });
  });

  group('LocationExtensions', () {
    test(
        'should return LocationResult with Location when both '
        'latitude and longitude are present', () {
      final map = {'latitude': 40.7128, 'longitude': 74.0060};
      final result = toLocationResult(map);

      expect(result.isSuccess, true);
      expect(result.isError, false);
      expect(
        result.match(
          onSuccess: (location) => location,
          onError: (error) => null,
        ),
        const Location(40.7128, 74.0060),
      );
    });

    test('should return LocationResult with Error when latitude is missing',
        () {
      final map = {'longitude': 74.0060};
      final result = toLocationResult(map);

      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(
        result.match(
          onSuccess: (location) => null,
          onError: (error) => error,
        ),
        const Error(
          message: 'Latitude or longitude is missing',
          errorCode: ErrorCode.unknown,
        ),
      );
    });

    test('should return LocationResult with Error when longitude is missing',
        () {
      final map = {'latitude': 40.7128};
      final result = toLocationResult(map);

      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(
        result.match(
          onSuccess: (location) => null,
          onError: (error) => error,
        ),
        const Error(
          message: 'Latitude or longitude is missing',
          errorCode: ErrorCode.unknown,
        ),
      );
    });

    test(
        'should return LocationResult with Error when both '
        'latitude and longitude are missing', () {
      final map = <String, double>{};
      final result = toLocationResult(map);

      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(
        result.match(
          onSuccess: (location) => null,
          onError: (error) => error,
        ),
        const Error(
          message: 'Latitude or longitude is missing',
          errorCode: ErrorCode.unknown,
        ),
      );
    });
  });
}
