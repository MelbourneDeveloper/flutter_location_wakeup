import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'location_wakeup_test_extensions.dart';

void main() {
  var receivedStartMonitoring = false;

  setUp(() => receivedStartMonitoring = false);

  //Handle incoming method calls from the plugin to the device platform
  Future<Object?>? handleMethodCall(MethodCall methodCall) async {
    if (methodCall.method == 'startMonitoring') {
      receivedStartMonitoring = true;
    }
    return null;
  }

  testWidgets('Receives events from the event channel', (tester) async {
    //Initialize the plugin and get the locationWakeup and sendToEventChannel
    final (locationWakeup, sendToEventChannel) =
        await tester.initLocationWakeupWithMockChannel(
      handleMethodCall,
    );

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

    //Verify that that calling startMonitoring on the plugin sent the
    //correct method call to the device platform
    expect(receivedStartMonitoring, isTrue);

    //Verify that the LocationResult is correct
    expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
    expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
  });

  testWidgets('Receives permission error from iOS', (tester) async {
    // Initialize the plugin and get the locationWakeup and sendToEventChannel
    final (locationWakeup, sendToEventChannel) =
        await tester.initLocationWakeupWithMockChannel(
      handleMethodCall,
    );

    // Simulate a permission error from iOS
    final errorDetails = <String, dynamic>{
      'errorCode': locationPermissionDeniedErrorCode,
      'message': 'I am an iOS error message',
      'details': {
        'permissionStatus': 'denied',
      },
    };

    // Send the error event to the EventChannel (Mimics the Swift code)
    await sendToEventChannel(errorDetails);

    // Wait for the first LocationResult on the stream
    final locationResult = await locationWakeup.locationUpdates.first;

    // Verify that calling startMonitoring on the plugin sent the
    // correct method call to the device platform
    expect(receivedStartMonitoring, isTrue);

    // Verify that the LocationResult is an error
    expect(locationResult.isError, isTrue);

    // Verify the error details
    expect(
      locationResult.errorOrEmpty().errorCode,
      ErrorCode.locationPermissionDenied,
    );

    expect(
      locationResult.errorOrEmpty().message,
      // ignore: avoid_dynamic_calls
      errorDetails['message'],
    );
  });
}
