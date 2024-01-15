import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';

export 'package:pointycastle/asymmetric/api.dart' show RSAPublicKey;

// Source: https://github.com/bcgit/pc-dart/blob/master/tutorials/rsa.md,
//         https://github.com/leocavalcante/encrypt/blob/5.x/lib/src/algorithms/rsa.dart
abstract class RSA {
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair(
    final SecureRandom secureRandom, {
    final int bitLength = 2048,
  }) {
    final RSAKeyGenerator keyGen = RSAKeyGenerator();
    keyGen.init(
      ParametersWithRandom<RSAKeyGeneratorParameters>(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom,
      ),
    );
    final AsymmetricKeyPair<PublicKey, PrivateKey> pair =
        keyGen.generateKeyPair();
    final RSAPublicKey publicKey = pair.publicKey as RSAPublicKey;
    final RSAPrivateKey privateKey = pair.privateKey as RSAPrivateKey;
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      publicKey,
      privateKey,
    );
  }

  static Uint8List encrypt({
    required final Uint8List data,
    required final RSAPublicKey publicKey,
  }) {
    final PKCS1Encoding encryptor = PKCS1Encoding(RSAEngine());
    encryptor.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return encryptor.process(data);
  }

  static Uint8List decrypt({
    required final Uint8List encrypted,
    required final RSAPublicKey publicKey,
  }) {
    final PKCS1Encoding decryptor = PKCS1Encoding(RSAEngine());
    decryptor.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    return decryptor.process(encrypted);
  }
}
