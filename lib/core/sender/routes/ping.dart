import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerPingRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request req) => shelf.Response.ok(
        RemitJsonBody.construct(true),
        headers: RemitHttpHeaders.construct(),
      ),
    );
  }

  static const String path = '/ping';
}
