import 'package:pointycastle/api.dart';
import 'package:remit/exports.dart';

export 'package:pointycastle/random/fortuna_random.dart' show FortunaRandom;

FortunaRandom createFortunaRandom() {
  final FortunaRandom random = FortunaRandom();
  random.seed(KeyParameter(SecureKey.generate32bytes()));
  return random;
}
