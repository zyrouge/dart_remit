class RemitDataSerializerFactory<T> {
  const RemitDataSerializerFactory({
    required this.serialize,
    required this.deserialize,
  });

  final Map<dynamic, dynamic> Function(T) serialize;
  final T Function(Map<dynamic, dynamic>) deserialize;
}
