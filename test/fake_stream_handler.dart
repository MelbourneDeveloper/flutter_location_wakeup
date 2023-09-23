import 'package:flutter_test/flutter_test.dart';

///Just a dummy implementation to satisfy the way setMockStreamHandler
///works in the Flutter test framework
class FakeStreamHandler extends MockStreamHandler {
  @override
  void onCancel(Object? arguments) {}

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    events.success(arguments);
  }
}
