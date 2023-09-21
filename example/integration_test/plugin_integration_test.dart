import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loc/loc.dart';
import 'package:loc/model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Monitor And Wait For First Location',
      (WidgetTester tester) async {
    final Loc plugin = Loc();
    final resultFuture = plugin.locationUpdates.first;
    await plugin.startMonitoring();
    final result = await resultFuture;
    expect(result.isSuccess, true);
    final location = result.locationOr((e) => const Location(0, 0));
    expect(location.latitude, isNot(0));
    expect(location.longitude, isNot(0));
  });
}
