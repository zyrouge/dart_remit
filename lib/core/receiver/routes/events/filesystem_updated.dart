import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitEventFilesystemUpdatedPairs {
  const RemitEventFilesystemUpdatedPairs({
    required this.path,
    required this.pairs,
  });

  factory RemitEventFilesystemUpdatedPairs.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      RemitEventFilesystemUpdatedPairs(
        path: json[RemitDataKeys.path] as String,
        pairs: RemitFilesystemStaticDataPairs.fromJson(
          json[RemitDataKeys.pairs] as Map<dynamic, dynamic>,
        ),
      );

  final String path;
  final RemitFilesystemStaticDataPairs pairs;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.path: path,
        RemitDataKeys.pairs: pairs.toJson(),
      };
}

class RemitReceiverServerEventFilesystemUpdatedRoute
    extends RemitReceiverServerRoute {
  @override
  final String method = 'PATCH';

  @override
  final String path = '/events/filesystem-updated';

  @override
  Future<shelf.Response> onRequest(
    final RemitReceiverServerRouteContext context,
    final shelf.Request request,
  ) async {
    if (!context.isAuthenticated(request)) {
      return shelf.Response.unauthorized(
        RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    final String body = await request.readAsString();
    final Map<dynamic, dynamic>? data =
        context.receiver.connection.optionalDecryptJsonOrNull(body);
    final List<RemitEventFilesystemUpdatedPairs>? pairs = mapKeyFactoryOrNull(
      data,
      RemitDataKeys.pairs,
      (final List<dynamic> x) => x
          .cast<Map<dynamic, dynamic>>()
          .map(RemitEventFilesystemUpdatedPairs.fromJson)
          .toList(),
    );
    if (pairs == null) {
      return shelf.Response.badRequest(
        body: RemitDataBody.failure(),
        headers: RemitHttpHeaders.construct(),
      );
    }
    context.receiver.onFilesystemUpdated(pairs);
    return shelf.Response.ok(
      RemitDataBody.successful(),
      headers: RemitHttpHeaders.construct(),
    );
  }

  Future<bool> makeRequest(
    final RemitSenderConnection connection, {
    required final List<RemitEventFilesystemUpdatedPairs> pairs,
  }) async {
    final http.Response resp = await makeRequestPartial(
      address: connection.receiverAddress,
      headers: RemitHttpHeaders.construct(
        secure: connection.secure,
        additional: <String, String>{
          RemitHeaderKeys.identifier: connection.identifier,
        },
      ),
      body: connection.optionalEncryptJson(<dynamic, dynamic>{
        RemitDataKeys.pairs: pairs
            .map((final RemitEventFilesystemUpdatedPairs x) => x.toJson())
            .toList(),
      }),
    );
    return resp.statusCode == HttpStatus.ok;
  }

  static final RemitReceiverServerEventFilesystemUpdatedRoute instance =
      RemitReceiverServerEventFilesystemUpdatedRoute();
}
