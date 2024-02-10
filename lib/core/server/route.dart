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
    final String? body,
    final Map<String, String>? headers,
  }) async {
    final http.StreamedResponse response = await makeRequestPartialStreamed(
      address: address,
      body: body,
      headers: headers,
    );
    return http.Response.fromStream(response)
        .timeout(RemitHttpDefaults.requestTimeout);
  }

  Future<http.StreamedResponse> makeRequestPartialStreamed({
    required final RemitConnectionAddress address,
    final String? body,
    final Map<String, String>? headers,
  }) async {
    final Uri uri = address.appendPathUri(path);
    final http.Request request = http.Request(method, uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      if (method == 'GET') {
        throw UnsupportedError('Cannot create GET with body');
      }
      request.body = body;
    }
    return request.send();
  }

  String get method => 'GET';
  String get path;
}
