import 'package:flutter_location_wakeup/location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../../test/mock_channels_test.dart';

//These run an actual device and prove that the plugin works end-to-end

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Monitor And Wait For First Location',
    (WidgetTester tester) async => await monitorAndWaitForFirstLocation(
      LocationWakeup(),
    ),
  );

  testWidgets(
    'Monitor And Wait For First Permission Error',
    (WidgetTester tester) => monitorAndWaitForPermissionError(
      LocationWakeup(),
    ),
  );
}
