import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:remit/exports.dart';

abstract class RemitFolder extends RemitFilesystemEntity {
  FutureOr<Stream<RemitFilesystemEntity>> list();

  FutureOr<RemitFile> createFile(
    final String basename, {
    required final bool overwrite,
  });

  FutureOr<RemitFolder> createFolder(final String basename);

  Future<RemitFilesystemEntity?> resolvePaths(
    final List<String> paths,
  ) async {
    if (paths.isEmpty) return this;
    final String first = paths.first;
    await for (final RemitFilesystemEntity x in await list()) {
      if (x.basename == first) {
        if (paths.length == 1) return x;
        if (x is! RemitFolder) {
          throw RemitException.cannotBrowseNonFolders();
        }
        return x.resolvePaths(paths.sublist(1));
      }
    }
    return null;
  }

  Future<RemitFilesystemEntity?> resolve(final String path) =>
      resolvePaths(p.split(path));

  Future<bool> exists(final String path) async {
    final RemitFilesystemEntity? resolved = await resolve(path);
    return resolved != null;
  }

  Future<RemitFolderStaticData> toStaticData() async =>
      RemitFolderStaticData(basename: basename);

  @override
  RemitFilesystemEntityType get type => RemitFilesystemEntityType.folder;
}

class RemitFolderStaticData {
  const RemitFolderStaticData({
    required this.basename,
  });

  factory RemitFolderStaticData.fromJson(final Map<dynamic, dynamic> json) =>
      RemitFolderStaticData(basename: json[0] as String);

  final String basename;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{0: basename};
}
