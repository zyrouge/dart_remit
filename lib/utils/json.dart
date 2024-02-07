import 'dart:convert';

export 'dart:convert' show jsonDecode, jsonEncode;

dynamic jsonDecodeOrNull(final String source) {
  try {
    return jsonDecode(source);
  } catch (_) {}
}

Map<dynamic, dynamic> jsonDecodeMap(final String source) =>
    jsonDecode(source) as Map<dynamic, dynamic>;

Map<dynamic, dynamic>? jsonDecodeMapOrNull(final String source) {
  try {
    return jsonDecode(source) as Map<dynamic, dynamic>;
  } catch (_) {}
  return null;
}

V? jsonFactoryOrNull<U, V>(
  final Map<dynamic, dynamic>? map,
  final V Function(U) factoryFn,
) {
  if (map == null) return null;
  try {
    return factoryFn(map as U);
  } catch (_) {}
  return null;
}

T? mapKeyOrNull<T>(final Map<dynamic, dynamic>? map, final dynamic key) {
  if (map == null) return null;
  try {
    return map[key] as T;
  } catch (_) {}
  return null;
}

V? mapKeyFactoryOrNull<U, V>(
  final Map<dynamic, dynamic>? map,
  final dynamic key,
  final V Function(U) factoryFn,
) {
  if (map == null) return null;
  try {
    return factoryFn(map[key] as U);
  } catch (_) {}
  return null;
}

List<V>? mapKeyAsListOrNull<U, V>(
  final Map<dynamic, dynamic>? map,
  final dynamic key,
) {
  if (map == null) return null;
  try {
    return (map[key] as List<dynamic>).cast<V>();
  } catch (_) {}
  return null;
}
