import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_crypto_platform_interface.dart';

/// An implementation of [NativeCryptoPlatform] that uses method channels.
class MethodChannelNativeCrypto extends NativeCryptoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_crypto');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
