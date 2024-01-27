import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerFilesystemListRoute extends RemitSenderServerRoute {
  @override
  void use(final RemitSender sender) {
    sender.server.app.post(
      path,
      (final shelf.Request request) async {
        final RemitSenderConnection? connection =
            identifyConnection(sender, request);
        if (connection == null) {
          return shelf.Response.unauthorized(
            RemitDataBody.failure(),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final String body = await request.readAsString();
        final Map<dynamic, dynamic>? data = sender.maybeDecryptJsonOrNull(
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
            await sender.filesystem.resolve(path);
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
            sender.maybeEncryptJson(
              connection: connection,
              data: <dynamic, dynamic>{
                RemitDataKeys.entities: entities,
              },
            ),
          ),
          headers: RemitHttpHeaders.construct(secure: sender.secure),
        );
      },
    );
  }

  static const String path = '/filesystem/list';
}
