///The result of a location change from the device
class LocationResult {
  ///Successful result
  LocationResult(Location location)
      : _location = location,
        _error = null;

  ///Error from the device
  LocationResult.error(Error error)
      : _error = error,
        _location = null;

  final Location? _location;
  final Error? _error;

  ///True if the result is a success
  bool get isSuccess => _location != null;

  ///True if the result is an error
  bool get isError => _error != null;

  ///Allows you to access the location if it is successful or
  ///the error if it is not
  T match<T>({
    required T Function(Location location) onSuccess,
    required T Function(Error error) onError,
  }) =>
      isSuccess ? onSuccess(_location!) : onError(_error!);

  ///Allows you to access the location if it is successful or
  ///to replace the location with a different value based on an error
  Location locationOr(Location Function(Error error) onError) =>
      isSuccess ? _location! : onError(_error!);

  /// Returns the location if it's successful, or an empty location if it's an
  /// error.
  Location get locationOrEmpty => _location ?? Location.empty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationResult &&
        other._location == _location &&
        other._error == _error;
  }

  @override
  int get hashCode => _location.hashCode ^ _error.hashCode;

  @override
  String toString() => 'LocationResult(_location: $_location, _error: $_error)';
}

///Represents the type of error that occurred at the device level
enum ErrorCode {
  ///The app doesn't have permission to access location
  locationPermissionDenied,

  ///No known information from the device about what went wrong
  unknown,
}

///Represents an error from the device in regards to location
class Error {
  ///Creates an error with the given message and error code
  const Error({required this.message, required this.errorCode});

  ///The textual message of the error
  final String message;

  ///The error code representing the type of error
  final ErrorCode errorCode;

  ///Represents an unknown error with no information from the device
  static const unknown = Error(
    message: 'Unknown',
    errorCode: ErrorCode.unknown,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Error &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => message.hashCode ^ errorCode.hashCode;

  @override
  String toString() => 'Error(message: $message, errorCode: $errorCode)';
}

///Represents a location on earth by latitude and longitude
class Location {
  ///Creates a location with the given latitude and longitude
  const Location(this.latitude, this.longitude);

  ///The latitude of the location
  final double latitude;

  ///The longitude of the location
  final double longitude;

  ///Represents an empty or undefined location
  static const empty = Location(double.nan, double.nan);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Location &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'Location(latitude: $latitude, longitude: $longitude)';
}
