import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerPingRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request request) {
        if (!isAuthenticated(sender, request)) {
          return shelf.Response.unauthorized(
            RemitDataBody.failure(),
            headers: RemitHttpHeaders.construct(),
          );
        }
        return shelf.Response.ok(
          RemitDataBody.successful(),
          headers: RemitHttpHeaders.construct(),
        );
      },
    );
  }

  static const String path = '/ping';
}
