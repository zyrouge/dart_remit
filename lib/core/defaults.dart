class RemitDefaults {
  static const String universalHost = '0.0.0.0';
  static const int universalPort = 0;
  static const Duration heartbeatInterval = Duration(seconds: 15);
  static const Duration heartbeatTimeout = Duration(seconds: 10);

  static Map<String, String> headers({
    final bool jsonContentType = true,
  }) {
    final Map<String, String> out = <String, String>{
      'User-Agent': 'Remit',
      'Content-Type': 'text/plain',
    };
    if (jsonContentType) {
      out['Content-Type'] = 'application/json';
    }
    return out;
  }
}
