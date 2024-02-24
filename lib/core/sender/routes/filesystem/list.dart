import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerFilesystemListRoute extends RemitSenderServerRoute {
  @override
  final String method = 'POST';

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
    final List<RemitFileStaticData> files = <RemitFileStaticData>[];
    final List<RemitFolderStaticData> folders = <RemitFolderStaticData>[];
    await for (final RemitFilesystemEntity x in await folder.list()) {
      if (x is RemitFile) {
        files.add(await x.toStaticData());
      } else if (x is RemitFolder) {
        folders.add(await x.toStaticData());
      }
    }
    return shelf.Response.ok(
      RemitDataBody.successful(
        connection.optionalEncryptJson(
          RemitFilesystemStaticDataPairs(
            files: files,
            folders: folders,
          ).toJson(),
        ),
      ),
      headers: RemitHttpHeaders.construct(secure: context.sender.secure),
    );
  }

  Future<RemitFilesystemStaticDataPairs> makeRequest(
    final RemitReceiverConnection connection, {
    required final String path,
  }) async {
    final http.Response resp = await makeRequestPartial(
      address: connection.senderAddress,
      headers: RemitHttpHeaders.construct(
        secure: connection.secure ?? false,
        additional: <String, String>{
          RemitHeaderKeys.token: connection.token ?? '',
        },
      ),
      body: connection.optionalEncryptJson(<dynamic, dynamic>{
        RemitDataKeys.path: path,
      }),
    );
    return RemitDataBody.deconstructJsonDataFactory(
      resp.body,
      RemitFilesystemStaticDataPairs.fromJson,
    );
  }

  static final RemitSenderServerFilesystemListRoute instance =
      RemitSenderServerFilesystemListRoute();
}
