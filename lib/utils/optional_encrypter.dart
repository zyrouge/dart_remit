import 'dart:typed_data';
import 'package:remit/exports.dart';

mixin RemitOptionalDataEncrypter {
  dynamic optionalEncryptJson(final Map<dynamic, dynamic> data) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.encryptJson(data: data, key: key);
    }
    return data;
  }

  Map<dynamic, dynamic>? optionalDecryptJsonOrNull(final dynamic data) {
    if (requiresEncryption) {
      final Uint8List? key = secret;
      if (key == null) {
        throw RemitException.missingSecretKey();
      }
      if (data is! String) return null;
      return RemitDataEncrypter.decryptJson(data: data, key: key);
    }
    if (data is! Map<dynamic, dynamic>) return null;
    return data;
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
