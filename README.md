# flutter_location_wakeup

Listens for significant location changes the device and wakes it up when they arrive

Currently only supports iOS. Android version pending...

## Getting Started

This is an example that you can use in the `State` of a stateful widget to listen for location updates and display them in a `SnackBar`:

## iOS

Add these to your `Info.plist`:

```xml
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>We need your location for...</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>We need your location for...</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>We need your location for...</string>
```

```dart
  Future<void> startListening() async {
    if (!mounted) return;

    try {
      _locationWakeup.locationUpdates.listen(
        (result) {
          if (!mounted) return;

          setState(() => onLocationResultChange(result));
        },
      );
      await _locationWakeup.startMonitoring();
    } on PlatformException {
      // Handle exception
    }
  }

  void onLocationResultChange(LocationResult result) {
    _display = result.match(
        onSuccess: (l) => 'Lat: ${l.latitude}\nLong: ${l.longitude}',
        onError: (e) => e.message);

    messengerStateKey.currentState.let(
      (state) async => state.showSnackBar(
        SnackBar(
          content: Text(
            _display,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(state.context).colorScheme.background,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }
```