import 'dart:async';
import 'dart:typed_data';
import 'package:remit/exports.dart';

typedef RemitSenderOnConnectionRequest = FutureOr<bool> Function({
  required RemitReceiverBasicInfo receiverInfo,
  required RemitConnectionAddress receiverAddress,
});

typedef RemitSenderUpdateFilesystem = FutureOr<RemitEventFilesystemUpdatedPairs>
    Function(RemitVirtualFolder root);

class RemitSender {
  RemitSender._({
    required this.info,
    required this.server,
    required this.secure,
    required this.logger,
    required this.onConnectionRequest,
  }) : inviteCode = UUID.generateInviteCode();

  final RemitSenderBasicInfo info;
  final RemitServer<RemitServerRouteContext> server;
  final bool secure;
  final RemitLogger logger;
  final RemitSenderOnConnectionRequest onConnectionRequest;
  String inviteCode;

  final Map<int, RemitSenderConnection> connections =
      <int, RemitSenderConnection>{};
  final Map<String, int> tokens = <String, int>{};
  final SequentialUUIDGenerator receiverIdGenerator = SequentialUUIDGenerator();
  final RemitVirtualFolder filesystem = RemitVirtualFolder(
    basename: filesystemRootBasename,
    entities: <String, RemitFile>{},
  );

  bool active = false;
  Timer? heartbeatTimer;

  Future<void> initialize() async {
    server.routeContext = RemitSenderServerRouteContext(this);
    active = true;
    startHeartbeat();
    logger.info('RemitSender', 'ready (server at ${server.address})');
  }

  Future<void> makeConnection({
    required final RemitReceiverBasicInfo receiverInfo,
    required final RemitConnectionAddress receiverAddress,
  }) async {
    final bool acceptConnection = await onConnectionRequest(
      receiverInfo: receiverInfo,
      receiverAddress: receiverAddress,
    );
    if (!acceptConnection) {
      return;
    }
    final String receiverToken = UUID.generateToken();
    final RemitSenderConnection connection = RemitSenderConnection(
      receiverInfo: receiverInfo,
      receiverAddress: receiverAddress,
      token: receiverToken,
      secure: secure,
      connectedAt: DateTime.now().millisecondsSinceEpoch,
    );
    logger.info(
      'RemitSender',
      'establishing connection with ${connection.debugUsername}',
    );
    final bool accepted = await connection.connectionAccepted();
    if (!accepted) {
      logger.warn(
        'RemitSender',
        'connection rejected by ${connection.debugUsername}',
      );
      return;
    }
    final int receiverId = receiverIdGenerator.next();
    connections[receiverId] = connection;
    tokens[receiverToken] = receiverId;
    logger.info('RemitSender', 'connected with ${connection.debugUsername}');
  }

  Future<void> removeConnection(final int receiverId) async {
    final RemitSenderConnection? connection = connections.remove(receiverId);
    if (connection == null) {
      return;
    }
    logger.info(
      'RemitSender',
      'disconnecting from ${connection.debugUsername}',
    );
    tokens.remove(connection.token);
    try {
      await connection.disconnect();
    } catch (_) {}
    logger.info('RemitSender', 'disconnected from ${connection.debugUsername}');
  }

  Future<Uint8List?> generateSecret(final int receiverId) async {
    final RemitSenderConnection? connection = connections[receiverId];
    if (connection == null) return null;
    if (connection.secret != null) {
      logger.warn(
        'RemitSender',
        'second read of secret attempted, disconnecting...',
      );
      removeConnection(receiverId);
      return null;
    }
    final Uint8List secretKey = SecureKey.generate32bytes();
    connection.secret = secretKey;
    logger.info('RemitSender', 'secret set for ${connection.debugUsername}');
    return secretKey;
  }

  Future<void> updateFilesystem(
    final RemitSenderUpdateFilesystem updater,
  ) async {
    final RemitEventFilesystemUpdatedPairs pairs = await updater(filesystem);
    for (final RemitSenderConnection x in connections.values) {
      try {
        await x.onFileSystemUpdated(pairs);
      } catch (err) {
        logger.error(
          'RemitSender',
          'event updated filesystem request to ${x.debugUsername} failed',
          err,
        );
      }
    }
    logger.info('RemitReceiver', 'updated filesystem');
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitHttpDefaults.heartbeatInterval, (final _) async {
      for (final MapEntry<int, RemitSenderConnection> x
          in connections.entries) {
        if (!active) {
          return;
        }
        bool awake = false;
        try {
          awake = await x.value.ping();
        } catch (err) {
          logger.error(
            'RemitSender',
            'ping request to ${x.value.debugUsername} failed',
            err,
          );
        }
        if (!awake) {
          logger.warn(
            'RemitSender',
            'ping to ${x.value.debugUsername} failed, disconnecting...',
          );
          await removeConnection(x.key);
          return;
        }
        x.value.lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
        logger.info(
          'RemitSender',
          'ping to ${x.value.debugUsername} passed',
        );
      }
    });
  }

  Future<void> destroy() async {
    heartbeatTimer?.cancel();
    await server.destroy();
    for (final int receiverId in connections.keys.toList()) {
      removeConnection(receiverId);
    }
  }

  static const String filesystemRootBasename = 'root';

  static final List<RemitSenderServerRoute> routes = <RemitSenderServerRoute>[
    RemitSenderServerConnectionRequestRoute.instance,
    RemitSenderServerConnectionSecretRoute.instance,
    RemitSenderServerConnectionDisconnectRoute.instance,
    RemitSenderServerFilesystemListRoute.instance,
    RemitSenderServerFilesystemReadRoute.instance,
    RemitSenderServerInfoRoute.instance,
    RemitSenderServerPingRoute.instance,
  ];

  static Future<RemitSender> create({
    required final RemitSenderBasicInfo info,
    required final RemitConnectionAddress address,
    required final bool secure,
    required final RemitLogger logger,
    required final RemitSenderOnConnectionRequest onConnectionRequest,
  }) async {
    final RemitServer<RemitSenderServerRouteContext> server =
        await RemitServer.createServer(address, routes);
    final RemitSender master = RemitSender._(
      info: info,
      server: server,
      secure: secure,
      logger: logger,
      onConnectionRequest: onConnectionRequest,
    );
    await master.initialize();
    return master;
  }
}
