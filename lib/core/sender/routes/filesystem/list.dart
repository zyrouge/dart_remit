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
    final Map<dynamic, dynamic>? data = context.sender.maybeDecryptJsonOrNull(
      connection: connection,
      data: body,
    );
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
        context.sender.maybeEncryptJson(
          connection: connection,
          data: <dynamic, dynamic>{
            RemitDataKeys.entities: entities,
          },
        ),
      ),
      headers: RemitHttpHeaders.construct(secure: context.sender.secure),
    );
  }
}
