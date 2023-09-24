# flutter_location_wakeup

`flutter_location_wakeup` is a Flutter plugin designed to listen for significant location changes on the device. When the changes are detected, the foreground app wakes up, or stays awake from suspension. Use this library when you need location changes to keep the foreground app alive, such as in the case of a navigation apps, or place based interaction apps.

The plugin's iOS implementation predominantly relies on Apple's [`startMonitoringSignificantLocationChanges`](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati) Swift API. For an in-depth understanding of its functionality, refer to Apple's official documentation. As of now, the plugin offers support exclusively for iOS, with Android support in the pipeline.

![Build Status Badge](https://github.com/MelbourneDeveloper/flutter_location_wakeup/actions/workflows/build.yaml/badge.svg)

<a href="https://codecov.io/gh/melbournedeveloper/flutter_location_wakeup"><img src="https://codecov.io/gh/melbournedeveloper/flutter_location_wakeup/branch/main/graph/badge.svg" alt="codecov"></a>

## Getting Started

### iOS Configuration

To set up the plugin for iOS, you need to request location permissions. Add the following keys to your Info.plist to describe the reasons for using the location:

```xml
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>We need your location for...</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>We need your location for...</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>We need your location for...</string>
```

### Sample Usage

For a comprehensive demonstration, refer to the example provided in the `example` directory. 

![Sample Usage](https://github.com/MelbourneDeveloper/flutter_location_wakeup/blob/main/images/example.png)

Test the functionality with the Freeway Drive feature of the iOS Simulator.

![Freeway Drive](https://github.com/MelbourneDeveloper/flutter_location_wakeup/blob/main/images/freewaydrive.png)

Below is a snippet showcasing a stateful widget that listens for location updates and presents them using a `SnackBar`:

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
      //Start listening before initializing
      _locationWakeup.locationUpdates.listen(
        (result) {
          if (!mounted) return;

          setState(() => onLocationResultChange(result));
        },
      );
      //Initialize
      await _locationWakeup.startMonitoring();
    } on PlatformException {
      // Handle exception
    }
  }

  void onLocationResultChange(LocationResult result) {
    _display = result.match(
        onSuccess: (l) => '''
Lat: ${l.latitude}
Long: ${l.longitude}
Altitude: ${l.altitude}
Horizontal Accuracy: ${l.horizontalAccuracy}
Vertical Accuracy: ${l.verticalAccuracy}
Course: ${l.course}
Speed: ${l.speed}
Timestamp: ${l.timestamp}
Floor Level: ${l.floorLevel}
''',
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
