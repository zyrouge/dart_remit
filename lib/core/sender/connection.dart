import 'dart:typed_data';
import 'package:remit/core/receiver/routes/events/exports.dart';
import 'package:remit/exports.dart';

class RemitSenderConnection with RemitOptionalDataEncrypter {
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

  @override
  Uint8List? secret;

  Future<bool> ping() =>
      RemitReceiverServerPingRoute.instance.makeRequest(this);

  Future<bool> connectionAccepted() =>
      RemitReceiverServerConnectionAcceptedRoute.instance.makeRequest(this);

  Future<void> disconnect() =>
      RemitReceiverServerConnectionDisconnectRoute.instance.makeRequest(this);

  Future<void> onFileSystemUpdated(
    final List<RemitEventFilesystemUpdatedPairs> pairs,
  ) =>
      RemitReceiverServerEventFilesystemUpdatedRoute.instance
          .makeRequest(this, pairs: pairs);

  String get debugUsername =>
      'u/sndr/${receiverInfo.username}/$receiverAddress';

  @override
  bool get requiresEncryption => secure;
}
