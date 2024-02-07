import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerSecretRoute extends RemitSenderServerRoute {
  @override
  final String path = '/connection/secret';

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
    final int? receiverId = context.identifyConnectionId(request);
    if (receiverId == null) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final String body = await request.readAsString();
    final Map<dynamic, dynamic>? data = jsonDecodeMapOrNull(body);
    final (BigInt, BigInt)? publicKey = mapKeyFactoryOrNull(
      data,
      RemitDataKeys.publicKey,
      (final dynamic x) {
        final List<dynamic> values = x as List<dynamic>;
        return (
          BigInt.parse(values[0] as String),
          BigInt.parse(values[1] as String)
        );
      },
    );
    if (publicKey == null) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final Uint8List? secret = await context.sender.generateSecret(receiverId);
    if (secret == null) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final Uint8List encryptedSecret = RSA.encrypt(
      data: secret,
      publicKey: RSAPublicKey(publicKey.$1, publicKey.$2),
    );
    return shelf.Response.ok(
      RemitDataBody.successful(<dynamic, dynamic>{
        RemitDataKeys.secret: hex.encode(encryptedSecret),
      }),
      headers: RemitHttpHeaders.construct(),
    );
  }
}
