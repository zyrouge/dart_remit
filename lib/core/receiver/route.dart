import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

abstract class RemitReceiverServerRoute {
  void use(final RemitReceiver receiver);

  bool isAuthenticated(
    final RemitReceiver receiver,
    final shelf.Request request,
  ) {
    final String? senderIdentifier =
        request.headers[RemitHeaderKeys.identifier];
    return receiver.connection.identifier == senderIdentifier;
  }
}
