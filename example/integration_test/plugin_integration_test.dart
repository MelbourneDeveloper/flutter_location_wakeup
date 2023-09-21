
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loc/loc.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Monitor And Wait For First Location',
      (WidgetTester tester) async {
    final Loc plugin = Loc();
    final resultFuture = plugin.locationUpdates.first;
    await plugin.startMonitoring();
    final result = await resultFuture;
    expect(result.isSuccess, true);
    expect(result.value, isNotNull);
    expect(result.value.latitude, isNot(0));
    expect(result.value.longitude, isNot(0));
  });
}
