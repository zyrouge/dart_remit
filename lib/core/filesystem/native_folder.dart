import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:remit/exports.dart';

class RemitNativeFolder extends RemitFolder {
  RemitNativeFolder(this.directory);

  final Directory directory;

  @override
  Stream<RemitFilesystemEntity> list() {
    final Stream<FileSystemEntity> entities = directory
        .list(followLinks: false)
        .skipWhile((final FileSystemEntity x) => x is! File && x is! Directory);
    return entities.map((final FileSystemEntity x) {
      if (x is File) return RemitNativeFile(x);
      if (x is Directory) return RemitNativeFolder(x);
      throw UnimplementedError();
    });
  }

  @override
  Future<RemitFile> createFile(
    final String basename, {
    required final bool overwrite,
  }) async {
    final File file = File(p.join(directory.path, basename));
    await file.create(recursive: true, exclusive: overwrite);
    return RemitNativeFile(file);
  }

  @override
  Future<RemitFolder> createFolder(final String basename) async {
    final Directory folder = Directory(p.join(directory.path, basename));
    await folder.create(recursive: true);
    return RemitNativeFolder(folder);
  }

  @override
  String get basename => p.basename(directory.path);
}
