


import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';

///Monitors the devices location for significant changes and wakes up the app
///when there is a change
class LocationWakeup {
  ///Start listening for location changes
  Future<void> startMonitoring() =>
      LocationWakeupPlatform.instance.startMonitoring();

  ///A stream of location changes
  Stream<LocationResult> get locationUpdates =>
      LocationWakeupPlatform.instance.locationUpdates.map(
        toLocationResult,
      );
}
