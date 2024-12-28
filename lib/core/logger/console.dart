import 'package:remit/core/exports.dart';

class RemitConsoleLogger implements RemitLogger {
  const RemitConsoleLogger();

  @override
  void info(final String tag, final String text) {
    print('INFO $tag: $text');
  }

  @override
  void warn(
    final String tag,
    final String text, [
    final Object? err,
    final Object? stackTrace,
  ]) {
    print('WARN $tag: $text');
    if (err != null) {
      print(err);
    }
    if (stackTrace != null) {
      print(stackTrace);
    }
  }

  @override
  void error(
    final String tag,
    final String text, [
    final Object? err,
    final Object? stackTrace,
  ]) {
    print('ERROR! $tag: $text');
    if (err != null) {
      print(err);
    }
    if (stackTrace != null) {
      print(stackTrace);
    }
  }
}
