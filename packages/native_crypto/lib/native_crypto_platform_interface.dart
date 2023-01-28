import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_crypto_method_channel.dart';

abstract class NativeCryptoPlatform extends PlatformInterface {
  /// Constructs a NativeCryptoPlatform.
  NativeCryptoPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeCryptoPlatform _instance = MethodChannelNativeCrypto();

  /// The default instance of [NativeCryptoPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeCrypto].
  static NativeCryptoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeCryptoPlatform] when
  /// they register themselves.
  static set instance(NativeCryptoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
