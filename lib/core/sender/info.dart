import 'package:remit/exports.dart';

class RemitSenderBasicInfo {
  const RemitSenderBasicInfo({
    required this.username,
    required this.device,
  });

  factory RemitSenderBasicInfo.fromJson(final Map<dynamic, dynamic> json) =>
      RemitSenderBasicInfo(
        username: json[RemitDataKeys.username] as String,
        device: json[RemitDataKeys.device] as String?,
      );

  final String username;
  final String? device;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.username: username,
        RemitDataKeys.device: device,
      };
}
