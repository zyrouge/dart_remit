import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/stream/chacha20.dart';

// Source: https://github.com/leocavalcante/encrypt/blob/5.x/lib/src/algorithms/salsa20.dart
abstract class ChaCha20 {
  static Uint8List encrypt({
    required final Uint8List data,
    required final Uint8List key,
    required final Uint8List iv,
  }) {
    final ChaCha20Engine encryptor = ChaCha20Engine();
    encryptor.init(true, buildParameters(key: key, iv: iv));
    return encryptor.process(data);
  }

  static Uint8List decrypt({
    required final Uint8List encrypted,
    required final Uint8List key,
    required final Uint8List iv,
  }) {
    final ChaCha20Engine decryptor = ChaCha20Engine();
    decryptor.init(false, buildParameters(key: key, iv: iv));
    return decryptor.process(encrypted);
  }

  static ParametersWithIV<KeyParameter> buildParameters({
    required final Uint8List key,
    required final Uint8List iv,
  }) =>
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
}
