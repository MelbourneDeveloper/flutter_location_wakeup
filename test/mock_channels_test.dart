import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_stream_handler.dart';

void main() {
  testWidgets('Receives events from the event channel', (tester) async {
    var receivedStartMonitoring = false;

    final plugin = LocationWakeup();

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('loc'),
      (methodCall) async {
        if (methodCall.method == 'startMonitoring') {
          receivedStartMonitoring = true;
          return null;
        }
        throw PlatformException(
          code: 'UNAVAILABLE',
          message: 'Mock error message',
        );
      },
    );

    TestWidgetsFlutterBinding.ensureInitialized();

    await plugin.startMonitoring();

    final locationData = <String, dynamic>{
      'latitude': 40.7128,
      'longitude': -74.0060,
      'altitude': 500.0,
      'speed': 5.0,
      'timestamp': 1677648652.0,
      'permissionStatus': 'granted',
    };

    final methodCall = MethodCall('listen', locationData);

    final encodedData =
        const StandardMethodCodec().encodeMethodCall(methodCall);

    const eventChannel = EventChannel('loc_stream');

    final fakeStreamHandler = FakeStreamHandler();
    tester.binding.defaultBinaryMessenger.setMockStreamHandler(
      eventChannel,
      fakeStreamHandler,
    );

    await eventChannel.binaryMessenger.send('loc_stream', encodedData);

    final locationResult = await plugin.locationUpdates.first;

    expect(receivedStartMonitoring, isTrue);
    expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
    expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
  });
}
