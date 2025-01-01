import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitSenderServerFilesystemReadRoute extends RemitSenderServerRoute {
  @override
  final String method = 'POST';

  @override
  final String path = '/filesystem/read';

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
    final RemitFilesystemEntity? file =
        await context.sender.filesystem.resolve(path);
    if (file is! RemitFile) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final String? rangeHeader = request.headers[RemitHeaderKeys.range];
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
    final Uint8List? iv =
        context.sender.secure ? SecureKey.generate8bytes() : null;
    return shelf.Response.ok(
      connection.optionalEncryptStream(
        stream: await file.openRead(range.$1, range.$2),
        iv: iv,
      ),
      headers: RemitHttpHeaders.construct(
        secure: context.sender.secure,
        contentType: RemitHttpHeaders.binaryContentType,
        additional: <String, String>{
          if (iv != null) RemitHeaderKeys.contentNonce: hex.encode(iv),
          'Content-Length': '$size',
        },
      ),
      context: <String, Object>{
        'shelf.io.buffer_output': false,
      },
    );
  }

  Future<Stream<List<int>>> makeRequest(
    final RemitReceiverConnection connection, {
    required final String path,
    required final int? rangeStart,
    required final int? rangeEnd,
  }) async {
    final String? rangeHeader =
        RemitHttpHeaders.createRangeHeader(rangeStart, rangeEnd);
    final http.StreamedResponse resp = await makeRequestPartialStreamed(
      address: connection.senderAddress,
      headers: RemitHttpHeaders.construct(
        secure: connection.secure ?? false,
        additional: <String, String>{
          RemitHeaderKeys.token: connection.token ?? '',
          if (rangeHeader != null) RemitHeaderKeys.range: rangeHeader,
        },
      ),
      body: connection.optionalEncryptJson(<dynamic, dynamic>{
        RemitDataKeys.path: path,
      }),
    );
    if (resp.statusCode != 200) {
      throw RemitException.nonSuccessResponse();
    }
    final Uint8List? iv = connection.secure ?? false
        ? nullTake(
            resp.headers[RemitHeaderKeys.contentNonce],
            (final String x) => Uint8List.fromList(hex.decode(x)),
          )
        : null;
    return connection.optionalDecryptStream(stream: resp.stream, iv: iv);
  }

  static final RemitSenderServerFilesystemReadRoute instance =
      RemitSenderServerFilesystemReadRoute();
}
