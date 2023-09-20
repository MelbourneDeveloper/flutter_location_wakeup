import 'package:flutter_test/flutter_test.dart';
import 'package:loc/loc.dart';
import 'package:loc/loc_platform_interface.dart';
import 'package:loc/loc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocPlatform
    with MockPlatformInterfaceMixin
    implements LocPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LocPlatform initialPlatform = LocPlatform.instance;

  test('$MethodChannelLoc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLoc>());
  });

  test('getPlatformVersion', () async {
    Loc locPlugin = Loc();
    MockLocPlatform fakePlatform = MockLocPlatform();
    LocPlatform.instance = fakePlatform;

    expect(await locPlugin.getPlatformVersion(), '42');
  });
}
