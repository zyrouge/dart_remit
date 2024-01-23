import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerPingRoute extends RemitReceiverServerRoute {
  @override
  void use(final RemitReceiver receiver) {
    receiver.server.app.post(
      path,
      (final shelf.Request req) {
        if (!isAuthenticated(receiver, req)) {
          return shelf.Response.unauthorized(
            RemitJsonBody.fail(),
            headers: RemitHttpHeaders.construct(),
          );
        }
        return shelf.Response.ok(
          RemitJsonBody.success(),
          headers: RemitHttpHeaders.construct(),
        );
      },
    );
  }

  static const String path = '/ping';
}
