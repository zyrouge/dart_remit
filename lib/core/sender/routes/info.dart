import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerInfoRoute extends RemitSenderServerRoute {
  @override
  final String path = '/info';

  @override
  shelf.Response onRequest(
    final RemitSenderServerRouteContext context,
    final shelf.Request request,
  ) =>
      shelf.Response.ok(
        RemitDataBody.successful(context.sender.info.toJson()),
        headers: RemitHttpHeaders.construct(),
      );

  Future<RemitSenderBasicInfo> makeRequest(
    final RemitConnectionAddress address,
  ) async {
    final http.Response resp = await makeRequestPartial(
      address: address,
      headers: RemitHttpHeaders.construct(contentType: null),
    );
    return RemitDataBody.deconstructJsonDataFactory(
      resp.body,
      RemitSenderBasicInfo.fromJson,
    );
  }

  static final RemitSenderServerInfoRoute instance =
      RemitSenderServerInfoRoute();
}
