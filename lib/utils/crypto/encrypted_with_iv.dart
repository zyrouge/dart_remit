import 'dart:convert';
import 'dart:typed_data';

class EncryptedWithIV {
  const EncryptedWithIV({
    required this.encrypted,
    required this.iv,
  });

  factory EncryptedWithIV.parse(final Uint8List combined) => EncryptedWithIV(
        encrypted: combined.sublist(ivLength),
        iv: combined.sublist(0, ivLength),
      );

  factory EncryptedWithIV.fromBase64(final String data) =>
      EncryptedWithIV.parse(Uint8List.fromList(base64Decode(data)));

  final Uint8List encrypted;
  final Uint8List iv;

  Uint8List combine() => Uint8List(iv.length + encrypted.length)
    ..setRange(0, ivLength, iv)
    ..setRange(iv.length, iv.length + encrypted.length, encrypted);

  static const int ivLength = 12;
}
