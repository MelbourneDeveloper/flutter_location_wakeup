
import 'package:flutter_location_wakeup/extensions.dart';
import 'package:flutter_location_wakeup/location_wakeup_platform.dart';
import 'package:flutter_location_wakeup/model.dart';

///Monitors the devices location for significant changes and wakes up the app
///when there is a change
class LocationWakeup {
  ///Start listening for location changes
  Future<void> startMonitoring() =>
      LocationWakeupPlatform.instance.startMonitoring();

  ///A stream of location changes
  Stream<LocationResult> get locationUpdates =>
      LocationWakeupPlatform.instance.locationUpdates.map(
        (map) => map.toLocationResult(),
      );
}
