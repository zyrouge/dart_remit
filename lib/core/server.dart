import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'defaults.dart';

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

  static Future<RemitServer> createServer() async {
    final shelf_router.Router app = shelf_router.Router();
    final HttpServer http = await shelf_io.serve(
      app.call,
      RemitDefaults.universalHost,
      RemitDefaults.universalPort,
      poweredByHeader: 'Remit',
    );
    return RemitServer._(app: app, http: http);
  }
}
