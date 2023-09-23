import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_stream_handler.dart';

extension Dasdasd on WidgetTester {
  ///Initializes the plugin, ensures that the initialization
  ///reaches the platform side, and emits one event from
  ///the event channel.
  Future<R> initializeAndEmitOne<TPlugin, R>({
    required TPlugin plugin,
    required MethodChannel methodChannel,
    required EventChannel eventChannel,
    required Future<void> Function(TPlugin plugin) initializePlugin,
    required Future<Object?>? Function(MethodCall)? methodHandler,
    required Map<String, dynamic> firstStreamData,
    required Future<R> Function(TPlugin plugin) onEvent,
  }) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      methodChannel,
      methodHandler,
    );

    binding.defaultBinaryMessenger.setMockStreamHandler(
      eventChannel,
      FakeStreamHandler(),
    );

    TestWidgetsFlutterBinding.ensureInitialized();

    await initializePlugin(plugin);

    final methodCall = MethodCall('listen', firstStreamData);

    final encodedData =
        const StandardMethodCodec().encodeMethodCall(methodCall);

    await eventChannel.binaryMessenger.send(eventChannel.name, encodedData);

    return onEvent(plugin);
  }
}
