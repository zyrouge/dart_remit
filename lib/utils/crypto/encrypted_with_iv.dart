import 'dart:typed_data';

import 'package:remit/exports.dart';

class EncryptedWithIV {
  const EncryptedWithIV({
    required this.encrypted,
    required this.iv,
  }) : assert(iv.length == ChaCha20.ivSize);

  factory EncryptedWithIV.parse(final Uint8List combined) => EncryptedWithIV(
        encrypted: combined.sublist(ChaCha20.ivSize),
        iv: combined.sublist(0, ChaCha20.ivSize),
      );

  final Uint8List encrypted;
  final Uint8List iv;

  Uint8List combine() => Uint8List(iv.length + encrypted.length)
    ..setRange(0, ChaCha20.ivSize, iv)
    ..setRange(iv.length, iv.length + encrypted.length, encrypted);
}
