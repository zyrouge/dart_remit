import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerRouteContext extends RemitServerRouteContext {
  const RemitSenderServerRouteContext(this.sender);

  final RemitSender sender;

  bool isAuthenticated(final shelf.Request request) {
    final String? receiverToken = request.headers[RemitHeaderKeys.token];
    return sender.tokens.containsKey(receiverToken);
  }

  int? identifyConnectionId(final shelf.Request request) {
    final String? receiverToken = request.headers[RemitHeaderKeys.token];
    return sender.tokens[receiverToken];
  }

  RemitSenderConnection? identifyConnection(final shelf.Request request) {
    final int? receiverId = identifyConnectionId(request);
    return sender.connections[receiverId];
  }
}

abstract class RemitSenderServerRoute
    extends RemitServerRoute<RemitSenderServerRouteContext> {}
