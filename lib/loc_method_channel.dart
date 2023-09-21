import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'loc_platform_interface.dart';

/// An implementation of [LocPlatform] that uses method channels.
class MethodChannelLoc extends LocPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel _channel = MethodChannel('loc');
  final EventChannel _eventChannel = EventChannel('loc_stream');

  Stream<Map<String, double>>? _locationUpdates;

  @override
  Future<void> startMonitoring() {
    return _channel.invokeMethod('startMonitoring');
  }

  @override
  Stream<Map<String, double>> get locationUpdates {
    _locationUpdates ??= _eventChannel.receiveBroadcastStream().map((event) {
      print('got data');
      return {
        'latitude': event['latitude'],
        'longitude': event['longitude'],
      };
    });
    return _locationUpdates!;
  }
}
