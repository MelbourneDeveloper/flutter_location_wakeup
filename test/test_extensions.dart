import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_stream_handler.dart';

extension Dasdasd on WidgetTester {
  ///Initializes the plugin, ensures that the initialization
  ///reaches the platform side, and emits one event from
  ///the event channel.
  Future<R> initializeAndEmitOne<TPlugin, R>(
    TPlugin plugin,
    MethodChannel methodChannel,
    EventChannel eventChannel,
    Future<void> Function(TPlugin plugin) initializePlugin,
    Future<Object?>? Function(MethodCall)? handler,
    Map<String, dynamic> firstStreamData,
    Future<R> Function(TPlugin plugin) onEvent,
  ) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      methodChannel,
      handler,
    );

    TestWidgetsFlutterBinding.ensureInitialized();

    await initializePlugin(plugin);

    final methodCall = MethodCall('listen', firstStreamData);

    final encodedData =
        const StandardMethodCodec().encodeMethodCall(methodCall);

    binding.defaultBinaryMessenger.setMockStreamHandler(
      eventChannel,
      FakeStreamHandler(),
    );

    await eventChannel.binaryMessenger.send(eventChannel.name, encodedData);

    return onEvent(plugin);
  }
}
