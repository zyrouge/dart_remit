import 'package:http/http.dart' as http;
import '../core/exports.dart';

class RemitMasterSlaveConnection {
  RemitMasterSlaveConnection({
    required this.id,
    required this.secret,
    required this.host,
    required this.port,
    required this.connectedAt,
    required this.lastHeartbeatAt,
  });

  final String id;
  final String secret;
  final String host;
  final int port;
  final int connectedAt;
  int lastHeartbeatAt;

  Future<bool> isAwake() async {
    try {
      final http.Response resp =
          await http.post(uri('ping')).timeout(RemitDefaults.heartbeatTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<void> close() async {
    try {
      await http.post(uri('close'));
    } catch (_) {}
  }

  Uri uri(final String path) => Uri(
        scheme: 'http',
        host: host,
        port: port,
        path: path,
      );
}
