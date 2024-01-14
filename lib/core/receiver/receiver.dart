import 'dart:async';
import 'package:remit/exports.dart';

class RemitReceiver {
  RemitReceiver._({
    required this.info,
    required this.server,
    required this.connection,
  });

  final RemitReceiverBasicInfo info;
  final RemitServer server;
  final RemitReceiverConnection connection;
  final RemitEventer<String> events = RemitEventer<String>();

  bool active = false;
  Timer? heartbeatTimer;

  Future<void> initialize() async {
    for (final RemitReceiverServerRoute route in routes) {
      route.use(this);
    }
  }

  void onConnectionAccepted() {
    active = true;
    startHeartbeat();
  }

  void onSenderDisconnected() {
    destroy();
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitHttpDefaults.heartbeatInterval, (final _) async {
      if (!active) return;
      final bool awake = await connection.ping();
      if (!awake) {
        await destroy();
        return;
      }
      connection.lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future<void> destroy() async {
    active = false;
    heartbeatTimer?.cancel();
    await connection.disconnect();
    await server.destroy();
  }

  static final List<RemitReceiverServerRoute> routes =
      <RemitReceiverServerRoute>[
    RemitReceiverServerPingRoute(),
  ];

  // TODO: redo this
  static Future<RemitReceiver> create({
    required final RemitReceiverBasicInfo info,
    required final RemitSenderBasicInfo sender,
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
    );
    await receiver.initialize();
    final bool requested = await connection.connectionRequest();
    if (!requested) {
      await receiver.destroy();
      throw Exception('Connection request rejected');
    }
    return receiver;
  }
}
