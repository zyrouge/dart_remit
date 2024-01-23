import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerPingRoute extends RemitReceiverServerRoute {
  @override
  void use(final RemitReceiver receiver) {
    receiver.server.app.post(
      path,
      (final shelf.Request req) {
        final String? senderIdentifier =
            req.headers[RemitHeaderKeys.identifier];
        if (receiver.connection.identifier != senderIdentifier) {
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
