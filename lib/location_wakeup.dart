import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';

const _locationPermissionDeniedErrorCode = 'LOCATION_PERMISSION_DENIED';

///Monitors the device's location for significant changes and wakes up the app
///when there is a change
class LocationWakeup {
  ///Constructs a LocationWakeup plugin
  LocationWakeup() {
    _subscription = LocationWakeupPlatform.instance.locationUpdates.listen(
      (event) {
        _streamController.add(toLocationResult(event));
      },
      // ignore: avoid_annotating_with_dynamic
      onError: (dynamic error) {
        if (error is PlatformException) {
          if (error.code == _locationPermissionDeniedErrorCode) {
            final locationResult = LocationResult.error(
              Error(
                message: error.message ?? 'Unknown permission related error',
                errorCode: ErrorCode.locationPermissionDenied,
              ),
              permissionStatus: error.details is Map
                  // ignore: avoid_dynamic_calls
                  ? switch (error.details['permissionStatus']) {
                      'granted' => PermissionStatus.granted,
                      'denied' => PermissionStatus.denied,
                      'permanentlyDenied' => PermissionStatus.permanentlyDenied,
                      'notDetermined' => PermissionStatus.notDetermined,
                      'restricted' => PermissionStatus.restricted,
                      'limited' => PermissionStatus.limited,
                      _ => PermissionStatus.notSpecified,
                    }
                  : PermissionStatus.notSpecified,
            );

            _streamController.add(locationResult);
          }

          return;
        }
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
  Stream<LocationResult> get locationUpdates => _streamController.stream;

  ///Disposes the plugin and stops listening to the system location changes
  Future<void> dispose() =>
      Future.wait([_subscription.cancel(), _streamController.close()]);
}
