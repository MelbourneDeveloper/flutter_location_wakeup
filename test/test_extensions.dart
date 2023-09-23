import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fake_stream_handler.dart';

extension TesterExtensions on WidgetTester {
  ///Creates a function that mimics the ability to send events to an
  ///EventChannel and therefore achieve full integration testing of Flutter
  ///plugins without, except for the native code
  // ignore: avoid_annotating_with_dynamic
  Future<void> Function(Map<String, dynamic>) getEventChannelSender({
    required MethodChannel methodChannel,
    required EventChannel eventChannel,
    required Future<Object?>? Function(MethodCall) methodHandler,
  }) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      methodChannel,
      methodHandler,
    );

    binding.defaultBinaryMessenger.setMockStreamHandler(
      eventChannel,
      FakeStreamHandler(),
    );

    // ignore: avoid_annotating_with_dynamic
    Future<void> send(Map<String, dynamic> platformData) async {
      final MethodCall methodCall;

      methodCall = MethodCall('listen', platformData);

      final encodedData =
          const StandardMethodCodec().encodeMethodCall(methodCall);

      await eventChannel.binaryMessenger.send(eventChannel.name, encodedData);
    }

    return send;
  }
}
