import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import '../../core/defaults.dart';
import '../route.dart';
import '../slave.dart';

class RemitSlaveServerPingRoute extends RemitSlaveServerRoute {
  @override
  void use(final RemitSlave slave) {
    slave.server.app.get('/ping', (final shelf.Request req) {
      final String data = jsonEncode(<dynamic, dynamic>{
        'success': true,
      });
      return shelf.Response.ok(
        data,
        headers: RemitDefaults.headers(),
      );
    });
  }
}
