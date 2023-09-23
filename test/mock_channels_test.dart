import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Receives events from the event channel', (tester) async {
    final plugin = LocationWakeup();

    const eventChannel = EventChannel('loc_stream');
    tester.binding.defaultBinaryMessenger.setMockStreamHandler(
      eventChannel,
      FakeStreamHandler(),
    );

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('loc'),
      (methodCall) async {
        if (methodCall.method == 'startMonitoring') {
          return null; // Mock response for startMonitoring
        }
        throw PlatformException(
          code: 'UNAVAILABLE',
          message: 'Mock error message',
        );
      },
    );

    TestWidgetsFlutterBinding.ensureInitialized();

    await plugin.startMonitoring();

    final events = await plugin.locationUpdates.toList();
    expect(
      events,
      isNotEmpty,
    );
  });
}

class FakeStreamHandler extends MockStreamHandler {
  @override
  void onCancel(Object? arguments) {
    // TODO: implement onCancel
  }

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    // TODO: implement onListen
  }
}
