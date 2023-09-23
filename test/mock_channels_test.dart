import 'package:flutter/services.dart';
import 'package:flutter_location_wakeup/flutter_location_wakeup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_stream_handler.dart';

void main() {
  testWidgets('Receives events from the event channel', (tester) async {
    var receivedStartMonitoring = false;

    final methodChannelLocationWakeup =
        LocationWakeupPlatform.instance as MethodChannelLocationWakeup;

    final locationData = <String, dynamic>{
      'latitude': 40.7128,
      'longitude': -74.0060,
      'altitude': 500.0,
      'speed': 5.0,
      'timestamp': 1677648652.0,
      'permissionStatus': 'granted',
    };

    final locationResult =
        await initializeAndEmitOne<LocationWakeup, LocationResult>(
      LocationWakeup(),
      tester,
      methodChannelLocationWakeup.channel,
      methodChannelLocationWakeup.eventChannel,
      (p) => p.startMonitoring(),
      (methodCall) async {
        if (methodCall.method == 'startMonitoring') {
          receivedStartMonitoring = true;
        }
        return null;
      },
      locationData,
      (p) => p.locationUpdates.first,
    );

    expect(receivedStartMonitoring, isTrue);
    expect(locationResult.locationOrEmpty.latitude, locationData['latitude']);
    expect(locationResult.locationOrEmpty.longitude, locationData['longitude']);
  });
}

///Initializes the plugin, ensures that the initialization
///reaches the platform side, and emits one event from 
///the event channel.
Future<R> initializeAndEmitOne<TPlugin, R>(
  TPlugin plugin,
  WidgetTester tester,
  MethodChannel methodChannel,
  EventChannel eventChannel,
  Future<void> Function(TPlugin plugin) initializePlugin,
  Future<Object?>? Function(MethodCall)? handler,
  Map<String, dynamic> firstStreamData,
  Future<R> Function(TPlugin plugin) onEvent,
) async {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    methodChannel,
    handler,
  );

  TestWidgetsFlutterBinding.ensureInitialized();

  await initializePlugin(plugin);

  final methodCall = MethodCall('listen', firstStreamData);

  final encodedData = const StandardMethodCodec().encodeMethodCall(methodCall);

  final fakeStreamHandler = FakeStreamHandler();
  tester.binding.defaultBinaryMessenger.setMockStreamHandler(
    eventChannel,
    fakeStreamHandler,
  );

  await eventChannel.binaryMessenger.send(eventChannel.name, encodedData);

  return onEvent(plugin);
}
