
import 'package:flutter_location_wakeup/method_channel_location_wakeup.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

///The interface that implementations of flutter_location_wakeup must implement.
abstract class LocationWakeupPlatform extends PlatformInterface {
  /// Constructs a LocationWakeupPlatform.
  LocationWakeupPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocationWakeupPlatform _instance = MethodChannelLocationWakeup();

  /// The default instance of [LocationWakeupPlatform] to use.
  static LocationWakeupPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  static set instance(LocationWakeupPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  ///Start listening for location changes
  Future<void> startMonitoring();

  ///A stream of location changes
  Stream<Map<String, double>> get locationUpdates;
}
