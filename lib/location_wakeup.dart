import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';

@visibleForTesting
// ignore: public_member_api_docs
const locationPermissionDeniedErrorCode = 'LOCATION_PERMISSION_DENIED';

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
      onError: (dynamic error) => streamError(_streamController, error),
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

@visibleForTesting
// ignore: public_member_api_docs
void streamError(
  StreamController<LocationResult> streamController,
  // ignore: avoid_annotating_with_dynamic
  dynamic error,
) {
  if (error is PlatformException) {
    if (error.code == locationPermissionDeniedErrorCode) {
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

      streamController.add(locationResult);
    }
    streamController.add(LocationResult.error(Error.unknown));
    return;
  }

}
