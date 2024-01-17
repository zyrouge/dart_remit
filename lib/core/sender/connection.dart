import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';

class RemitSenderConnection {
  RemitSenderConnection({
    required this.receiver,
    required this.token,
    required this.connectedAt,
    required this.secure,
  })  : identifier = UUID.generateIdentifier(),
        lastHeartbeatAt = connectedAt;

  final RemitReceiverBasicInfo receiver;
  final String token;
  final bool secure;

  final int connectedAt;
  final String identifier;
  int lastHeartbeatAt;
  SecureKey? secretKey;

  Future<bool> ping() async {
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitSenderServerPingRoute.path),
            headers: RemitHttpHeaders.construct(
              contentType: null,
              additional: <String, String>{
                RemitHeaderKeys.identifier: identifier,
              },
            ),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> connectionAccepted() async {
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitReceiverServerConnectionAcceptedRoute.path),
            headers: RemitHttpHeaders.construct(),
            body: jsonEncode(<dynamic, dynamic>{
              RemitDataKeys.identifier: identifier,
              RemitDataKeys.token: token,
              RemitDataKeys.secure: secure,
            }),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<void> disconnect() async {
    try {
      await http
          .post(
            constructSenderUri('/disconnect'),
            headers: RemitHttpHeaders.construct(contentType: null),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
    } catch (_) {}
  }

  Uri constructSenderUri(final String path) => Uri(
        scheme: 'http',
        host: receiver.host,
        port: receiver.port,
        path: path,
      );
}
