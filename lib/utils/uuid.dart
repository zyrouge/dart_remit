import 'dart:math';

abstract class UUID {
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
  static String generateIdentifier() => generate(32);
  static String generateToken() => generate(128);
  static String generateInviteCode() => generate(6);
  static String generateLongIdentifier() => fromDateTime() + generate(48);

  static String fromNumber(final int value) {
    final StringBuffer buffer = StringBuffer();
    int i = value;
    while (i > 0) {
      buffer.write(symbols[i % 10]);
      i ~/= 10;
    }
    return buffer.toString();
  }

  static String fromDateTime([final DateTime? time]) =>
      fromNumber((time ?? DateTime.now()).millisecondsSinceEpoch);
}

class SequentialUUIDGenerator {
  int _i = 0;
  int next() => _i++;
}
