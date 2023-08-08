import 'dart:async';
import '../../core/exports.dart';
import 'connection.dart';
import 'route.dart';
import 'routes/exports.dart';

class RemitMaster {
  RemitMaster._({
    required this.server,
  });

  final RemitServer server;

  Timer? heartbeatTimer;
  final Map<String, RemitMasterSlaveConnection> connections =
      <String, RemitMasterSlaveConnection>{};

  Future<void> initialize() async {
    for (final RemitMasterServerRoute route in routes) {
      route.use(this);
    }
    startHeartbeat();
  }

  void addConnection(final RemitMasterSlaveConnection conn) {
    connections[conn.id] = conn;
  }

  Future<void> removeConnection(final RemitMasterSlaveConnection conn) async {
    connections.remove(conn.id);
    await conn.close();
  }

  void startHeartbeat() {
    heartbeatTimer =
        Timer.periodic(RemitDefaults.heartbeatInterval, (final _) async {
      for (final RemitMasterSlaveConnection conn in connections.values) {
        final bool awake = await conn.isAwake();
        if (!awake) {
          await removeConnection(conn);
        }
      }
    });
  }

  Future<void> destroy() async {
    heartbeatTimer?.cancel();
    for (final RemitMasterSlaveConnection conn in connections.values) {
      await removeConnection(conn);
    }
    await server.destroy();
  }

  static final List<RemitMasterServerRoute> routes = <RemitMasterServerRoute>[
    RemitMasterServerConnectRoute(),
  ];

  static Future<RemitMaster> create() async {
    final RemitServer server = await RemitServer.createServer();
    final RemitMaster master = RemitMaster._(server: server);
    await master.initialize();
    return master;
  }
}
