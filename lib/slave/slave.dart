import 'dart:async';
import '../../core/exports.dart';
import 'connection.dart';
import 'route.dart';
import 'routes/exports.dart';

class RemitSlave {
  RemitSlave._({
    required this.server,
    required this.connection,
  });

  final RemitServer server;
  final RemitSlaveMasterConnection connection;

  Timer? heartbeatTimer;
  bool active = false;

  Future<void> initialize() async {
    for (final RemitSlaveServerRoute route in routes) {
      route.use(this);
    }
    startHeartbeat();
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitDefaults.heartbeatInterval, (final _) async {
      if (active) return;
      final bool awake = await connection.isAwake();
      if (!awake) {
        await destroy();
      }
    });
  }

  Future<void> destroy() async {
    active = false;
    heartbeatTimer?.cancel();
    await connection.close();
    await server.destroy();
  }

  static final List<RemitSlaveServerRoute> routes = <RemitSlaveServerRoute>[
    RemitSlaveServerPingRoute(),
  ];

  static Future<RemitSlave> create({
    required final String host,
    required final int port,
  }) async {
    final RemitServer server = await RemitServer.createServer();
    final int connectedAt = DateTime.now().millisecondsSinceEpoch;
    final RemitSlaveMasterConnection connection = RemitSlaveMasterConnection(
      host: host,
      port: port,
      connectedAt: connectedAt,
      lastHeartbeatAt: connectedAt,
    );
    final RemitSlave slave = RemitSlave._(
      server: server,
      connection: connection,
    );
    await slave.initialize();
    return slave;
  }
}
