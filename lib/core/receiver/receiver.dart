import 'dart:async';
import 'dart:typed_data';
import 'package:remit/exports.dart';

typedef RemitReceiverOnFilesystemUpdated = void Function(
  RemitEventFilesystemUpdatedPairs pairs,
);

class RemitReceiver {
  RemitReceiver._({
    required this.info,
    required this.server,
    required this.connection,
    required this.logger,
    required this.onFilesystemUpdated,
  });

  final RemitReceiverBasicInfo info;
  final RemitServer<RemitReceiverServerRouteContext> server;
  final RemitReceiverConnection connection;
  final RemitLogger logger;
  final RemitEventer<String> events = RemitEventer<String>();
  final RemitReceiverOnFilesystemUpdated onFilesystemUpdated;

  bool active = false;
  Timer? heartbeatTimer;
  final Completer<void> _connectionCompleter = Completer<void>();

  Future<void> initialize() async {
    server.routeContext = RemitReceiverServerRouteContext(this);
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
      final RSAKeyPair keyPair = RSA.generateKeyPair(createFortunaRandom());
      try {
        final Uint8List secretKey = await connection.fetchSecret(keyPair);
        connection.secret = secretKey;
        logger.info('RemitReceiver', 'fetched secret key');
      } catch (error) {
        logger.error(
          'RemitReceiver',
          'fetching secret failed, destroying...',
          error,
        );
        _connectionCompleter
            .completeError(RemitException.cannotFetchSecretKey());
        destroy();
        rethrow;
      }
    }
    active = true;
    _connectionCompleter.complete();
    startHeartbeat();
    logger.info('RemitReceiver', 'connected to ${connection.debugUsername}');
  }

  void onSenderDisconnected() {
    destroy();
    logger.info('RemitReceiver', '${connection.debugUsername} disconnected');
  }

  dynamic maybeEncryptJson({
    required final RemitSenderConnection connection,
    required final Map<dynamic, dynamic> data,
  }) {
    if (connection.secure) {
      if (connection.secret == null) {
        throw RemitException.missingSecretKey();
      }
      return RemitDataEncrypter.encryptJson(
        data: data,
        key: connection.secret!,
      );
    }
    return data;
  }

  Map<dynamic, dynamic>? maybeDecryptJsonOrNull({
    required final RemitSenderConnection connection,
    required final dynamic data,
  }) {
    if (connection.secure) {
      if (data is! String) return null;
      return RemitDataEncrypter.decryptJson(
        data: data,
        key: connection.secret!,
      );
    }
    if (data is! Map<dynamic, dynamic>) return null;
    return data;
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitHttpDefaults.heartbeatInterval, (final _) async {
      if (!active) {
        return;
      }
      bool awake = false;
      try {
        awake = await connection.ping();
      } catch (err) {
        logger.error(
          'RemitSender',
          'ping request to ${connection.debugUsername} failed',
          err,
        );
      }
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
    try {
      await connection.disconnect();
    } catch (_) {}
    await server.destroy();
    logger.info('RemitReceiver', 'destroyed');
  }

  Future<void> get connectionFuture => _connectionCompleter.future;

  static final List<RemitReceiverServerRoute> routes =
      <RemitReceiverServerRoute>[
    RemitReceiverServerConnectionAcceptedRoute.instance,
    RemitReceiverServerConnectionDisconnectRoute.instance,
    RemitReceiverServerEventFilesystemUpdatedRoute.instance,
    RemitReceiverServerPingRoute.instance,
  ];

  static Future<RemitReceiver> create({
    required final RemitReceiverBasicInfo info,
    required final RemitConnectionAddress address,
    required final RemitConnectionAddress senderAddress,
    required final String inviteCode,
    required final RemitLogger logger,
    required final RemitReceiverOnFilesystemUpdated onFilesystemUpdated,
  }) async {
    final RemitSenderBasicInfo senderInfo =
        await RemitReceiverConnection.fetchSenderInfo(senderAddress);
    final RemitServer<RemitReceiverServerRouteContext> server =
        await RemitServer.createServer(address, routes);
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
      onFilesystemUpdated: onFilesystemUpdated,
    );
    await receiver.initialize();
    final bool requested = await connection.connectionRequest(inviteCode);
    if (!requested) {
      await receiver.destroy();
      throw RemitException.connectionRejected();
    }
    await receiver.connectionFuture;
    return receiver;
  }
}
