import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';

class RemitSenderConnection {
  RemitSenderConnection({
    required this.receiverInfo,
    required this.receiverAddress,
    required this.token,
    required this.connectedAt,
    required this.secure,
  })  : identifier = UUID.generateIdentifier(),
        lastHeartbeatAt = connectedAt;

  final RemitReceiverBasicInfo receiverInfo;
  final RemitConnectionAddress receiverAddress;
  final String token;
  final bool secure;

  final int connectedAt;
  final String identifier;
  int lastHeartbeatAt;
  Uint8List? secretKey;

  Future<bool> ping() => RemitSenderServerPingRoute.instance.makeRequest(this);

  Future<bool> connectionAccepted() async {
    try {
      final http.Response resp = await http
          .post(
            buildReceiverUri(RemitReceiverServerConnectionAcceptedRoute.path),
            headers: RemitHttpHeaders.construct(),
            body: jsonEncode(<dynamic, dynamic>{
              RemitDataKeys.identifier: identifier,
              RemitDataKeys.token: token,
              RemitDataKeys.secure: secure,
            }),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  Future<void> disconnect() async {
    try {
      await http
          .post(
            buildReceiverUri('/disconnect'),
            headers: RemitHttpHeaders.construct(contentType: null),
          )
          .timeout(RemitHttpDefaults.requestTimeout);
    } catch (_) {}
  }

  Uri buildReceiverUri(final String path) =>
      receiverAddress.appendPathUri(path);

  String get debugUsername =>
      'u/sndr/${receiverInfo.username}/$receiverAddress';
}
