class RemitClientHeaders {
  const RemitClientHeaders({
    required this.clientId,
  });

  factory RemitClientHeaders.parse(final Map<dynamic, dynamic> json) =>
      RemitClientHeaders(
        clientId: json[kToken] as String,
      );

  final String clientId;

  static const String kToken = 'rmt_token';
}
