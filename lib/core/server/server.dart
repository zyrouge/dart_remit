import 'dart:io';
import 'package:remit/exports.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

class RemitServer {
  RemitServer._({
    required this.http,
    required this.app,
  });

  final HttpServer http;
  final shelf_router.Router app;

  Future<void> destroy() async {
    await http.close(force: true);
  }

  String get host => http.address.host;
  int get port => http.port;
  RemitConnectionAddress get address => RemitConnectionAddress(host, port);

  static Future<RemitServer> createServer(
    final RemitConnectionAddress address,
  ) async {
    final shelf_router.Router app = shelf_router.Router();
    final HttpServer http = await shelf_io.serve(
      app.call,
      address.host,
      address.port,
      poweredByHeader: RemitHttpHeaders.userAgent,
    );
    return RemitServer._(app: app, http: http);
  }

  static Future<List<InternetAddress>> getAvailableNetworks() async {
    final List<NetworkInterface> networks = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    return networks.expand((final NetworkInterface x) => x.addresses).toList();
  }
}
