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
    final List<String> files = <String>[];
    final List<String> folders = <String>[];
    await for (final RemitFilesystemEntity x in await folder.list()) {
      switch (x.type) {
        case RemitFilesystemEntityType.file:
          files.add(x.basename);

        case RemitFilesystemEntityType.folder:
          folders.add(x.basename);
      }
    }
    return shelf.Response.ok(
      RemitDataBody.successful(
        connection.optionalEncryptJson(<dynamic, dynamic>{
          RemitDataKeys.files: files,
          RemitDataKeys.folders: folders,
        }),
      ),
      headers: RemitHttpHeaders.construct(secure: context.sender.secure),
    );
  }

  Future<({List<String> files, List<String> folders})> makeRequest(
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
    final List<String>? files = mapKeyAsListOrNull(data, RemitDataKeys.files);
    final List<String>? folders =
        mapKeyAsListOrNull(data, RemitDataKeys.folders);
    if (files == null || folders == null) {
      throw RemitException.invalidResponseData();
    }
    return (files: files, folders: folders);
  }

  static final RemitSenderServerConnectionSecretRoute instance =
      RemitSenderServerConnectionSecretRoute();
}
