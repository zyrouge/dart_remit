import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerInfoRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request request) => shelf.Response.ok(
        RemitDataBody.successful(sender.info.toJson()),
        headers: RemitHttpHeaders.construct(),
      ),
    );
  }

  static const String path = '/info';
}
