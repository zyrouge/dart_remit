import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

abstract class RemitSenderServerRoute {
  void use(final RemitSender sender);

  bool isAuthenticated(
    final RemitSender sender,
    final shelf.Request request,
  ) {
    final String? receiverToken = request.headers[RemitHeaderKeys.token];
    return sender.tokens.containsKey(receiverToken);
  }

  int? identifyConnectionId(
    final RemitSender sender,
    final shelf.Request request,
  ) {
    final String? receiverToken = request.headers[RemitHeaderKeys.token];
    return sender.tokens[receiverToken];
  }

  RemitSenderConnection? identifyConnection(
    final RemitSender sender,
    final shelf.Request request,
  ) {
    final int? receiverId = identifyConnectionId(sender, request);
    return sender.connections[receiverId];
  }
}
