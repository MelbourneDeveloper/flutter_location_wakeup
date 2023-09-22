import 'dart:async';

import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';

///Monitors the device's location for significant changes and wakes up the app
///when there is a change
class LocationWakeup {
  ///Constructs a LocationWakeup plugin
  LocationWakeup() {
    _subscription = LocationWakeupPlatform.instance.locationUpdates.listen(
      (event) {
        _streamController.add(toLocationResult(event));
      },
      onError: (error) {
        _streamController.add(LocationResult.error(Error.unknown));
      },
    );
  }

  final StreamController<LocationResult> _streamController =
      StreamController<LocationResult>.broadcast();

  late final StreamSubscription<dynamic> _subscription;

  ///Start listening for location changes
  Future<void> startMonitoring() =>
      LocationWakeupPlatform.instance.startMonitoring();

  ///A stream of location changes
  Stream<LocationResult> get locationUpdates =>
      LocationWakeupPlatform.instance.locationUpdates.map(
        toLocationResult,
      );

  ///Disposes the plugin and stops listening to the system location changes
  Future<void> dispose() =>
      Future.wait([_subscription.cancel(), _streamController.close()]);
}
