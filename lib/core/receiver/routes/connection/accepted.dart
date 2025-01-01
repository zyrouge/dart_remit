import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerConnectionAcceptedRoute
    extends RemitReceiverServerRoute {
  @override
  final String method = 'POST';

  @override
  final String path = '/connection/accepted';

  @override
  Future<shelf.Response> onRequest(
    final RemitReceiverServerRouteContext context,
    final shelf.Request request,
  ) async {
    final String body = await request.readAsString();
    final Map<dynamic, dynamic>? data = jsonDecodeMapOrNull(body);
    final String? identifier = mapKeyOrNull(data, RemitDataKeys.identifier);
    final String? token = mapKeyOrNull(data, RemitDataKeys.token);
    final bool? secure = mapKeyOrNull(data, RemitDataKeys.secure);
    if (data == null || identifier == null || token == null || secure == null) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    context.receiver.onConnectionAccepted(
      identifier: identifier,
      token: token,
      secure: secure,
    );
    return shelf.Response.ok(
      RemitDataBody.successful(),
      headers: RemitHttpHeaders.construct(),
    );
  }

  Future<bool> makeRequest(final RemitSenderConnection connection) async {
    final http.Response resp = await makeRequestPartial(
      address: connection.receiverAddress,
      headers: RemitHttpHeaders.construct(),
      body: jsonEncode(<dynamic, dynamic>{
        RemitDataKeys.identifier: connection.identifier,
        RemitDataKeys.token: connection.token,
        RemitDataKeys.secure: connection.secure,
      }),
    );
    return resp.statusCode == HttpStatus.ok;
  }

  static final RemitReceiverServerConnectionAcceptedRoute instance =
      RemitReceiverServerConnectionAcceptedRoute();
}
