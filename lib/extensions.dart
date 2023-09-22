import 'package:flutter_location_wakeup/model.dart';

/// Extensions for nullable types
extension NullyExtensions<T> on T? {
  ///Allows you to perform an async action on a value only when that value is
  ///not null. and happens first because its synchronous
  Future<void> let(
    Future<void> Function(T) action, {
    void Function(T)? and,
  }) async {
    if (this != null) and?.call(this as T);
    return this != null ? action(this as T) : Future<void>.value();
  }
}

///Converts the platform data, possibly including the lat/log [LocationResult]
///to the result object
// ignore: avoid_annotating_with_dynamic
LocationResult toLocationResult(dynamic platformData) {

//Why doesnt this work as 

  if (platformData is Map<String, double>) {
    final latitude = platformData['latitude'];
    final longitude = platformData['longitude'];

    return latitude != null && longitude != null
        ? LocationResult(Location(latitude, longitude))
        : LocationResult.error(
            const Error('Latitude or longitude is missing'),
          );
  }

  throw UnimplementedError();
}
