import 'dart:math';
import 'dart:typed_data';

abstract class SecureKey {
  static final Random random = Random.secure();

  static Uint8List generate(final int length) {
    final Uint8List bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  static Uint8List generate8bytes() => generate(8);
  static Uint8List generate32bytes() => generate(32);
}
