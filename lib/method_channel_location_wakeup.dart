import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/location_wakeup_platform.dart';

/// An implementation of [LocationWakeupPlatform] that uses method channels.
class MethodChannelLocationWakeup extends LocationWakeupPlatform {
  final MethodChannel _channel = const MethodChannel('loc');
  final EventChannel _eventChannel = const EventChannel('loc_stream');

  Stream<dynamic>? _locationUpdates;

  @override
  Future<void> startMonitoring() => _channel.invokeMethod('startMonitoring');

  @override
  Stream<dynamic> get locationUpdates {
    _locationUpdates ??= _eventChannel.receiveBroadcastStream();
    return _locationUpdates!;
  }
}
