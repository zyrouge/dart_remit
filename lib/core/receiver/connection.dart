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

  Future<Uint8List> fetchSecret(final RSAKeyPair keyPair) =>
      RemitSenderServerConnectionSecretRoute.instance
          .makeRequest(this, keyPair: keyPair);

  Future<RemitFilesystemStaticDataPairs> filesystemList(final String path) =>
      RemitSenderServerFilesystemListRoute.instance
          .makeRequest(this, path: path);

  Future<Stream<List<int>>> filesystemRead(
    final String path, {
    final int? start,
    final int? end,
  }) =>
      RemitSenderServerFilesystemReadRoute.instance
          .makeRequest(this, path: path, rangeStart: start, rangeEnd: end);

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
