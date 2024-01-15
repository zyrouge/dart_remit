import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerConnectionAcceptedRoute
    extends RemitReceiverServerRoute {
  @override
  void use(final RemitReceiver receiver) {
    receiver.server.app.post(path, (final shelf.Request req) async {
      final String body = await req.readAsString();
      final Map<dynamic, dynamic>? data = jsonDecodeMapOrNull(body);
      final String? identifier = mapKeyOrNull(data, RemitDataKeys.identifier);
      final String? token = mapKeyOrNull(data, RemitDataKeys.token);
      if (data == null || identifier == null || token == null) {
        return shelf.Response.badRequest(
          body: RemitJsonBody.construct(false),
          headers: RemitHttpHeaders.construct(),
        );
      }
      receiver.onConnectionAccepted(identifier: identifier, token: token);
      return shelf.Response.ok(
        RemitJsonBody.construct(true),
        headers: RemitHttpHeaders.construct(),
      );
    });
  }

  static const String path = '/connection/accepted';
}
