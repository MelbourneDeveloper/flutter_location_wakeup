import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'loc_method_channel.dart';

abstract class LocPlatform extends PlatformInterface {
  /// Constructs a LocPlatform.
  LocPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocPlatform _instance = MethodChannelLoc();

  /// The default instance of [LocPlatform] to use.
  ///
  /// Defaults to [MethodChannelLoc].
  static LocPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocPlatform] when
  /// they register themselves.
  static set instance(LocPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> startMonitoring();
  Stream<Map<String, double>> get locationUpdates;
}
