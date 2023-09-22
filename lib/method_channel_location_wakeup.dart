///The flutter_location_wakeup library
library flutter_location_wakeup;

import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/location_wakeup_platform.dart';

/// An implementation of [LocationWakeupPlatform] that uses method channels.
class MethodChannelLocationWakeup extends LocationWakeupPlatform {
  final MethodChannel _channel = const MethodChannel('loc');
  final EventChannel _eventChannel = const EventChannel('loc_stream');

  Stream<Map<String, double>>? _locationUpdates;

  @override
  Future<void> startMonitoring() => _channel.invokeMethod('startMonitoring');

  @override
  Stream<Map<String, double>> get locationUpdates {
    _locationUpdates ??= _eventChannel.receiveBroadcastStream().map(
          (event) => {
            // ignore: avoid_dynamic_calls
            'latitude': event['latitude'] as double,
            // ignore: avoid_dynamic_calls
            'longitude': event['longitude'] as double,
          },
        );
    return _locationUpdates!;
  }
}
