import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/location_wakeup_platform.dart';

/// An implementation of [LocationWakeupPlatform] that uses method channels.
class MethodChannelLocationWakeup extends LocationWakeupPlatform {
  @visibleForTesting
  // ignore: public_member_api_docs
  final MethodChannel channel = const MethodChannel('loc');

  @visibleForTesting
  // ignore: public_member_api_docs
  final EventChannel eventChannel = const EventChannel('loc_stream');

  Stream<dynamic>? _locationUpdates;

  @override
  Future<void> startMonitoring() => channel.invokeMethod('startMonitoring');

  @override
  Future<void> stopMonitoring() => channel.invokeMethod('stopMonitoring');

  @override
  Stream<dynamic> get locationUpdates {
    _locationUpdates ??= eventChannel.receiveBroadcastStream();
    return _locationUpdates!;
  }
}
