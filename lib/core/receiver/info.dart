import 'package:remit/exports.dart';

class RemitReceiverBasicInfo {
  const RemitReceiverBasicInfo({
    required this.username,
    required this.device,
  });

  factory RemitReceiverBasicInfo.fromJson(final Map<dynamic, dynamic> json) =>
      RemitReceiverBasicInfo(
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
