import 'dart:async';
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
    logger.info('RemitReceiver', 'ready');
  }

  void onConnectionAccepted({
    required final String identifier,
    required final String token,
  }) {
    connection.identifier = identifier;
    connection.token = token;
    active = true;
    startHeartbeat();
    logger.info('RemitReceiver', 'connected to sender');
  }

  void onSenderDisconnected() {
    destroy();
    logger.info('RemitReceiver', 'sender disconnected');
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitHttpDefaults.heartbeatInterval, (final _) async {
      if (!active) return;
      final bool awake = await connection.ping();
      if (!awake) {
        logger.info('RemitReceiver', 'ping to sender fail');
        await destroy();
        return;
      }
      connection.lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
      logger.info('RemitReceiver', 'ping to sender passed');
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
  ];

  // TODO: redo this
  static Future<RemitReceiver> create({
    required final RemitReceiverBasicInfo info,
    required final RemitSenderBasicInfo sender,
    required final RemitLogger logger,
  }) async {
    final RemitServer server = await RemitServer.createServer(
      host: info.host,
      port: info.port,
    );
    final int connectedAt = DateTime.now().millisecondsSinceEpoch;
    final RemitReceiverConnection connection = RemitReceiverConnection(
      sender: sender,
      connectedAt: connectedAt,
    );
    final RemitReceiver receiver = RemitReceiver._(
      info: info,
      server: server,
      connection: connection,
      logger: logger,
    );
    await receiver.initialize();
    final bool requested = await connection.connectionRequest();
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
