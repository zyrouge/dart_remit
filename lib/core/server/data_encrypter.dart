import 'dart:convert';
import 'dart:typed_data';
import 'package:remit/exports.dart';

abstract class RemitDataEncrypter {
  static String encryptJson({
    required final Map<dynamic, dynamic> data,
    required final Uint8List key,
  }) {
    final String json = jsonEncode(data);
    final Uint8List bytes = utf8.encode(json);
    final Uint8List iv = SecureKey.generate8bytes();
    final Uint8List encrypted = ChaCha20.encrypt(data: bytes, key: key, iv: iv);
    final Uint8List combined =
        EncryptedWithIV(encrypted: encrypted, iv: iv).combine();
    return base64Encode(combined);
  }

  static Stream<List<int>> encryptStream({
    required final Stream<List<int>> data,
    required final Uint8List key,
    required final Uint8List iv,
  }) =>
      data.map(
        (final List<int> x) =>
            ChaCha20.encrypt(data: Uint8List.fromList(x), key: key, iv: iv),
      );

  static Map<dynamic, dynamic> decryptJson({
    required final String data,
    required final Uint8List key,
  }) {
    final Uint8List decoded = base64Decode(data);
    final EncryptedWithIV decombined = EncryptedWithIV.parse(decoded);
    final Uint8List decrypted = ChaCha20.decrypt(
      encrypted: decombined.encrypted,
      key: key,
      iv: decombined.iv,
    );
    final String json = utf8.decode(decrypted);
    return jsonDecodeMap(json);
  }

  static Stream<List<int>> decryptStream({
    required final Stream<List<int>> encrypted,
    required final Uint8List key,
    required final Uint8List iv,
  }) =>
      encrypted.map(
        (final List<int> x) => ChaCha20.decrypt(
          encrypted: Uint8List.fromList(x),
          key: key,
          iv: iv,
        ),
      );
}
