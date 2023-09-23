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

      streamError(streamController, error);

      // Listen to the stream first
      final emittedEvents = streamController.stream.toList();

      // Then close the stream
      await streamController.close();

      // Now, check the emitted events
      expect(
        await emittedEvents,
        [
          LocationResult.error(
            const Error(
              message: 'Permission denied',
              errorCode: ErrorCode.locationPermissionDenied,
            ),
            permissionStatus: PermissionStatus.denied,
          ),
        ],
      );
    });

    test('handles PlatformException with unknown code', () {
      final error = PlatformException(
        code: 'UNKNOWN_CODE',
        message: 'Unknown error',
      );

      streamError(streamController, error);

      expect(streamController.stream, neverEmits(anything));
    });

    test('handles non-PlatformException errors', () {
      final error = ArgumentError('Invalid argument');

      streamError(streamController, error);

      expect(
        streamController.stream,
        emits(LocationResult.error(Error.unknown)),
      );
    });

    test('handles PlatformException with various permission statuses',
        () async {
      const statuses = PermissionStatus.values;
      for (final status in statuses) {
        final error = PlatformException(
          code: locationPermissionDeniedErrorCode,
          message: 'Permission $status',
          details: {'permissionStatus': status.toString().split('.').last},
        );

        streamError(streamController, error);
        await streamController.close();

        expect(
          streamController.stream,
          emitsInOrder([
            LocationResult.error(
              Error(
                message: 'Permission $status',
                errorCode: ErrorCode.locationPermissionDenied,
              ),
              permissionStatus: status,
            ),
            emitsDone,
          ]),
        );
      }
    });
  });
}
