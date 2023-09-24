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

  /// ⚠️ Don't use this. If you want to mock incoming events from the device
  /// platform for testing, see the mock_channels_test where it mocks
  /// incoming events from the device platform.
  ///
  /// However, if you are building and implementation for a platform, you can
  /// use this to set the static instance of [LocationWakeupPlatform].
  // coverage:ignore-start
  static set instance(LocationWakeupPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  // coverage:ignore-end

  ///Start listening for location changes
  Future<void> startMonitoring();

  ///Stops listening to the system location changes and disposes platform
  ///resources. This plugin is only designed to start once, so if you need
  ///to listen again, you will need to create a new instance of this plugin.
  Future<void> stopMonitoring();

  ///A stream of location changes
  Stream<dynamic> get locationUpdates;
}
