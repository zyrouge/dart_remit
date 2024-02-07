import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerConnectionDisconnectRoute
    extends RemitSenderServerRoute {
  @override
  final String method = 'POST';

  @override
  final String path = '/connection/disconnect';

  @override
  Future<shelf.Response> onRequest(
    final RemitSenderServerRouteContext context,
    final shelf.Request request,
  ) async {
    if (!context.sender.secure) {
      return shelf.Response.forbidden(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final RemitSenderConnection? connection =
        context.identifyConnection(request);
    if (connection == null) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    connection.disconnect();
    return shelf.Response.ok(
      RemitDataBody.successful(),
      headers: RemitHttpHeaders.construct(),
    );
  }

  Future<void> makeRequest(
    final RemitReceiverConnection connection,
  ) async {
    await makeRequestPartial(
      address: connection.senderAddress,
      headers: RemitHttpHeaders.construct(
        contentType: null,
        additional: <String, String>{
          RemitHeaderKeys.token: connection.token ?? '',
        },
      ),
    );
  }

  static final RemitSenderServerConnectionDisconnectRoute instance =
      RemitSenderServerConnectionDisconnectRoute();
}
