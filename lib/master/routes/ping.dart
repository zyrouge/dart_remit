import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import '../../core/defaults.dart';
import '../master.dart';
import '../route.dart';

class RemitSlaveServerPingRoute extends RemitMasterServerRoute {
  @override
  void use(final RemitMaster master) {
    master.server.app.get('/ping', (final shelf.Request req) {
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
