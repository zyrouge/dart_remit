import 'dart:async';
import 'package:remit/exports.dart';

class RemitSender {
  RemitSender._({
    required this.info,
    required this.server,
  }) : inviteCode = UUID.generateInviteCode();

  final RemitSenderBasicInfo info;
  final RemitServer server;
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
  }

  Future<void> makeConnection(final RemitReceiverBasicInfo receiverInfo) async {
    // TODO: defer user confirmation
    final String receiverToken = UUID.generateToken();
    final RemitSenderConnection connection = RemitSenderConnection(
      receiver: receiverInfo,
      token: receiverToken,
      connectedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final bool accepted = await connection.connectionAccepted();
    if (accepted) {
      final int receiverId = receiverIdGenerator.next();
      connections[receiverId] = connection;
      tokens[receiverToken] = receiverId;
    }
  }

  Future<void> removeConnection(final int receiverId) async {
    final RemitSenderConnection? connection = connections.remove(receiverId);
    if (connection == null) return;
    tokens.remove(connection.token);
    await connection.disconnect();
  }

  Future<SecureKey?> generateSecret(final int receiverId) async {
    final RemitSenderConnection? connection = connections[receiverId];
    if (connection == null) return null;
    if (connection.secretKey != null) {
      removeConnection(receiverId);
      return null;
    }
    final SecureKey secureKey = SecureKey.generate32bits();
    connection.secretKey = secureKey;
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
          await removeConnection(x.key);
          return;
        }
        x.value.lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
      }
    });
  }

  Future<void> destroy() async {
    heartbeatTimer?.cancel();
    await server.destroy();
    for (final int receiverId in connections.keys) {
      await removeConnection(receiverId);
    }
  }

  static final List<RemitSenderServerRoute> routes = <RemitSenderServerRoute>[
    RemitSenderServerConnectionRequestRoute(),
  ];

  static Future<RemitSender> create({
    required final RemitSenderBasicInfo info,
  }) async {
    final RemitServer server = await RemitServer.createServer(
      host: info.host,
      port: info.port,
    );
    final RemitSender master = RemitSender._(
      info: info,
      server: server,
    );
    await master.initialize();
    return master;
  }
}
