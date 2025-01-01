import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

class RemitEventFilesystemUpdatedAddedEntity {
  const RemitEventFilesystemUpdatedAddedEntity({
    required this.path,
    required this.pairs,
  });

  factory RemitEventFilesystemUpdatedAddedEntity.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      RemitEventFilesystemUpdatedAddedEntity(
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

class RemitEventFilesystemUpdatedPairs {
  const RemitEventFilesystemUpdatedPairs({
    required this.added,
    required this.modified,
    required this.removed,
  });

  factory RemitEventFilesystemUpdatedPairs.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      RemitEventFilesystemUpdatedPairs(
        added: (json[RemitDataKeys.added] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(RemitEventFilesystemUpdatedAddedEntity.fromJson)
            .toList(),
        modified: (json[RemitDataKeys.modified] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(RemitEventFilesystemUpdatedAddedEntity.fromJson)
            .toList(),
        removed: (json[RemitDataKeys.removed] as List<dynamic>).cast<String>(),
      );

  final List<RemitEventFilesystemUpdatedAddedEntity> added;
  final List<RemitEventFilesystemUpdatedAddedEntity> modified;
  final List<String> removed;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.added: added
            .map((final RemitEventFilesystemUpdatedAddedEntity x) => x.toJson())
            .toList(),
        RemitDataKeys.modified: added
            .map((final RemitEventFilesystemUpdatedAddedEntity x) => x.toJson())
            .toList(),
        RemitDataKeys.removed: removed,
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
    final RemitEventFilesystemUpdatedPairs? pairs = mapKeyFactoryOrNull(
      data,
      RemitDataKeys.pairs,
      RemitEventFilesystemUpdatedPairs.fromJson,
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

  Future<void> makeRequest(
    final RemitSenderConnection connection, {
    required final RemitEventFilesystemUpdatedPairs pairs,
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
        RemitDataKeys.pairs: pairs.toJson(),
      }),
    );
    if (resp.statusCode != HttpStatus.ok) {
      throw RemitException.nonSuccessResponse();
    }
  }

  static final RemitReceiverServerEventFilesystemUpdatedRoute instance =
      RemitReceiverServerEventFilesystemUpdatedRoute();
}
