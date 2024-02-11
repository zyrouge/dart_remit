import 'dart:typed_data';
import 'package:remit/exports.dart';

mixin RemitOptionalDataEncrypter {
  String optionalEncryptJson(final Map<dynamic, dynamic> data) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.encryptJson(data: data, key: key);
    }
    return jsonEncode(data);
  }

  Map<dynamic, dynamic>? optionalDecryptJsonOrNull(final String data) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.decryptJson(data: data, key: key);
    }
    return jsonDecodeMap(data);
  }

  Stream<List<int>> optionalEncryptStream({
    required final Stream<List<int>> stream,
    required final Uint8List? iv,
  }) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      if (iv == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.encryptStream(data: stream, key: key, iv: iv);
    }
    return stream;
  }

  Stream<List<int>> optionalDecryptStream({
    required final Stream<List<int>> stream,
    required final Uint8List? iv,
  }) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      if (iv == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.decryptStream(
        encrypted: stream,
        key: key,
        iv: iv,
      );
    }
    return stream;
  }

  bool get requiresEncryption;
  Uint8List? get secret;
}
