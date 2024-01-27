import 'package:remit/exports.dart';

typedef RemitJsonDataBody = RemitDataBody<Map<dynamic, dynamic>>;

class RemitDataBody<T> {
  const RemitDataBody({
    required this.success,
    required this.data,
    required this.error,
  }) : assert(data == null || data is String || data is Map<dynamic, dynamic>);

  factory RemitDataBody.fromJson(final Map<dynamic, dynamic> data) =>
      RemitDataBody<T>(
        success: data['success'] as bool,
        data: data['data'] as T?,
        error: data['error'] as String?,
      );

  factory RemitDataBody.fromString(final String data) =>
      RemitDataBody<T>.fromJson(jsonDecode(data) as Map<dynamic, dynamic>);

  final bool success;
  final T? data;
  final String? error;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'success': success,
        'data': data,
        'error': error,
      };

  @override
  String toString() => jsonEncode(toJson());

  static String construct<T>(
    final bool success, [
    final T? data,
    final String? error,
  ]) =>
      RemitDataBody<T>(success: success, data: data, error: error).toString();

  static RemitDataBody<T>? deconstruct<T>(final String body) {
    try {
      return RemitDataBody<T>.fromString(body);
    } catch (_) {}
    return null;
  }

  static String successful<T>([final T? data]) => construct<T>(true, data);

  static String failure<T>([
    final String? error,
    final T? data,
  ]) =>
      construct<T>(false, data, error);
}
