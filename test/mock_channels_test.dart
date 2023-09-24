import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'location_wakeup_test_extensions.dart';

void main() {
  var receivedStartMonitoringCount = 0;
  var receivedStopMonitoringCount = 0;

  setUp(() {
    receivedStartMonitoringCount = 0;
    receivedStopMonitoringCount = 0;
  });

  //Handle incoming method calls from the plugin to the device platform
  Future<Object?>? handleMethodCall(MethodCall methodCall) async {
    if (methodCall.method == 'startMonitoring') {
      receivedStartMonitoringCount++;
    } else if (methodCall.method == 'stopMonitoring') {
      receivedStopMonitoringCount++;
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

  testWidgets('Monitor And Wait For First Location', (tester) async {
    //Initialize the plugin and get the locationWakeup and sendToEventChannel
    final (plugin, sendToEventChannel) =
        await tester.initLocationWakeupWithMockChannel(
      handleMethodCall,
    );

    final locationData = <String, dynamic>{
      'latitude': 40.7128,
      'longitude': -74.0060,
      'altitude': 500.0,
      'speed': 5.0,
      'timestamp': 1677648652.0,
      'horizontalAccuracy': 10.0,
      'permissionStatus': 'granted',
      'verticalAccuracy': 10.0,
      'course': 10.0,
    };

    await sendToEventChannel(locationData);
    final resultFuture = plugin.locationUpdates.first;
    await plugin.startMonitoring();
    final result = await resultFuture;

    expect(result.isSuccess, true);
    final location = result.locationOr((e) => Location.empty);

    // Asserting that latitude and longitude are not default or invalid values
    expect(location.latitude, isNot(0));
    expect(location.longitude, isNot(0));
    expect(location.latitude, isNot(double.nan));
    expect(location.longitude, isNot(double.nan));

    // Asserting that other properties are also not default or invalid values
    expect(location.altitude, isNotNull);
    expect(location.horizontalAccuracy, isNotNull);
    expect(location.verticalAccuracy, isNotNull);
    expect(location.course, isNotNull);
    expect(location.speed, isNotNull);
    expect(location.timestamp, isNotNull);

    //We don't always get this
    //expect(location.floorLevel, isNotNull);

    // Asserting that the location is not an empty location
    expect(location, isNot(Location.empty));

    // Asserting that the permission status is granted
    expect(result.permissionStatus, PermissionStatus.granted);

    //Close the plugin on the device platform
    await plugin.stopMonitoring();

    //TODO: is there anything we verify on the Swift side?
  });

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

    await locationWakeup.stopMonitoring();

    expect(receivedStopMonitoringCount, 1);
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

  Future<void> testPermissionStatusHandling(
    String? permissionString,
    PermissionStatus expectedStatus,
    WidgetTester tester,
  ) async {
    final locationData = <String, dynamic>{
      'latitude': 40.7128,
      'longitude': -74.0060,
    };

    if (permissionString != null) {
      locationData['permissionStatus'] = permissionString;
    }

    final locationResult = await sendDataAndGetResult(locationData, tester);

    expect(locationResult.permissionStatus, expectedStatus);
    expect(locationResult.isError, isFalse);
    expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
    expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
    expect(receivedStartMonitoringCount, 1);
  }

  testWidgets(
    'Handles restricted permission status gracefully',
    (tester) async => testPermissionStatusHandling(
      'restricted',
      PermissionStatus.restricted,
      tester,
    ),
  );

  testWidgets(
    'Handles limited permission status gracefully',
    (tester) async => testPermissionStatusHandling(
      'limited',
      PermissionStatus.limited,
      tester,
    ),
  );

  testWidgets(
    'Handles missing permission status gracefully',
    (tester) async => testPermissionStatusHandling(
      null,
      PermissionStatus.notSpecified,
      tester,
    ),
  );
}
