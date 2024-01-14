import 'package:remit/exports.dart';

class RemitReceiverBasicInfo {
  const RemitReceiverBasicInfo({
    required this.username,
    required this.host,
    required this.port,
  });

  factory RemitReceiverBasicInfo.fromJson(final Map<dynamic, dynamic> json) =>
      RemitReceiverBasicInfo(
        username: json[RemitDataKeys.username] as String,
        host: json[RemitDataKeys.host] as String,
        port: json[RemitDataKeys.port] as int,
      );

  final String username;
  final String host;
  final int port;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.username: username,
        RemitDataKeys.host: host,
        RemitDataKeys.port: port,
      };
}
