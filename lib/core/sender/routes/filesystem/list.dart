import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

typedef _RouteDataFile = ({
  String basename,
  int size,
});

typedef _RouteDataFolder = ({
  String basename,
});

class RemitSenderServerFilesystemRouteData {
  const RemitSenderServerFilesystemRouteData({
    required this.files,
    required this.folders,
  });

  factory RemitSenderServerFilesystemRouteData.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      RemitSenderServerFilesystemRouteData(
        files: (json[RemitDataKeys.files] as List<dynamic>)
            .cast<List<dynamic>>()
            .map(fileFromJson)
            .toList(),
        folders: (json[RemitDataKeys.folders] as List<dynamic>)
            .cast<List<dynamic>>()
            .map(folderFromJson)
            .toList(),
      );

  final List<_RouteDataFile> files;
  final List<_RouteDataFolder> folders;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.files: files.map(fileToJson).toList(),
        RemitDataKeys.folders: folders.map(folderToJson).toList(),
      };

  static _RouteDataFile fileFromJson(
    final List<dynamic> x,
  ) =>
      (basename: x[0], size: x[1]);

  static _RouteDataFolder folderFromJson(final List<dynamic> x) =>
      (basename: x[0]);

  static List<dynamic> fileToJson(final _RouteDataFile x) =>
      <dynamic>[x.basename, x.size];

  static List<dynamic> folderToJson(final _RouteDataFolder x) =>
      <dynamic>[x.basename];
}

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

  Future<RemitSenderServerFilesystemRouteData> makeRequest(
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
    final RemitDataBody<String> body = RemitDataBody.deconstruct(resp.body);
    if (!body.success) {
      throw body.error ?? RemitException.nonSuccessResponse();
    }
    if (body.data == null) {
      throw RemitException.unexpectedResponseData();
    }
    final Map<dynamic, dynamic>? raw =
        connection.optionalDecryptJsonOrNull(body.data!);
    final RemitSenderServerFilesystemRouteData? data = jsonFactoryOrNull(
      raw,
      RemitSenderServerFilesystemRouteData.fromJson,
    );
    if (data == null) {
      throw RemitException.invalidResponseData();
    }
    return data;
  }

  static final RemitSenderServerFilesystemListRoute instance =
      RemitSenderServerFilesystemListRoute();
}
