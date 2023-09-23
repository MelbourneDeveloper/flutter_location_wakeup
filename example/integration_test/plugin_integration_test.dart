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
    expect(location.latitude, isNot(0));
    expect(location.longitude, isNot(0));
    expect(location.latitude, isNot(double.nan));
    expect(location.longitude, isNot(double.nan));
    expect(location, isNot(Location.empty));
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
