import 'dart:io';
import 'package:remit/exports.dart';

const RemitLogger logger = RemitConsoleLogger();

Future<void> main() async {
  final List<InternetAddress> addresses =
      await RemitServer.getAvailableNetworks();
  final String host = addresses.first.address;
  final RemitSender sender = await RemitSender.create(
    info: const RemitSenderBasicInfo(
      username: 'remit-demo-sender',
      device: null,
    ),
    address: RemitConnectionAddress(host, 0),
    secure: true,
    logger: logger,
  );
  final RemitReceiver receiver = await RemitReceiver.create(
    info: const RemitReceiverBasicInfo(
      username: 'remit-demo-sender',
      device: null,
    ),
    address: RemitConnectionAddress(host, 0),
    senderAddress: RemitConnectionAddress(
      sender.server.host,
      sender.server.port,
    ),
    inviteCode: sender.inviteCode,
    logger: logger,
  );
}
