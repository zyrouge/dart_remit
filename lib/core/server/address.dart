import 'package:remit/exports.dart';

class RemitConnectionAddress {
  const RemitConnectionAddress(this.host, this.port);

  factory RemitConnectionAddress.fromJson(final Map<dynamic, dynamic> json) =>
      RemitConnectionAddress(
        json[RemitDataKeys.host] as String,
        json[RemitDataKeys.port] as int,
      );

  final String host;
  final int port;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.host: host,
        RemitDataKeys.port: port,
      };

  String appendPath(final String path) {
    assert(path.startsWith('/'));
    return '$this$path';
  }

  Uri appendPathUri(final String path) => Uri.parse(appendPath(path));

  @override
  String toString() => 'http://$host:$port';
}
