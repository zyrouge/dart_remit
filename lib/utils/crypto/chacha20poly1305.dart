import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/macs/poly1305.dart';
import 'package:pointycastle/stream/chacha20poly1305.dart' as c;
import 'package:pointycastle/stream/chacha7539.dart';

typedef _ChaCha20Poly1305 = c.ChaCha20Poly1305;

// Source: https://github.com/leocavalcante/encrypt/blob/5.x/lib/src/algorithms/salsa20.dart
abstract class ChaCha20Poly1305 {
  static Uint8List encrypt({
    required final Uint8List data,
    required final Uint8List key,
    required final Uint8List iv,
  }) {
    final _ChaCha20Poly1305 encryptor = _buildEngine();
    encryptor.init(true, _buildParameters(key: key, iv: iv));
    return encryptor.process(data);
  }

  static Uint8List decrypt({
    required final Uint8List encrypted,
    required final Uint8List key,
    required final Uint8List iv,
  }) {
    final _ChaCha20Poly1305 decryptor = _buildEngine();
    decryptor.init(false, _buildParameters(key: key, iv: iv));
    return decryptor.process(encrypted);
  }

  static _ChaCha20Poly1305 _buildEngine() =>
      _ChaCha20Poly1305(ChaCha7539Engine(), Poly1305());

  static ParametersWithIV<KeyParameter> _buildParameters({
    required final Uint8List key,
    required final Uint8List iv,
  }) =>
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
}
