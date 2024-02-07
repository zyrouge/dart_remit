import 'dart:typed_data';
import 'package:remit/exports.dart';

class RemitReceiverConnection with RemitOptionalDataEncrypter {
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

  @override
  Uint8List? secret;

  Future<bool> ping() => RemitSenderServerPingRoute.instance.makeRequest(this);

  Future<bool> connectionRequest(final String inviteCode) =>
      RemitSenderServerConnectionRequestRoute.instance
          .makeRequest(this, inviteCode: inviteCode);

  Future<Uint8List> fetchSecret(final RSAPublicKey publicKey) =>
      RemitSenderServerConnectionSecretRoute.instance
          .makeRequest(this, publicKey: publicKey);

  Future<void> disconnect() =>
      RemitSenderServerConnectionDisconnectRoute.instance.makeRequest(this);

  String get debugUsername => 'u/rcvr/${senderInfo.username}/$senderAddress';

  @override
  bool get requiresEncryption => secure ?? false;

  static Future<RemitSenderBasicInfo> fetchSenderInfo(
    final RemitConnectionAddress address,
  ) =>
      RemitSenderServerInfoRoute.instance.makeRequest(address);
}
