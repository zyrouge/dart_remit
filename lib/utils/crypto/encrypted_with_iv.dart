import 'dart:convert';
import 'dart:typed_data';

class EncryptedWithIV {
  const EncryptedWithIV({
    required this.encrypted,
    required this.iv,
  });

  factory EncryptedWithIV.parse(final Uint8List combined) {
    final int ivLength = combined.first;
    return EncryptedWithIV(
      encrypted: combined.sublist(ivLength),
      iv: combined.sublist(0, ivLength),
    );
  }

  factory EncryptedWithIV.fromBase64(final String data) =>
      EncryptedWithIV.parse(Uint8List.fromList(base64Decode(data)));

  final Uint8List encrypted;
  final Uint8List iv;

  Uint8List combine() => Uint8List(0)
    ..add(iv.length)
    ..addAll(iv)
    ..addAll(encrypted);
}
