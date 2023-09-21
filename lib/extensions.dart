import 'package:loc/model.dart';

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

/// Extensions for [Map<String, double>]
extension LocationExtensions on Map<String, double> {
  ///Converts a map of latitude and longitude to a [LocationResult]
  LocationResult toLocationResult() {
    final latitude = this['latitude'];
    final longitude = this['longitude'];

    return latitude != null && longitude != null
        ? LocationResult(Location(latitude, longitude))
        : LocationResult.error(const Error('Latitude or longitude is missing'));
  }
}
