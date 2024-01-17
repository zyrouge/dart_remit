import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';

class SecureKey {
  const SecureKey(this.bytes);

  factory SecureKey.fromHexString(final String value) =>
      SecureKey(Uint8List.fromList(hex.decode(value)));

  factory SecureKey.generate(final int length) {
    final Uint8List bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return SecureKey(bytes);
  }

  factory SecureKey.generate32bits() => SecureKey.generate(32);

  final Uint8List bytes;

  String toHexString() => hex.encode(bytes);

  static final Random random = Random.secure();
}
