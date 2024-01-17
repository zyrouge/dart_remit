import 'package:remit/core/exports.dart';

class RemitConsoleLogger implements RemitLogger {
  const RemitConsoleLogger();

  @override
  void info(final String tag, final String text) {
    print('INFO $tag: $text');
  }

  @override
  void warn(final String tag, final String text) {
    print('WARN $tag: $text');
  }

  @override
  void error(final String tag, final String text) {
    print('ERROR! $tag: $text');
  }
}
