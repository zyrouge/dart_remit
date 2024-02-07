import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:remit/exports.dart';
import 'package:shelf/shelf.dart' as shelf;

abstract class RemitServerRouteContext {
  const RemitServerRouteContext();
}

abstract class RemitServerRoute<Context extends RemitServerRouteContext> {
  RemitServerRoute() {
    assert(method == 'GET' || method == 'POST');
    assert(path.startsWith('/'));
  }

  FutureOr<shelf.Response> onRequest(
    final Context context,
    final shelf.Request request,
  );

  Future<http.Response> makeRequestPartial({
    required final RemitConnectionAddress address,
    final Object? body,
    final Map<String, String>? headers,
  }) {
    final Uri uri = address.appendPathUri(path);
    final Future<http.Response> response = switch (method) {
      'GET' when body == null => http.get(uri, headers: headers),
      'POST' => http.post(uri, body: body, headers: headers),
      _ => throw UnimplementedError()
    };
    return response.timeout(RemitHttpDefaults.requestTimeout);
  }

  String get method => 'GET';
  String get path;
}
