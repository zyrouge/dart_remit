import 'package:remit/utils/semver.dart';

class RemitHttpHeaders {
  static final String userAgent = 'Remit v$version';
  static const SemVer version = SemVer(0, 0, 1);
  static const String jsonContentType = 'application/json';
  static const String binaryContentType = 'application/octet-stream';

  static Map<String, String> construct({
    final String? contentType = jsonContentType,
    final bool secure = false,
    final Map<String, String>? additional,
  }) {
    final Map<String, String> out = <String, String>{
      'User-Agent': userAgent,
      'Remit-Version': version.toString(),
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

  static String? createRangeHeader([final int? start, final int? end]) {
    if (start == null && end == null) return null;
    return '${start ?? ''}-${end ?? ''}';
  }
}
