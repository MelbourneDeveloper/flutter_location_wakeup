import 'loc_platform_interface.dart';

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

abstract class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isError => this is Error<T, E>;

  T get value {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).value;
    }
    throw StateError('value called on Result in Error state');
  }

  E get error {
    if (this is Error<T, E>) {
      return (this as Error<T, E>).error;
    }
    throw StateError('error called on Result in Success state');
  }
}

class Success<T, E> extends Result<T, E> {
  @override
  final T value;
  Success(this.value);
}

class Error<T, E> extends Result<T, E> {
  @override
  final E error;
  Error(this.error);
}

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);
}

class Loc {
  Future<void> startMonitoring() {
    return LocPlatform.instance.startMonitoring();
  }

  Stream<Result<Location, String>> get locationUpdates {
    return LocPlatform.instance.locationUpdates
        .map((event) => Success(Location(34.0522, 118.2437)));
  }
}
