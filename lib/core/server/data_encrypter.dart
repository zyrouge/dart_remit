import 'dart:convert';
import 'dart:typed_data';
import 'package:remit/exports.dart';

abstract class RemitDataEncrypter {
  static Uint8List encryptBytes({
    required final Uint8List data,
    required final Uint8List key,
  }) {
    final Uint8List iv = SecureKey.generate12bits();
    final Uint8List encrypted =
        ChaCha20Poly1305.encrypt(data: data, key: key, iv: iv);
    return EncryptedWithIV(encrypted: encrypted, iv: iv).combine();
  }

  static String encryptJson({
    required final Map<dynamic, dynamic> data,
    required final Uint8List key,
  }) {
    final Uint8List bytes = utf8.encode(jsonEncode(data));
    return base64Encode(encryptBytes(data: bytes, key: key));
  }

  static Stream<List<int>> encryptStream({
    required final Stream<List<int>> data,
    required final Uint8List key,
  }) =>
      data.map(
        (final List<int> x) => RemitDataEncrypter.encryptBytes(
          data: Uint8List.fromList(x),
          key: key,
        ),
      );

  static Uint8List decryptBytes({
    required final Uint8List data,
    required final Uint8List key,
  }) {
    final EncryptedWithIV combined = EncryptedWithIV.parse(data);
    return ChaCha20Poly1305.decrypt(
      encrypted: combined.encrypted,
      key: key,
      iv: combined.iv,
    );
  }

  static Map<dynamic, dynamic> decryptJson({
    required final String data,
    required final Uint8List key,
  }) {
    final Uint8List bytes = base64Decode(data);
    final Uint8List decrypted = decryptBytes(data: bytes, key: key);
    return jsonDecode(utf8.decode(decrypted)) as Map<dynamic, dynamic>;
  }

  static Stream<List<int>> decryptStream({
    required final Stream<List<int>> data,
    required final Uint8List key,
  }) =>
      data.map(
        (final List<int> x) => RemitDataEncrypter.decryptBytes(
          data: Uint8List.fromList(x),
          key: key,
        ),
      );
}
