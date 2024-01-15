import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';

class RemitReceiverConnection {
  RemitReceiverConnection({
    required this.sender,
    required this.connectedAt,
  }) : lastHeartbeatAt = connectedAt;

  final RemitSenderBasicInfo sender;
  final int connectedAt;

  int lastHeartbeatAt;
  String? identifier;
  String? token;

  Future<bool> ping() async {
    if (token == null) return false;
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitSenderServerPingRoute.path),
            headers: RemitHttpHeaders.construct(
              contentType: null,
              additional: <String, String>{
                RemitHeaderKeys.token: token ?? '',
              },
            ),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> connectionRequest() async {
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitSenderServerConnectionRequestRoute.path),
            headers: RemitHttpHeaders.construct(contentType: null),
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
            headers: RemitHttpHeaders.construct(
              contentType: null,
              additional: <String, String>{
                RemitHeaderKeys.token: token ?? '',
              },
            ),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
    } catch (_) {}
  }

  Uri constructSenderUri(final String path) => Uri(
        scheme: 'http',
        host: sender.host,
        port: sender.port,
        path: path,
      );
}
