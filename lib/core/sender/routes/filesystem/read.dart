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
        final RemitFilesystemEntity? file =
            await sender.filesystem.resolve(path);
        if (file is! RemitFile) {
          return shelf.Response.badRequest(
            body: RemitDataBody.failure(),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final String? rangeHeader = request.headers['Range'];
        final (int?, int?)? range = rangeHeader != null
            ? RemitHttpHeaders.parseRangeHeader(rangeHeader)
            : (null, null);
        if (range == null) {
          return shelf.Response.badRequest(
            body: RemitDataBody.failure(),
            headers: RemitHttpHeaders.construct(),
          );
        }
        final int size = await file.size();
        return shelf.Response.ok(
          RemitDataBody.successful(
            sender.maybeEncryptStream(
              connection: connection,
              stream: await file.openRead(range.$1, range.$2),
            ),
          ),
          headers: RemitHttpHeaders.construct(
            secure: sender.secure,
            contentType: RemitHttpHeaders.binaryContentType,
            additional: <String, String>{
              'Content-Length': '$size',
            },
          ),
          context: <String, Object>{
            'shelf.io.buffer_output': false,
          },
        );
      },
    );
  }

  static const String path = '/filesystem/read';
}
