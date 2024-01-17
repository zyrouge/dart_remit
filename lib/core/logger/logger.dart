abstract class RemitLogger {
  const RemitLogger();

  void info(final String tag, final String text);
  void warn(final String tag, final String text);
  void error(final String tag, final String text);
}
