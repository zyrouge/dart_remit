import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerConnectionRequestRoute extends RemitSenderServerRoute {
  @override
  final String method = 'POST';

  @override
  final String path = '/connection/request';

  @override
  Future<shelf.Response> onRequest(
    final RemitSenderServerRouteContext context,
    final shelf.Request request,
  ) async {
    final String body = await request.readAsString();
    final Map<dynamic, dynamic>? data = jsonDecodeMapOrNull(body);
    final RemitReceiverBasicInfo? receiverInfo = mapKeyFactoryOrNull(
      data,
      RemitDataKeys.info,
      RemitReceiverBasicInfo.fromJson,
    );
    final RemitConnectionAddress? receiverAddress = mapKeyFactoryOrNull(
      data,
      RemitDataKeys.connectionAddress,
      RemitConnectionAddress.fromJson,
    );
    final String? inviteCode = mapKeyOrNull(data, RemitDataKeys.inviteCode);
    if (receiverInfo == null || receiverAddress == null || inviteCode == null) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    if (inviteCode != context.sender.inviteCode) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    context.sender.makeConnection(
      receiverInfo: receiverInfo,
      receiverAddress: receiverAddress,
    );
    return shelf.Response.ok(
      RemitDataBody.failure(),
      headers: RemitHttpHeaders.construct(),
    );
  }

  Future<bool> makeRequest(
    final RemitReceiverConnection connection, {
    required final String inviteCode,
  }) async {
    final http.Response resp = await makeRequestPartial(
      address: connection.senderAddress,
      headers: RemitHttpHeaders.construct(),
      body: jsonEncode(<dynamic, dynamic>{
        RemitDataKeys.info: connection.info.toJson(),
        RemitDataKeys.connectionAddress: connection.address.toJson(),
        RemitDataKeys.inviteCode: inviteCode,
      }),
    );
    return resp.statusCode == HttpStatus.ok;
  }

  static final RemitSenderServerConnectionRequestRoute instance =
      RemitSenderServerConnectionRequestRoute();
}
