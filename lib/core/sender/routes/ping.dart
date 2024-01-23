import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerPingRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request req) {
        if (!isAuthenticated(sender, req)) {
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
