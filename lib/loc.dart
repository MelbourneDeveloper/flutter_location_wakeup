import 'package:loc/loc_platform_interface.dart';
import 'package:loc/model.dart';



class Loc {
  Future<void> startMonitoring() => LocPlatform.instance.startMonitoring();

  Stream<LocationResult> get locationUpdates =>
      LocPlatform.instance.locationUpdates.map(
        (map) => LocationResult(Location(map['latitude']!, map['longitude']!)),
      );
}
