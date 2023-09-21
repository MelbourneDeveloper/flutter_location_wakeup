import 'package:loc/loc_platform_interface.dart';

///Allows you to perform an async action on a value only when that value is not
///null. and happens first because its synchronous
extension NullyExtensions<T> on T? {
  Future<void> let(
    Future<void> Function(T) action, {
    void Function(T)? and,
  }) async {
    if (this != null) and?.call(this as T);
    return this != null ? action(this as T) : Future<void>.value();
  }
}

class Result {
  Result(this._location) : _error = null;
  Result.error(this._error) : _location = null;

  final Location? _location;
  final Error? _error;

  bool get isSuccess => _location != null;
  bool get isError => _error != null;

  T match<T>({
    required T Function(Location location) onSuccess,
    required T Function(Error error) onError,
  }) =>
      isSuccess ? onSuccess(_location!) : onError(_error!);

  Location locationOr(Location Function(Error error) onError) =>
      isSuccess ? _location! : onError(_error!);
}

class Error {
  Error(this.message);
  final String message;
}

class Location {
  Location(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class Loc {
  Future<void> startMonitoring() => LocPlatform.instance.startMonitoring();

  Stream<Result> get locationUpdates => LocPlatform.instance.locationUpdates
      .map((map) => Result(Location(map['latitude']!, map['longitude']!)));
}
