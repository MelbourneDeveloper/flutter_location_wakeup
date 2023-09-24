import 'package:flutter_location_wakeup/location_wakeup.dart';
import 'package:flutter_location_wakeup/model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../../test/mock_channels_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Monitor And Wait For First Location',
      (WidgetTester tester) async =>
          await monitorAndWaitForFirstLocation(LocationWakeup()));

  testWidgets('Monitor And Wait For First Permission Error',
      (WidgetTester tester) async {
    final LocationWakeup plugin = LocationWakeup();
    final resultFuture = plugin.locationUpdates.first;
    await plugin.startMonitoring();
    final result = await resultFuture;
    expect(result.isSuccess, false);
    expect(result.permissionStatus, PermissionStatus.denied);
    //Close the plugin on the device platform
    await plugin.stopMonitoring();
  });
}
