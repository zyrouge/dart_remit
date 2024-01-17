import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

// TODO: experimental
class RemitSenderServerSecretRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request req) async {
        if (!sender.secure) {
          return shelf.Response.forbidden(
            RemitJsonBody.construct(false),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final String? receiverToken = req.headers[RemitHeaderKeys.token];
        final int? receiverId = sender.tokens[receiverToken];
        if (receiverId == null) {
          return shelf.Response.unauthorized(
            RemitJsonBody.construct(false),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final String body = await req.readAsString();
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
            body: RemitJsonBody.construct(false),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final SecureKey? secret = await sender.generateSecret(receiverId);
        if (secret == null) {
          return shelf.Response.badRequest(
            body: RemitJsonBody.construct(false),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final Uint8List encryptedSecret = RSA.encrypt(
          data: secret.bytes,
          publicKey: RSAPublicKey(publicKey.$1, publicKey.$2),
        );
        return shelf.Response.ok(
          RemitJsonBody.construct(true, <dynamic, dynamic>{
            RemitDataKeys.secret: hex.encode(encryptedSecret),
          }),
          headers: RemitHttpHeaders.construct(),
        );
      },
    );
  }

  static const String path = '/connection/secret';
}
