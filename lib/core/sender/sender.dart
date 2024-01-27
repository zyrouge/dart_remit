import 'dart:async';
import 'dart:typed_data';
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
  final RemitVirtualFolder filesystem = RemitVirtualFolder(
    basename: '/',
    entities: <String, RemitFile>{},
  );

  bool active = false;
  Timer? heartbeatTimer;

  Future<void> initialize() async {
    for (final RemitSenderServerRoute route in routes) {
      route.use(this);
    }
    active = true;
    startHeartbeat();
    logger.info('RemitSender', 'ready (server at ${server.address})');
  }

  Future<void> makeConnection({
    required final RemitReceiverBasicInfo receiverInfo,
    required final RemitConnectionAddress receiverAddress,
  }) async {
    // TODO: defer user confirmation
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
    if (connection == null) return;
    logger.info(
      'RemitSender',
      'disconnecting from ${connection.debugUsername}',
    );
    tokens.remove(connection.token);
    await connection.disconnect();
    logger.info('RemitSender', 'disconnected from ${connection.debugUsername}');
  }

  Future<Uint8List?> generateSecret(final int receiverId) async {
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
    final Uint8List secureKey = SecureKey.generate32bits();
    connection.secretKey = secureKey;
    logger.info('RemitSender', 'secret set for ${connection.debugUsername}');
    return secureKey;
  }

  void updateFilesystem(final void Function(RemitVirtualFolder root) updater) {
    // TODO: emit fs update event
    updater(filesystem);
    logger.info('RemitReceiver', 'updated filesystem');
  }

  dynamic maybeEncryptJson({
    required final RemitSenderConnection connection,
    required final Map<dynamic, dynamic> data,
  }) {
    if (secure) {
      final Uint8List? key = connection.secretKey;
      if (key == null) {
        throw RemitException(
          'Cannot encrypt without secret key',
          code: RemitErrorCodes.invalidState,
        );
      }
      return RemitDataEncrypter.encryptJson(data: data, key: key);
    }
    return data;
  }

  Map<dynamic, dynamic>? maybeDecryptJsonOrNull({
    required final RemitSenderConnection connection,
    required final dynamic data,
  }) {
    if (secure) {
      final Uint8List? key = connection.secretKey;
      if (key == null) {
        throw RemitException(
          'Cannot encrypt without secret key',
          code: RemitErrorCodes.invalidState,
        );
      }
      if (data is! String) return null;
      return RemitDataEncrypter.decryptJson(data: data, key: key);
    }
    if (data is! Map<dynamic, dynamic>) return null;
    return data;
  }

  Stream<List<int>> maybeEncryptStream({
    required final RemitSenderConnection connection,
    required final Stream<List<int>> stream,
  }) {
    if (secure) {
      final Uint8List? key = connection.secretKey;
      if (key == null) {
        throw RemitException(
          'Cannot encrypt without secret key',
          code: RemitErrorCodes.invalidState,
        );
      }
      return stream.map(
        (final List<int> x) => RemitDataEncrypter.encryptBytes(
          data: Uint8List.fromList(x),
          key: key,
        ),
      );
    }
    return stream;
  }

  Stream<List<int>> maybeDecryptStreamOrNull({
    required final RemitSenderConnection connection,
    required final Stream<List<int>> stream,
  }) {
    if (secure) {
      final Uint8List? key = connection.secretKey;
      if (key == null) {
        throw RemitException(
          'Cannot encrypt without secret key',
          code: RemitErrorCodes.invalidState,
        );
      }
      return stream.map(
        (final List<int> x) => RemitDataEncrypter.decryptBytes(
          data: Uint8List.fromList(x),
          key: key,
        ),
      );
    }
    return stream;
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
    for (final int receiverId in connections.keys) {
      removeConnection(receiverId);
    }
  }

  static final List<RemitSenderServerRoute> routes = <RemitSenderServerRoute>[
    RemitSenderServerPingRoute(),
    RemitSenderServerConnectionRequestRoute(),
    RemitSenderServerSecretRoute(),
    RemitSenderServerInfoRoute(),
  ];

  static Future<RemitSender> create({
    required final RemitSenderBasicInfo info,
    required final RemitConnectionAddress address,
    required final bool secure,
    required final RemitLogger logger,
  }) async {
    final RemitServer server = await RemitServer.createServer(address);
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
