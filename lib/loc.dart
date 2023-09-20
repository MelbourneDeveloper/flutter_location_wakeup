
import 'loc_platform_interface.dart';

class Loc {
  Future<String?> getPlatformVersion() {
    return LocPlatform.instance.getPlatformVersion();
  }
}
