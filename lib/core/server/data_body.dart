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
        error: mapKeyFactoryOrNull(data, 'error', RemitException.fromJson),
      );

  factory RemitDataBody.fromString(final String data) =>
      RemitDataBody<T>.fromJson(jsonDecode(data) as Map<dynamic, dynamic>);

  final bool success;
  final T? data;
  final RemitException? error;

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
    final RemitException? error,
  ]) =>
      RemitDataBody<T>(success: success, data: data, error: error).toString();

  static RemitDataBody<T>? deconstruct<T>(final String body) {
    try {
      return RemitDataBody<T>.fromString(body);
    } catch (_) {}
    return null;
  }

  static T deconstructJsonDataFactory<T>(
    final String body,
    final T Function(Map<dynamic, dynamic>) factoryFn,
  ) {
    final RemitJsonDataBody? data = RemitDataBody.deconstruct(body);
    if (data == null) {
      throw RemitException.invalidResponseData();
    }
    if (!data.success) {
      throw data.error ?? RemitException.nonSuccessResponse();
    }
    final T? info = jsonFactoryOrNull(data.data, factoryFn);
    if (info == null) {
      throw RemitException.unexpectedResponseData();
    }
    return info;
  }

  static String successful<T>([final T? data]) => construct<T>(true, data);

  static String failure<T>([
    final RemitException? error,
    final T? data,
  ]) =>
      construct<T>(false, data, error);
}
