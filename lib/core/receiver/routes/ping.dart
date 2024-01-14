import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerPingRoute extends RemitReceiverServerRoute {
  @override
  void use(final RemitReceiver receiver) {
    receiver.server.app.post(
      path,
      (final shelf.Request req) => shelf.Response.ok(
        null,
        headers: RemitHttpHeaders.construct(),
      ),
    );
  }

  static const String path = '/ping';
}
