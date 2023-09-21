import 'package:loc/extensions.dart';
import 'package:loc/loc_platform_interface.dart';
import 'package:loc/model.dart';

class Loc {
  Future<void> startMonitoring() => LocPlatform.instance.startMonitoring();

  Stream<LocationResult> get locationUpdates =>
      LocPlatform.instance.locationUpdates.map(
        (map) => map.toLocationResult(),
      );
}
