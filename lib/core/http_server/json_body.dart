import 'dart:convert';

typedef RemitHttpBodyData = (bool, Map<dynamic, dynamic>);

class RemitJsonBody {
  static const Map<dynamic, dynamic> defaultData = <dynamic, dynamic>{};

  static String construct(
    final bool success, [
    final Map<dynamic, dynamic> data = defaultData,
  ]) {
    final Map<dynamic, dynamic> output = <dynamic, dynamic>{
      'success': success,
      'data': data,
    };
    return jsonEncode(output);
  }

  static RemitHttpBodyData? deconstruct(final String body) {
    try {
      final Map<dynamic, dynamic> data =
          jsonDecode(body) as Map<dynamic, dynamic>;
      return (data['success'] as bool, data['data'] as Map<dynamic, dynamic>);
    } catch (_) {}
    return null;
  }

  static String success([final Map<dynamic, dynamic> data = defaultData]) =>
      construct(true, data);

  static String fail([final Map<dynamic, dynamic> data = defaultData]) =>
      construct(false, data);
}
