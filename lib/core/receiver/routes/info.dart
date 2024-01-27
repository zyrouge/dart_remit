import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

// TODO: not currently useful
class RemitReceiverServerInfoRoute extends RemitReceiverServerRoute {
  @override
  void use(final RemitReceiver receiver) {
    receiver.server.app.post(
      path,
      (final shelf.Request request) => shelf.Response.ok(
        RemitDataBody.successful(receiver.info.toJson()),
        headers: RemitHttpHeaders.construct(),
      ),
    );
  }

  static const String path = '/info';
}
