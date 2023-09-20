import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'loc_platform_interface.dart';

/// An implementation of [LocPlatform] that uses method channels.
class MethodChannelLoc extends LocPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('loc');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
