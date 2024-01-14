import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerConnectionAcceptedRoute
    extends RemitReceiverServerRoute {
  @override
  void use(final RemitReceiver receiver) {
    receiver.server.app.post(path, (final shelf.Request req) async {
      final String body = await req.readAsString();
      final RemitHttpBodyData? data = RemitJsonBody.deconstruct(body);
      if (data == null || !data.$1) {
        return shelf.Response.badRequest(
          body: RemitJsonBody.construct(false),
          headers: RemitHttpHeaders.construct(),
        );
      }
      receiver.onConnectionAccepted();
      return shelf.Response.ok(
        RemitJsonBody.construct(true),
        headers: RemitHttpHeaders.construct(),
      );
    });
  }

  static const String path = '/connection/accepted';
}
