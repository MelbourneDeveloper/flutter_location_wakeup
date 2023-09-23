import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_extensions.dart';

void main() {
  testWidgets('Receives events from the event channel', (tester) async {
    var receivedStartMonitoring = false;

    final methodChannelLocationWakeup =
        LocationWakeupPlatform.instance as MethodChannelLocationWakeup;

    final locationData = <String, dynamic>{
      'latitude': 40.7128,
      'longitude': -74.0060,
      'altitude': 500.0,
      'speed': 5.0,
      'timestamp': 1677648652.0,
      'permissionStatus': 'granted',
    };

    final locationWakeup = LocationWakeup();

    final send = tester.initializeAndEmitOne<LocationWakeup, LocationResult>(
      methodChannel: methodChannelLocationWakeup.channel,
      eventChannel: methodChannelLocationWakeup.eventChannel,
      methodHandler: (methodCall) async {
        if (methodCall.method == 'startMonitoring') {
          receivedStartMonitoring = true;
        }
        return null;
      },
    );

    await locationWakeup.startMonitoring();

    await send(locationData);

    final locationResult = await locationWakeup.locationUpdates.first;

    expect(receivedStartMonitoring, isTrue);
    expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
    expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
  });
}
