# flutter_location_wakeup

Listens for significant location changes the device and wakes it up when they arrive

Currently only supports iOS. Android version pending...

## Getting Started

### iOS

Add these to your `Info.plist`:

```xml
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>We need your location for...</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>We need your location for...</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>We need your location for...</string>
```

Check out the full working sample in the example folder. This is an example of a stateful widget to listen for location updates and display them in a `SnackBar`.

```dart
class _LocationDisplayState extends State<LocationDisplay> {
  String _display = 'Unknown';
  final _locationWakeup = LocationWakeup();

  @override
  void initState() {
    super.initState();
    startListening();
  }

  Future<void> startListening() async {
    if (!mounted) return;

    try {
      //Start listening to the stream before initizaling the plugin
      _locationWakeup.locationUpdates.listen(
        (result) {
          if (!mounted) return;

          setState(() => onLocationResultChange(result));
        },
      );
      //Initialize the plugin
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

  @override
  Widget build(BuildContext context) => Text(_display);
}
```

## More Info

The iOS implementation makes heavy use of the [`startMonitoringSignificantLocationChanges`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati) Swift API. You can read about how this works on Apple's website.
