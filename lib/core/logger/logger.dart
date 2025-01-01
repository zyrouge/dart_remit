abstract class RemitLogger {
  const RemitLogger();

  void debug(
    final String tag,
    final String text, [
    final Object? err,
    final Object? stackTrace,
  ]);

  void info(
    final String tag,
    final String text, [
    final Object? err,
    final Object? stackTrace,
  ]);

  void warn(
    final String tag,
    final String text, [
    final Object? err,
    final Object? stackTrace,
  ]);

  void error(
    final String tag,
    final String text, [
    final Object? err,
    final Object? stackTrace,
  ]);
}
