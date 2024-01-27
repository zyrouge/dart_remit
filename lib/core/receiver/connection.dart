import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';

class RemitReceiverConnection {
  RemitReceiverConnection({
    required this.info,
    required this.address,
    required this.senderInfo,
    required this.senderAddress,
    required this.connectedAt,
  }) : lastHeartbeatAt = connectedAt;

  final RemitReceiverBasicInfo info;
  final RemitConnectionAddress address;
  final RemitSenderBasicInfo senderInfo;
  final RemitConnectionAddress senderAddress;
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
            buildSenderUri(RemitSenderServerPingRoute.path),
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
            buildSenderUri(RemitSenderServerConnectionRequestRoute.path),
            headers: RemitHttpHeaders.construct(),
            body: jsonEncode(<dynamic, dynamic>{
              RemitDataKeys.info: info.toJson(),
              RemitDataKeys.connectionAddress: address.toJson(),
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
            buildSenderUri(RemitSenderServerSecretRoute.path),
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
          code: RemitErrorCode.unexpectedResponse,
        );
      }
      final RemitJsonDataBody? data = RemitDataBody.deconstruct(resp.body);
      if (data == null || !data.success) {
        throw RemitException(
          'Received non-success response',
          code: RemitErrorCode.unexpectedResponse,
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
          code: RemitErrorCode.invalidData,
        );
      }
      return Uint8List.fromList(encryptedSecretBytes);
    } catch (error) {
      throw RemitException(
        error.toString(),
        code: RemitErrorCode.unexpectedError,
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await http
          .post(
            buildSenderUri('/disconnect'),
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

  Uri buildSenderUri(final String path) => senderAddress.appendPathUri(path);

  String get debugUsername => 'u/rcvr/${senderInfo.username}/$senderAddress';

  static Future<RemitSenderBasicInfo> fetchSenderInfo(
    final RemitConnectionAddress address,
  ) async {
    final http.Response resp = await http
        .post(
          address.appendPathUri(RemitSenderServerInfoRoute.path),
          headers: RemitHttpHeaders.construct(contentType: null),
        )
        .timeout(RemitHttpDefaults.requestTimeout);
    if (resp.statusCode != 200) {
      throw RemitException(
        'Fetching sender info returned ${resp.statusCode} status code',
        code: RemitErrorCode.unexpectedResponse,
      );
    }
    final RemitJsonDataBody? data = RemitDataBody.deconstruct(resp.body);
    if (data == null || !data.success) {
      throw RemitException(
        'Received non-success response',
        code: RemitErrorCode.unexpectedResponse,
      );
    }
    final RemitSenderBasicInfo? info = jsonFactoryOrNull(
      data.data,
      RemitSenderBasicInfo.fromJson,
    );
    if (info == null) {
      throw RemitException(
        'Received invalid data',
        code: RemitErrorCode.invalidData,
      );
    }
    return info;
  }
}
