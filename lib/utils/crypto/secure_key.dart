import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';

abstract class SecureKey {
  static final Random random = Random.secure();

  static Uint8List generate(final int length) {
    final Uint8List bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  static Uint8List generate12bits() => generate(12);
  static Uint8List generate32bits() => generate(32);

  List<int> parseHexString(final String data) => hex.decode(data);
  String toHexString(final List<int> data) => hex.encode(data);
}
