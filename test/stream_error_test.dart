import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('streamError', () {
    late StreamController<LocationResult> streamController;

    setUp(() {
      streamController = StreamController<LocationResult>();
    });

    tearDown(() async {
      await streamController.close();
    });

    test('handles PlatformException with locationPermissionDeniedErrorCode',
        () async {
      final error = PlatformException(
        code: locationPermissionDeniedErrorCode,
        message: 'Permission denied',
        details: {'permissionStatus': 'denied'},
      );

      // Listen to the stream first
      final emittedEvents = streamController.stream.toList();

      streamError(streamController, error);

      // Then close the stream
      await streamController.close();

      // Now, check the emitted events
      expect(
        await emittedEvents,
        [
          const LocationResult.error(
            Error(
              message: 'Permission denied',
              errorCode: ErrorCode.locationPermissionDenied,
            ),
            permissionStatus: PermissionStatus.denied,
          ),
        ],
      );
    });

    test('handles PlatformException with unknown code', () async {
      final error = PlatformException(
        code: 'UNKNOWN_CODE',
        message: 'Unknown error',
      );

      // Listen to the stream first
      final emittedEvents = streamController.stream.toList();

      streamError(streamController, error);

      // Then close the stream
      await streamController.close();

      // Now, check the emitted events
      expect(
        await emittedEvents,
        [
          LocationResult.unknownError,
        ],
      );
    });

    test('handles non-PlatformException errors', () {
      final error = ArgumentError('Invalid argument');

      streamError(streamController, error);

      expect(
        streamController.stream,
        emits(
          LocationResult.unknownError,
        ),
      );
    });

    test('handles PlatformException with UNKNOWN_LOCATION_ERROR code',
        () async {
      final error = PlatformException(
        code: 'UNKNOWN_LOCATION_ERROR',
        message: 'Unknown location error',
        details: {'permissionStatus': 'notDetermined'},
      );

      // Listen to the stream first
      final emittedEvents = streamController.stream.toList();

      streamError(streamController, error);

      // Then close the stream
      await streamController.close();

      // Now, check the emitted events
      expect(
        await emittedEvents,
        [
          const LocationResult.error(
            Error(
              message: 'Unknown location error',
              errorCode: ErrorCode.unknown,
            ),
            permissionStatus: PermissionStatus.notDetermined,
          ),
        ],
      );
    });

  });
}
