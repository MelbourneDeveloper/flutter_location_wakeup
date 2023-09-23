import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_extensions.dart';

///A set of extensions that make it easier to test the LocationWakeup plugin
extension LocationWakeupTesterExtensions on WidgetTester {
  Future<
      (
        LocationWakeup,
        Future<void> Function(Map<String, dynamic>),
      )> initLocationWakeupWithMockChannel(
    Future<Object?>? Function(MethodCall) methodHandler,
  ) async {
    //Get the method/event channels
    final methodChannelLocationWakeup =
        LocationWakeupPlatform.instance as MethodChannelLocationWakeup;

    //Create a sender that sends fake events to the EventChannel that mimic
    //the events that the device platform sends over the EventChannel

    final sendToEventChannel =
        getEventChannelSender<LocationWakeup, LocationResult>(
      methodChannel: methodChannelLocationWakeup.channel,
      eventChannel: methodChannelLocationWakeup.eventChannel,
      methodHandler: methodHandler,
    );

    //Create the Plugin
    final locationWakeup = LocationWakeup();

    //Initialize the plugin
    await locationWakeup.startMonitoring();

    return (locationWakeup, sendToEventChannel);
  }
}
