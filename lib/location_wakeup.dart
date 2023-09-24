import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  ///Stops listening to the system location changes and disposes platform
  ///resources. This plugin is only designed to start once, so if you need
  ///to listen again, you will need to create a new instance of this plugin.
  Future<void> stopMonitoring() => Future.wait([
        _subscription.cancel(),
        _streamController.close(),
        LocationWakeupPlatform.instance.stopMonitoring(),
      ]);

  ///A stream of location changes
  Stream<LocationResult> get locationUpdates => _streamController.stream;
}

@visibleForTesting
// ignore: public_member_api_docs
void streamError(
  StreamController<LocationResult> streamController,
  // ignore: avoid_annotating_with_dynamic
  dynamic error,
) {
  if (error is PlatformException) {
    String? permissionStatusString;
    if (error.details is Map) {
      final details = error.details as Map;
      permissionStatusString = details['permissionStatus'] as String?;
    }
    final errorCode = error.code.toErrorCode();
    streamController.add(
      LocationResult.error(
        Error(
          message: error.message ??
              (errorCode == ErrorCode.unknown
                  ? 'Unknown OS level error'
                  : 'Unknown permission related error'),
          errorCode: errorCode,
        ),
        permissionStatus: permissionStatusString.toPermissionStatus(),
      ),
    );
    return;
  }

  streamController.add(
    LocationResult.unknownError,
  );
}
