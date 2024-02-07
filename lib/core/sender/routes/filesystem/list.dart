import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerFilesystemListRoute extends RemitSenderServerRoute {
  @override
  final String path = '/filesystem/list';

  @override
  Future<shelf.Response> onRequest(
    final RemitSenderServerRouteContext context,
    final shelf.Request request,
  ) async {
    final RemitSenderConnection? connection =
        context.identifyConnection(request);
    if (connection == null) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final String body = await request.readAsString();
    final Map<dynamic, dynamic>? data =
        connection.optionalDecryptJsonOrNull(body);
    final String? path = mapKeyOrNull(data, RemitDataKeys.path);
    if (data == null || path == null) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final RemitFilesystemEntity? folder =
        await context.sender.filesystem.resolve(path);
    if (folder is! RemitFolder) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final List<String> entities = <String>[];
    await for (final RemitFilesystemEntity x in await folder.list()) {
      entities.add(x.basename);
    }
    return shelf.Response.ok(
      RemitDataBody.successful(
        connection.optionalEncryptJson(<dynamic, dynamic>{
          RemitDataKeys.entities: entities,
        }),
      ),
      headers: RemitHttpHeaders.construct(secure: context.sender.secure),
    );
  }

  Future<List<String>> makeRequest(
    final RemitReceiverConnection connection,
  ) async {
    final http.Response resp = await makeRequestPartial(
      address: connection.senderAddress,
      headers: RemitHttpHeaders.construct(
        contentType: null,
        secure: connection.secure ?? false,
        additional: <String, String>{
          RemitHeaderKeys.token: connection.token ?? '',
        },
      ),
    );
    final RemitDataBody<dynamic> body = RemitDataBody.deconstruct(resp.body);
    final Map<dynamic, dynamic>? data =
        connection.optionalDecryptJsonOrNull(body.data);
    final List<String>? entities = mapKeyFactoryOrNull(
      data,
      RemitDataKeys.entities,
      (final dynamic x) => (x as List<dynamic>).cast(),
    );
    if (entities == null) {
      throw RemitException.invalidResponseData();
    }
    return entities;
  }

  static final RemitSenderServerConnectionSecretRoute instance =
      RemitSenderServerConnectionSecretRoute();
}
