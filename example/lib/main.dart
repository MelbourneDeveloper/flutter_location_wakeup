import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:loc/loc.dart';

final messengerStateKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(MaterialApp(
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
  String _latitude = 'Unknown Latitude';
  String _longitude = 'Unknown Longitude';
  final _locPlugin = Loc();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    try {
      _locPlugin.locationUpdates.listen(
        (result) {
          if (!mounted) return;
          setState(() {
            if (result is Success) {
              _latitude = result.value.latitude.toString();
              _longitude = result.value.longitude.toString();
            }
          });

          messengerStateKey.currentState.let(
            (state) async => state.showSnackBar(
              SnackBar(
                content: Text(
                  'Lat: $_latitude\nLong: $_longitude',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
        },
      );
      await _locPlugin.startMonitoring();
    } on PlatformException {
      // Handle exception
    }
  }

  @override
  Widget build(BuildContext context) =>
      Text('Lat: $_latitude\nLong: $_longitude');
}
