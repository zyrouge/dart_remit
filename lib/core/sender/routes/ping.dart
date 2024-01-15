import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerPingRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request req) {
        final String? receiverToken = req.headers[RemitHeaderKeys.token];
        if (!sender.tokens.containsKey(receiverToken)) {
          return shelf.Response.unauthorized(
            RemitJsonBody.construct(false),
            headers: RemitHttpHeaders.construct(),
          );
        }
        return shelf.Response.ok(
          RemitJsonBody.construct(true),
          headers: RemitHttpHeaders.construct(),
        );
      },
    );
  }

  static const String path = '/ping';
}
