import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerConnectionRequestRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(path, (final shelf.Request req) async {
      final String body = await req.readAsString();
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
      if (receiverInfo == null ||
          receiverAddress == null ||
          inviteCode == null) {
        return shelf.Response.badRequest(
          body: RemitJsonBody.fail(),
          headers: RemitHttpHeaders.construct(),
        );
      }
      if (inviteCode != sender.inviteCode) {
        return shelf.Response.unauthorized(
          RemitJsonBody.fail(),
          headers: RemitHttpHeaders.construct(),
        );
      }
      sender.makeConnection(
        receiverInfo: receiverInfo,
        receiverAddress: receiverAddress,
      );
      return shelf.Response.ok(
        RemitJsonBody.fail(),
        headers: RemitHttpHeaders.construct(),
      );
    });
  }

  static const String path = '/connection/request';
}
