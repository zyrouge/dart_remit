import 'dart:convert';
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
    onConnectionRequest: ({
      required final RemitConnectionAddress receiverAddress,
      required final RemitReceiverBasicInfo receiverInfo,
    }) =>
        true,
  );
  logger.info('SenderExample', 'invite code: ${sender.inviteCode}');
  const String testFileContent = 'Hello World!';
  final RemitVirtualFile testFile = RemitVirtualFile(
    basename: 'test.txt',
    content: utf8.encode(testFileContent),
  );
  sender.filesystem.addEntity(testFile);
}
