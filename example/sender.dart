import 'package:remit/exports.dart';

const RemitLogger logger = RemitConsoleLogger();

Future<void> main() async {
  final RemitSender sender = await RemitSender.create(
    info: const RemitSenderBasicInfo(
      username: 'remit-demo-sender',
      host: 'localhost',
      port: RemitHttpDefaults.universalPort,
    ),
    secure: true,
    logger: logger,
  );
  final RemitReceiver receiver = await RemitReceiver.create(
    info: const RemitReceiverBasicInfo(
      username: 'remit-demo-sender',
      host: 'localhost',
      port: RemitHttpDefaults.universalPort + 1,
    ),
    sender: sender.info,
    inviteCode: sender.inviteCode,
    logger: logger,
  );
}
