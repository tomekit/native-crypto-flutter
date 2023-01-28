import 'package:flutter_test/flutter_test.dart';
import 'package:native_crypto/native_crypto.dart';
import 'package:native_crypto/native_crypto_platform_interface.dart';
import 'package:native_crypto/native_crypto_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeCryptoPlatform
    with MockPlatformInterfaceMixin
    implements NativeCryptoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeCryptoPlatform initialPlatform = NativeCryptoPlatform.instance;

  test('$MethodChannelNativeCrypto is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeCrypto>());
  });

  test('getPlatformVersion', () async {
    NativeCrypto nativeCryptoPlugin = NativeCrypto();
    MockNativeCryptoPlatform fakePlatform = MockNativeCryptoPlatform();
    NativeCryptoPlatform.instance = fakePlatform;

    expect(await nativeCryptoPlugin.getPlatformVersion(), '42');
  });
}
