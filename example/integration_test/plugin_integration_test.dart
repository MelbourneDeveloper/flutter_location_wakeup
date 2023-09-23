import 'package:flutter_location_wakeup/location_wakeup.dart';
import 'package:flutter_location_wakeup/model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Monitor And Wait For First Location',
      (WidgetTester tester) async {
    final LocationWakeup plugin = LocationWakeup();
    final resultFuture = plugin.locationUpdates.first;
    await plugin.startMonitoring();
    final result = await resultFuture;

    expect(result.isSuccess, true);
    final location = result.locationOr((e) => Location.empty);

    // Asserting that latitude and longitude are not default or invalid values
    expect(location.latitude, isNot(0));
    expect(location.longitude, isNot(0));
    expect(location.latitude, isNot(double.nan));
    expect(location.longitude, isNot(double.nan));

    // Asserting that other properties are also not default or invalid values
    expect(location.altitude, isNotNull);
    expect(location.horizontalAccuracy, isNotNull);
    expect(location.verticalAccuracy, isNotNull);
    expect(location.course, isNotNull);
    expect(location.speed, isNotNull);
    expect(location.timestamp, isNotNull);

    //We don't always get this
    //expect(location.floorLevel, isNotNull);

    // Asserting that the location is not an empty location
    expect(location, isNot(Location.empty));

    // Asserting that the permission status is granted
    expect(result.permissionStatus, PermissionStatus.granted);
  });

  testWidgets('Monitor And Wait For First Permission Error',
      (WidgetTester tester) async {
    final LocationWakeup plugin = LocationWakeup();
    final resultFuture = plugin.locationUpdates.first;
    await plugin.startMonitoring();
    final result = await resultFuture;
    expect(result.isSuccess, false);
    expect(result.permissionStatus, PermissionStatus.denied);
  });
}
