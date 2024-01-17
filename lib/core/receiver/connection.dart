import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:remit/core/errors/exception.dart';
import 'package:remit/exports.dart';

class RemitReceiverConnection {
  RemitReceiverConnection({
    required this.sender,
    required this.info,
    required this.connectedAt,
  }) : lastHeartbeatAt = connectedAt;

  final RemitSenderBasicInfo sender;
  final RemitReceiverBasicInfo info;
  final int connectedAt;

  int lastHeartbeatAt;
  String? identifier;
  String? token;
  bool? secure;
  Uint8List? secret;

  Future<bool> ping() async {
    if (token == null) return false;
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitSenderServerPingRoute.path),
            headers: RemitHttpHeaders.construct(
              contentType: null,
              additional: <String, String>{
                RemitHeaderKeys.token: token ?? '',
              },
            ),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<bool> connectionRequest(final String inviteCode) async {
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitSenderServerConnectionRequestRoute.path),
            headers: RemitHttpHeaders.construct(),
            body: jsonEncode(<dynamic, dynamic>{
              RemitDataKeys.info: info.toJson(),
              RemitDataKeys.inviteCode: inviteCode,
            }),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<Uint8List> fetchSecret(final RSAPublicKey publicKey) async {
    try {
      final http.Response resp = await http
          .post(
            constructSenderUri(RemitSenderServerSecretRoute.path),
            headers: RemitHttpHeaders.construct(
              additional: <String, String>{
                RemitHeaderKeys.token: token ?? '',
              },
            ),
            body: jsonEncode(<dynamic, dynamic>{
              RemitDataKeys.publicKey: <dynamic>[
                publicKey.modulus.toString(),
                publicKey.exponent.toString(),
              ],
            }),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      if (resp.statusCode != 200) {
        throw RemitException(
          'Fetching secret returned ${resp.statusCode} status code',
          code: RemitErrorCodes.unexpectedResponse,
        );
      }
      final RemitJsonBodyData? data = RemitJsonBody.deconstruct(resp.body);
      if (data == null || !data.success) {
        throw RemitException(
          'Received non-success response',
          code: RemitErrorCodes.unexpectedResponse,
        );
      }
      final List<int>? encryptedSecretBytes = mapKeyFactoryOrNull(
        data.data,
        RemitDataKeys.secret,
        (final dynamic encoded) => hex.decode(encoded as String),
      );
      if (encryptedSecretBytes == null) {
        throw RemitException(
          'Invalid secret received',
          code: RemitErrorCodes.invalidData,
        );
      }
      return Uint8List.fromList(encryptedSecretBytes);
    } catch (error) {
      throw RemitException(
        error.toString(),
        code: RemitErrorCodes.unexpectedError,
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await http
          .post(
            constructSenderUri('/disconnect'),
            headers: RemitHttpHeaders.construct(
              contentType: null,
              additional: <String, String>{
                RemitHeaderKeys.token: token ?? '',
              },
            ),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
    } catch (_) {}
  }

  Uri constructSenderUri(final String path) => Uri(
        scheme: 'http',
        host: sender.host,
        port: sender.port,
        path: path,
      );
}
