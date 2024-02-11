import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/stream/chacha20.dart';

// Source: https://github.com/leocavalcante/encrypt/blob/5.x/lib/src/algorithms/salsa20.dart
abstract class ChaCha20 {
  static const int ivSize = 8;

  static Uint8List encrypt({
    required final Uint8List data,
    required final Uint8List key,
    required final Uint8List iv,
  }) {
    final ChaCha20Engine encryptor = _buildEngine();
    encryptor.init(true, _buildParameters(key: key, iv: iv));
    return encryptor.process(data);
  }

  static Uint8List decrypt({
    required final Uint8List encrypted,
    required final Uint8List key,
    required final Uint8List iv,
  }) {
    final ChaCha20Engine decryptor = _buildEngine();
    decryptor.init(false, _buildParameters(key: key, iv: iv));
    return decryptor.process(encrypted);
  }

  static ChaCha20Engine _buildEngine() => ChaCha20Engine();

  static ParametersWithIV<KeyParameter> _buildParameters({
    required final Uint8List key,
    required final Uint8List iv,
  }) =>
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
}
