import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerPingRoute extends RemitSenderServerRoute {
  @override
  final String path = '/ping';

  @override
  shelf.Response onRequest(
    final RemitSenderServerRouteContext context,
    final shelf.Request request,
  ) {
    if (!context.isAuthenticated(request)) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    return shelf.Response.ok(
      RemitDataBody.successful(),
      headers: RemitHttpHeaders.construct(),
    );
  }

  Future<bool> makeRequest(final RemitSenderConnection connection) async {
    final http.Response resp = await makeRequestPartial(
      address: connection.receiverAddress,
      headers: RemitHttpHeaders.construct(
        contentType: null,
        additional: <String, String>{
          RemitHeaderKeys.identifier: connection.identifier,
        },
      ),
    );
    return resp.statusCode == 200;
  }

  static final RemitSenderServerPingRoute instance =
      RemitSenderServerPingRoute();
}
