import 'package:flutter_test/flutter_test.dart';
import 'package:loc/model.dart';

void main() {
  group('LocationResult', () {
    const location1 =
        Location(40.7128, 74.0060); // Replace with your actual Location class
    const location2 = Location(34.0522, 118.2437);
    const error1 =
        Error('Something went wrong'); // Replace with your actual Error class
    const error2 = Error('Another issue');

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
}
