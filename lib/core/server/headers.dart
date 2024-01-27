class RemitHttpHeaders {
  static const String userAgent = 'Remit v0';
  static const String jsonContentType = 'application/json';
  static const String binaryContentType = 'application/octet-stream';

  static Map<String, String> construct({
    final String? contentType = jsonContentType,
    final bool secure = false,
    final Map<String, String>? additional,
  }) {
    final Map<String, String> out = <String, String>{
      'User-Agent': userAgent,
      if (contentType != null) 'Content-Type': contentType,
      if (secure) 'Remit-Secure': '1',
      if (additional != null) ...additional,
    };
    return out;
  }

  static final RegExp rangeHeaderRegex = RegExp(r'^bytes=(\d*)-(\d*)$');

  static (int?, int?)? parseRangeHeader(final String value) {
    final RegExpMatch? match = rangeHeaderRegex.firstMatch(value);
    if (match == null) return null;
    return (int.tryParse(match.group(1)!), int.tryParse(match.group(2)!));
  }
}
