import 'package:remit/core/exports.dart';
import 'package:remit/exports.dart';

class RemitException implements Exception {
  const RemitException(
    this.text, {
    this.code,
  });

  factory RemitException.fromJson(final Map<dynamic, dynamic> data) =>
      RemitException(
        data['text'] as String,
        code: data['code'] as String?,
      );

  factory RemitException.nonSuccessResponse() => const RemitException(
        'Response returned non-success status',
        code: RemitErrorCodes.nonSuccessResponse,
      );

  factory RemitException.invalidResponseData() => const RemitException(
        'Response returned invalid data',
        code: RemitErrorCodes.invalidResponseData,
      );

  factory RemitException.unexpectedResponseData() => const RemitException(
        'Response returned unexpected data',
        code: RemitErrorCodes.unexpectedResponseData,
      );

  factory RemitException.connectionRejected() => const RemitException(
        'Node rejected connection request',
        code: RemitErrorCodes.connectionRejected,
      );

  factory RemitException.missingSecretKey() => const RemitException(
        'Missing secret key',
        code: RemitErrorCodes.missingSecretKey,
      );

  factory RemitException.cannotBrowseNonFolders() => const RemitException(
        'Cannot browse non-folder entity',
        code: RemitErrorCodes.cannotBrowseNonFolders,
      );

  factory RemitException.filesystemEntityAlreadyExists() =>
      const RemitException(
        'Entity already exists',
        code: RemitErrorCodes.filesystemEntityAlreadyExists,
      );

  factory RemitException.cannotFetchSecretKey() => const RemitException(
        'Cannot fetch secret key',
        code: RemitErrorCodes.cannotFetchSecretKey,
      );

  factory RemitException.invaildData() => const RemitException(
        'Received invalid data',
        code: RemitErrorCodes.invalidData,
      );

  final String text;
  final String? code;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'text': text,
        'code': code,
      };

  @override
  String toString() {
    if (code != null) return 'RemitException: [$code] $text';
    return 'RemitException: $text';
  }
}
