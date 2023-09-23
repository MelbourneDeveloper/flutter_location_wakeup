import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';

final messengerStateKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    scaffoldMessengerKey: messengerStateKey,
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Get Significant Location Changes'),
      ),
      body: const Center(
        child: LocationDisplay(),
      ),
    ),
  ));
}

class LocationDisplay extends StatefulWidget {
  const LocationDisplay({Key? key}) : super(key: key);

  @override
  State<LocationDisplay> createState() => _LocationDisplayState();
}

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
