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
      final bool? secure = mapKeyOrNull(data, RemitDataKeys.secure);
      if (data == null ||
          identifier == null ||
          token == null ||
          secure == null) {
        return shelf.Response.badRequest(
          body: RemitJsonBody.fail(),
          headers: RemitHttpHeaders.construct(),
        );
      }
      receiver.onConnectionAccepted(
        identifier: identifier,
        token: token,
        secure: secure,
      );
      return shelf.Response.ok(
        RemitJsonBody.success(),
        headers: RemitHttpHeaders.construct(),
      );
    });
  }

  static const String path = '/connection/accepted';
}
