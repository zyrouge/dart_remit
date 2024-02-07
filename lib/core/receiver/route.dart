import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitReceiverServerRouteContext extends RemitServerRouteContext {
  const RemitReceiverServerRouteContext(this.receiver);

  final RemitReceiver receiver;

  bool isAuthenticated(final shelf.Request request) {
    final String? senderIdentifier =
        request.headers[RemitHeaderKeys.identifier];
    return receiver.connection.identifier == senderIdentifier;
  }
}

abstract class RemitReceiverServerRoute
    extends RemitServerRoute<RemitReceiverServerRouteContext> {}
