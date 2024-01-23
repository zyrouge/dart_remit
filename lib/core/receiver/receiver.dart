import 'dart:async';
import 'dart:typed_data';
import 'package:remit/core/errors/exception.dart';
import 'package:remit/exports.dart';

class RemitReceiver {
  RemitReceiver._({
    required this.info,
    required this.server,
    required this.connection,
    required this.logger,
  });

  final RemitReceiverBasicInfo info;
  final RemitServer server;
  final RemitReceiverConnection connection;
  final RemitLogger logger;
  final RemitEventer<String> events = RemitEventer<String>();

  bool active = false;
  Timer? heartbeatTimer;

  Future<void> initialize() async {
    for (final RemitReceiverServerRoute route in routes) {
      route.use(this);
    }
    logger.info('RemitReceiver', 'ready (server at ${server.address})');
  }

  Future<void> onConnectionAccepted({
    required final String identifier,
    required final String token,
    required final bool secure,
  }) async {
    connection.identifier = identifier;
    connection.token = token;
    connection.secure = secure;
    if (secure) {
      logger.info('RemitReceiver', 'fetching secret key');
      final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          RSA.generateKeyPair(createFortunaRandom());
      try {
        final Uint8List secret =
            await connection.fetchSecret(keyPair.publicKey);
        connection.secret = secret;
        logger.info('RemitReceiver', 'fetched secret key');
      } catch (error) {
        logger.error(
          'RemitReceiver',
          'fetching secret failed, destroying (err: $error)',
        );
        destroy();
        rethrow;
      }
    }
    active = true;
    startHeartbeat();
    logger.info('RemitReceiver', 'connected to ${connection.debugUsername}');
  }

  void onSenderDisconnected() {
    destroy();
    logger.info('RemitReceiver', '${connection.debugUsername} disconnected');
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitHttpDefaults.heartbeatInterval, (final _) async {
      if (!active) return;
      final bool awake = await connection.ping();
      if (!awake) {
        logger.warn(
          'RemitReceiver',
          'ping to ${connection.debugUsername} failed, disconnecting...',
        );
        await destroy();
        return;
      }
      connection.lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
      logger.info(
        'RemitReceiver',
        'ping to ${connection.debugUsername} passed',
      );
    });
  }

  Future<void> destroy() async {
    active = false;
    connection.identifier = null;
    connection.token = null;
    heartbeatTimer?.cancel();
    await connection.disconnect();
    await server.destroy();
    logger.info('RemitReceiver', 'destroyed');
  }

  static final List<RemitReceiverServerRoute> routes =
      <RemitReceiverServerRoute>[
    RemitReceiverServerPingRoute(),
    RemitReceiverServerConnectionAcceptedRoute(),
  ];

  static Future<RemitReceiver> create({
    required final RemitReceiverBasicInfo info,
    required final RemitConnectionAddress address,
    required final RemitConnectionAddress senderAddress,
    required final String inviteCode,
    required final RemitLogger logger,
  }) async {
    final RemitSenderBasicInfo senderInfo =
        await RemitReceiverConnection.fetchSenderInfo(senderAddress);
    final RemitServer server = await RemitServer.createServer(address);
    final int connectedAt = DateTime.now().millisecondsSinceEpoch;
    final RemitReceiverConnection connection = RemitReceiverConnection(
      info: info,
      address: server.address,
      senderInfo: senderInfo,
      senderAddress: senderAddress,
      connectedAt: connectedAt,
    );
    final RemitReceiver receiver = RemitReceiver._(
      info: info,
      server: server,
      connection: connection,
      logger: logger,
    );
    await receiver.initialize();
    final bool requested = await connection.connectionRequest(inviteCode);
    if (!requested) {
      await receiver.destroy();
      throw RemitException(
        'Connection request rejected',
        code: RemitErrorCodes.connectionReject,
      );
    }
    return receiver;
  }
}
