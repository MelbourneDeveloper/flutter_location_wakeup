import 'package:flutter/services.dart';

import 'package:loc/loc_platform_interface.dart';

/// An implementation of [LocPlatform] that uses method channels.
class MethodChannelLoc extends LocPlatform {
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
