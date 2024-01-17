import 'dart:convert';

class RemitJsonBodyData {
  const RemitJsonBodyData({
    required this.success,
    required this.data,
    required this.error,
  });

  final bool success;
  final Map<dynamic, dynamic> data;
  final String? error;
}

class RemitJsonBody {
  static const Map<dynamic, dynamic> defaultData = <dynamic, dynamic>{};

  static String construct(
    final bool success, [
    final Map<dynamic, dynamic> data = defaultData,
    final String? error,
  ]) {
    final Map<dynamic, dynamic> output = <dynamic, dynamic>{
      'success': success,
      'data': data,
      'error': error,
    };
    return jsonEncode(output);
  }

  static RemitJsonBodyData? deconstruct(final String body) {
    try {
      final Map<dynamic, dynamic> data =
          jsonDecode(body) as Map<dynamic, dynamic>;
      return RemitJsonBodyData(
        success: data['success'] as bool,
        data: data['data'] as Map<dynamic, dynamic>,
        error: data['error'] as String?,
      );
    } catch (_) {}
    return null;
  }

  static String success([final Map<dynamic, dynamic> data = defaultData]) =>
      construct(true, data);

  static String fail([
    final String? error,
    final Map<dynamic, dynamic> data = defaultData,
  ]) =>
      construct(false, data, error);
}
