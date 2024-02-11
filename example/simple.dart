import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  const String testFileContent = 'Hello World!';
  final RemitVirtualFile testFile = RemitVirtualFile(
    basename: 'test.txt',
    content: utf8.encode(testFileContent),
  );
  sender.filesystem.addEntity(testFile);
  final RemitSenderServerFilesystemListData files =
      await receiver.connection.filesystemList('');
  assert(files.folders.isEmpty);
  assert(files.files.length == 1);
  assert(files.files.first == testFile.basename);
  final Stream<List<int>> nTestFileDataStream =
      await receiver.connection.filesystemRead(testFile.basename);
  final BytesBuilder nTestFileData = await nTestFileDataStream.fold(
    BytesBuilder(),
    (final BytesBuilder pv, final List<int> cv) => pv..add(cv),
  );
  final String nTestFileContent = utf8.decode(nTestFileData.toBytes());
  print('Expected test file data: $testFileContent');
  print('Expected test file data: $nTestFileContent');
  assert(testFileContent == nTestFileContent);
  await sender.destroy();
  await receiver.destroy();
}
