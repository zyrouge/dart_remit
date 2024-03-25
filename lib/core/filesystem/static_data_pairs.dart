import 'package:remit/exports.dart';

class RemitFilesystemStaticDataPairs {
  const RemitFilesystemStaticDataPairs({
    required this.files,
    required this.folders,
  });

  factory RemitFilesystemStaticDataPairs.fromJson(
    final Map<dynamic, dynamic> json,
  ) =>
      RemitFilesystemStaticDataPairs(
        files: (json[RemitDataKeys.files] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(RemitFileStaticData.fromJson)
            .toList(),
        folders: (json[RemitDataKeys.folders] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(RemitFolderStaticData.fromJson)
            .toList(),
      );

  final List<RemitFileStaticData> files;
  final List<RemitFolderStaticData> folders;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        RemitDataKeys.files:
            files.map((final RemitFileStaticData x) => x.toJson()).toList(),
        RemitDataKeys.folders:
            folders.map((final RemitFolderStaticData x) => x.toJson()).toList(),
      };

  int get length => files.length + folders.length;
  bool get isEmpty => files.isEmpty && files.isEmpty;
  bool get isNotEmpty => files.isNotEmpty || folders.isNotEmpty;
}
