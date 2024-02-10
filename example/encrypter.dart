import 'dart:typed_data';
import 'package:remit/exports.dart';

Future<void> main() async {
  final Uint8List key = SecureKey.generate32bytes();
  final Uint8List iv = SecureKey.generate12bytes();
  final Uint8List encrypted = ChaCha20Poly1305.encrypt(
    data: Uint8List.fromList(<int>[0, 1, 2, 3, 4, 5, 6, 7]),
    key: key,
    iv: iv,
  );
  print(encrypted);
  final Uint8List decrypted = ChaCha20Poly1305.decrypt(
    encrypted: encrypted,
    key: key,
    iv: iv,
  );
  print(decrypted);
}
