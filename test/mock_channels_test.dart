import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_extensions.dart';

void main() {
testWidgets('Receives events from the event channel', (tester) async {
  var receivedStartMonitoring = false;

  //Get the method/event channels
  final methodChannelLocationWakeup =
      LocationWakeupPlatform.instance as MethodChannelLocationWakeup;

  //Create a sender that sends fake events to the EventChannel that mimic
  //the events that the device platform sends over the EventChannel
  final sendToEventChannel =
      tester.getEventChannelSender<LocationWakeup, LocationResult>(
    methodChannel: methodChannelLocationWakeup.channel,
    eventChannel: methodChannelLocationWakeup.eventChannel,
    methodHandler: (methodCall) async {
      if (methodCall.method == 'startMonitoring') {
        receivedStartMonitoring = true;
      }
      return null;
    },
  );

  //Create the Plugin
  final locationWakeup = LocationWakeup();

  //Initialize the plugin
  await locationWakeup.startMonitoring();

  final locationData = <String, dynamic>{
    'latitude': 40.7128,
    'longitude': -74.0060,
    'altitude': 500.0,
    'speed': 5.0,
    'timestamp': 1677648652.0,
    'permissionStatus': 'granted',
  };

  //Send the event to the EventChannel (Mimics the Swift code)
  //eventSink?(locationData)
  await sendToEventChannel(locationData);

  //Wait for the first LocationResult on the stream
  final locationResult = await locationWakeup.locationUpdates.first;

  //Verify that the LocationResult is correct
  expect(receivedStartMonitoring, isTrue);
  expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
  expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
});
}
