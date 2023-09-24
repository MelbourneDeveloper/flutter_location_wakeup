import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'location_wakeup_test_extensions.dart';

void main() {
  var receivedStartMonitoringCount = 0;

  setUp(() => receivedStartMonitoringCount = 0);

  //Handle incoming method calls from the plugin to the device platform
  Future<Object?>? handleMethodCall(MethodCall methodCall) async {
    if (methodCall.method == 'startMonitoring') {
      receivedStartMonitoringCount++;
    }
    return null;
  }

  Future<LocationResult> sendDataAndGetResult(
    Map<String, dynamic> data,
    WidgetTester tester,
  ) async {
    final (locationWakeup, sendToEventChannel) =
        await tester.initLocationWakeupWithMockChannel(handleMethodCall);
    await sendToEventChannel(data);
    return locationWakeup.locationUpdates.first;
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
    expect(receivedStartMonitoringCount, 1);

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
    expect(receivedStartMonitoringCount, 1);

    // Verify that the LocationResult is an error
    expect(locationResult.isError, isTrue);

    // Verify the error details
    expect(
      locationResult.errorOrEmpty().errorCode,
      ErrorCode.locationPermissionDenied,
    );

    expect(
      locationResult.errorOrEmpty().message,
      errorDetails['message'],
    );
  });

  testWidgets('Two locations with the same values should be equal',
      (tester) async {
    final (locationWakeup, sendToEventChannel) =
        await tester.initLocationWakeupWithMockChannel(handleMethodCall);

    final locationData1 = {
      'latitude': 40.7128,
      'longitude': 74.0060,
      'altitude': 100.0,
      'permissionStatus': 'granted',
    };

    final locationData2 = {
      'latitude': 40.7128,
      'longitude': 74.0060,
      'altitude': 100.0,
      'permissionStatus': 'granted',
    };

    await sendToEventChannel(locationData1);
    final locationResult1 = await locationWakeup.locationUpdates.first;

    await sendToEventChannel(locationData2);
    final locationResult2 = await locationWakeup.locationUpdates.first;

    expect(locationResult1, locationResult2);
  });

  testWidgets('Two locations with different altitudes should not be equal',
      (tester) async {
    final (locationWakeup, sendToEventChannel) =
        await tester.initLocationWakeupWithMockChannel(handleMethodCall);

    final locationData1 = {
      'latitude': 40.7128,
      'longitude': 74.0060,
      'altitude': 100.0,
      'permissionStatus': 'granted',
    };

    final locationData2 = {
      'latitude': 40.7128,
      'longitude': 74.0060,
      'altitude': 200.0,
      'permissionStatus': 'granted',
    };

    await sendToEventChannel(locationData1);
    final locationResult1 = await locationWakeup.locationUpdates.first;

    await sendToEventChannel(locationData2);
    final locationResult2 = await locationWakeup.locationUpdates.first;

    expect(locationResult1, isNot(locationResult2));
  });

  testWidgets('Handles invalid data types gracefully', (tester) async {
    final locationResult = await sendDataAndGetResult(
      {
        'latitude': '40.7128', // Invalid data type
        'longitude': -74.0060,
        'permissionStatus': 'granted',
      },
      tester,
    );

    expect(locationResult.isError, isTrue);
    expect(receivedStartMonitoringCount, 1);
  });

  testWidgets('Handles missing data gracefully', (tester) async {
    final locationResult = await sendDataAndGetResult(
      {
        'latitude': 40.7128,
        // 'longitude': -74.0060, // Missing data
        'permissionStatus': 'granted',
      },
      tester,
    );

    expect(locationResult.isError, isTrue);
    expect(receivedStartMonitoringCount, 1);
  });

  testWidgets('Handles missing permission status gracefully', (tester) async {
    final locationData = {
      'latitude': 40.7128,
      'longitude': -74.0060,
    };

    final locationResult = await sendDataAndGetResult(locationData, tester);

    // Check that the permissionStatus is set to notSpecified when it's missing
    expect(locationResult.permissionStatus, PermissionStatus.notSpecified);
    expect(locationResult.isError, isFalse);
    expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
    expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
    expect(receivedStartMonitoringCount, 1);
  });
}
