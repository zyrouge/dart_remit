import 'dart:io';
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

class RemitServer<RouteContext extends RemitServerRouteContext> {
  RemitServer._({
    required this.http,
    required this.app,
  });

  final HttpServer http;
  final shelf_router.Router app;
  late final RouteContext routeContext;

  Future<void> destroy() async {
    await http.close(force: true);
  }

  String get host => http.address.host;
  int get port => http.port;
  RemitConnectionAddress get address => RemitConnectionAddress(host, port);

  static Future<RemitServer<RouteContext>>
      createServer<RouteContext extends RemitServerRouteContext>(
    final RemitConnectionAddress address,
    final List<RemitServerRoute<RouteContext>> routes,
  ) async {
    final shelf_router.Router app = shelf_router.Router();
    final HttpServer http = await shelf_io.serve(
      app.call,
      address.host,
      address.port,
      poweredByHeader: RemitHttpHeaders.userAgent,
    );
    final RemitServer<RouteContext> server =
        RemitServer<RouteContext>._(app: app, http: http);
    for (final RemitServerRoute<RouteContext> x in routes) {
      app.add(
        x.method,
        x.path,
        (final shelf.Request request) =>
            x.onRequest(server.routeContext, request),
      );
    }
    return server;
  }

  static Future<List<InternetAddress>> getAvailableNetworks() async {
    final List<NetworkInterface> networks = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    return networks.expand((final NetworkInterface x) => x.addresses).toList();
  }
}
