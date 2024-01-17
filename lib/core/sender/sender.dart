import 'dart:async';
import 'package:remit/exports.dart';

class RemitSender {
  RemitSender._({
    required this.info,
    required this.server,
    required this.secure,
    required this.logger,
  }) : inviteCode = UUID.generateInviteCode();

  final RemitSenderBasicInfo info;
  final RemitServer server;
  final bool secure;
  final RemitLogger logger;
  String inviteCode;

  final Map<int, RemitSenderConnection> connections =
      <int, RemitSenderConnection>{};
  final Map<String, int> tokens = <String, int>{};
  final SequentialUUIDGenerator receiverIdGenerator = SequentialUUIDGenerator();

  bool active = false;
  Timer? heartbeatTimer;

  Future<void> initialize() async {
    for (final RemitSenderServerRoute route in routes) {
      route.use(this);
    }
    active = true;
    startHeartbeat();
    logger.info('RemitSender', 'ready');
  }

  Future<void> makeConnection(final RemitReceiverBasicInfo receiverInfo) async {
    // TODO: defer user confirmation
    final String receiverToken = UUID.generateToken();
    final RemitSenderConnection connection = RemitSenderConnection(
      receiver: receiverInfo,
      token: receiverToken,
      secure: secure,
      connectedAt: DateTime.now().millisecondsSinceEpoch,
    );
    logger.info(
      'RemitSender',
      'establishing connecting with uname:${receiverInfo.username} host:${receiverInfo.host} port:${receiverInfo.port}',
    );
    final bool accepted = await connection.connectionAccepted();
    if (!accepted) {
      logger.warn(
        'RemitSender',
        'connection rejected by uname:${receiverInfo.username}',
      );
      return;
    }
    final int receiverId = receiverIdGenerator.next();
    connections[receiverId] = connection;
    tokens[receiverToken] = receiverId;
    logger.info('RemitSender', 'connected with uname:${receiverInfo.username}');
  }

  Future<void> removeConnection(final int receiverId) async {
    final RemitSenderConnection? connection = connections.remove(receiverId);
    if (connection == null) return;
    logger.info(
      'RemitSender',
      'disconnecting from uname:${connection.receiver.username}',
    );
    tokens.remove(connection.token);
    await connection.disconnect();
    logger.info(
      'RemitSender',
      'disconnected from uname:${connection.receiver.username}',
    );
  }

  Future<SecureKey?> generateSecret(final int receiverId) async {
    final RemitSenderConnection? connection = connections[receiverId];
    if (connection == null) return null;
    if (connection.secretKey != null) {
      logger.warn(
        'RemitSender',
        'second read of secret attempted, disconnecting...',
      );
      removeConnection(receiverId);
      return null;
    }
    final SecureKey secureKey = SecureKey.generate32bits();
    connection.secretKey = secureKey;
    logger.info(
      'RemitSender',
      'secret set for uname:${connection.receiver.username}',
    );
    return secureKey;
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitHttpDefaults.heartbeatInterval, (final _) async {
      for (final MapEntry<int, RemitSenderConnection> x
          in connections.entries) {
        if (!active) return;
        final bool awake = await x.value.ping();
        if (!awake) {
          logger.warn(
            'RemitSender',
            'ping to uname:${x.value.receiver.username} failed, disconnecting...',
          );
          await removeConnection(x.key);
          return;
        }
        x.value.lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
        logger.info(
          'RemitSender',
          'ping to uname:${x.value.receiver.username} passed',
        );
      }
    });
  }

  Future<void> destroy() async {
    heartbeatTimer?.cancel();
    await server.destroy();
    for (final int receiverId in connections.keys) {
      removeConnection(receiverId);
    }
  }

  static final List<RemitSenderServerRoute> routes = <RemitSenderServerRoute>[
    RemitSenderServerPingRoute(),
    RemitSenderServerConnectionRequestRoute(),
    RemitSenderServerSecretRoute(),
  ];

  static Future<RemitSender> create({
    required final RemitSenderBasicInfo info,
    required final bool secure,
    required final RemitLogger logger,
  }) async {
    final RemitServer server = await RemitServer.createServer(
      host: info.host,
      port: info.port,
    );
    final RemitSender master = RemitSender._(
      info: info,
      server: server,
      secure: secure,
      logger: logger,
    );
    await master.initialize();
    return master;
  }
}
