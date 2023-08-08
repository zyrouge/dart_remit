class RemitClientHeaders {
  const RemitClientHeaders({
    required this.clientId,
    required this.clientSecret,
  });

  factory RemitClientHeaders.parse(final Map<dynamic, dynamic> json) =>
      RemitClientHeaders(
        clientId: json[kClientId] as String,
        clientSecret: json[kClientSecret] as String,
      );

  final String clientId;
  final String clientSecret;

  static const String kClientId = 'client_id';
  static const String kClientSecret = 'client_secret';
}
