import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

abstract class RemitSenderServerRoute {
  void use(final RemitSender sender);

  bool isAuthenticated(
    final RemitSender sender,
    final shelf.Request req,
  ) {
    final String? receiverToken = req.headers[RemitHeaderKeys.token];
    return sender.tokens.containsKey(receiverToken);
  }

  int? identifyReceiverId(
    final RemitSender sender,
    final shelf.Request req,
  ) {
    final String? receiverToken = req.headers[RemitHeaderKeys.token];
    return sender.tokens[receiverToken];
  }
}
