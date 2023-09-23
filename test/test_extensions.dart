import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_stream_handler.dart';

extension Dasdasd on WidgetTester {
  ///Initializes the plugin, ensures that the initialization
  ///reaches the platform side, and emits one event from
  ///the event channel.
  Future<void> Function(Map<String, dynamic>)
      getEventChannelSender<TPlugin, R>({
    required MethodChannel methodChannel,
    required EventChannel eventChannel,
    required Future<Object?>? Function(MethodCall)? methodHandler,
  }) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      methodChannel,
      methodHandler,
    );

    binding.defaultBinaryMessenger.setMockStreamHandler(
      eventChannel,
      FakeStreamHandler(),
    );

    TestWidgetsFlutterBinding.ensureInitialized();

    Future<void> send(Map<String, dynamic> firstStreamData) async {
      final methodCall = MethodCall('listen', firstStreamData);

      final encodedData =
          const StandardMethodCodec().encodeMethodCall(methodCall);

      await eventChannel.binaryMessenger.send(eventChannel.name, encodedData);
    }

    return send;
  }
}
