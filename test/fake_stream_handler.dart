import 'package:flutter_test/flutter_test.dart';

class FakeStreamHandler extends MockStreamHandler {
  @override
  void onCancel(Object? arguments) {
    // TODO: implement onCancel
  }

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    events.success(arguments);
    // TODO: implement onListen
  }
}
