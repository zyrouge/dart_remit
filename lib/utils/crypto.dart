import 'dart:math';

class UUID {
  static final Random random = Random.secure();
  static const String symbols =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const int symbolsLength = symbols.length;

  static String generate(final int length) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(generateChar());
    }
    return buffer.toString();
  }

  static String generateChar() => symbols[random.nextInt(symbolsLength)];
  static String generateToken() => generate(128);
  static String generateInviteCode() => generate(6);
}

class SequentialUUIDGenerator {
  int i = 0;

  int next() => i++;
}
