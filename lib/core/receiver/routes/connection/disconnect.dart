import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerConnectionDisconnectRoute
    extends RemitReceiverServerRoute {
  @override
  final String method = 'POST';

  @override
  final String path = '/connection/disconnect';

  @override
  shelf.Response onRequest(
    final RemitReceiverServerRouteContext context,
    final shelf.Request request,
  ) {
    if (!context.isAuthenticated(request)) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    context.receiver.onSenderDisconnected();
    return shelf.Response.ok(
      RemitDataBody.successful(),
      headers: RemitHttpHeaders.construct(),
    );
  }

  Future<void> makeRequest(final RemitSenderConnection connection) async {
    await makeRequestPartial(
      address: connection.receiverAddress,
      headers: RemitHttpHeaders.construct(
        contentType: null,
        additional: <String, String>{
          RemitHeaderKeys.identifier: connection.identifier,
        },
      ),
    );
  }

  static final RemitReceiverServerConnectionDisconnectRoute instance =
      RemitReceiverServerConnectionDisconnectRoute();
}
