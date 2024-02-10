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

  Stream<List<int>> optionalEncryptStream(final Stream<List<int>> stream) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.encryptStream(data: stream, key: key);
    }
    return stream;
  }

  Stream<List<int>> optionalDecryptStream(
    final Stream<List<int>> stream,
  ) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.decryptStream(data: stream, key: key);
    }
    return stream;
  }

  bool get requiresEncryption;
  Uint8List? get secret;
}
