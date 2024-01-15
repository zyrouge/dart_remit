class RemitHttpHeaders {
  static const String userAgent = 'Remit v0';
  static const String jsonContentType = 'application/json';

  static Map<String, String> construct({
    final String? contentType = jsonContentType,
    final Map<String, String>? additional,
  }) {
    final Map<String, String> out = <String, String>{
      'User-Agent': userAgent,
      if (contentType != null) 'Content-Type': contentType,
      if (additional != null) ...additional,
    };
    return out;
  }
}
