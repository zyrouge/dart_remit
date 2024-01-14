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
  final SequentialUUIDGenerator senderIdGenerator = SequentialUUIDGenerator();

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
    final String senderToken = UUID.generateToken();
    final RemitSenderConnection conn = RemitSenderConnection(
      receiver: receiverInfo,
      token: senderToken,
      connectedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final bool accepted = await conn.connectionAccepted();
    if (accepted) {
      addConnection(conn);
    }
  }

  void addConnection(final RemitSenderConnection connection) {
    final int senderId = senderIdGenerator.next();
    connections[senderId] = connection;
  }

  Future<void> removeConnection(final int senderId) async {
    connections.remove(senderId);
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
    for (final int senderId in connections.keys) {
      await removeConnection(senderId);
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
