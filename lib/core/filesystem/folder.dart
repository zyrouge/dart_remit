import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:remit/exports.dart';

abstract class RemitFolder extends RemitFilesystemEntity {
  FutureOr<Stream<RemitFilesystemEntity>> list();

  Future<RemitFilesystemEntity?> resolvePaths(
    final List<String> paths,
  ) async {
    final String first = paths.first;
    await for (final RemitFilesystemEntity x in await list()) {
      if (x.basename == first) {
        if (paths.length == 1) return x;
        if (x is! RemitFolder) {
          throw RemitException(
            'Unsupported resolve on ${x.type.name} "$first"',
            code: RemitErrorCodes.unsupportedOperation,
          );
        }
        return x.resolvePaths(paths.sublist(1));
      }
    }
    return null;
  }

  Future<RemitFilesystemEntity?> resolve(final String path) =>
      resolvePaths(p.split(path));

  @override
  RemitFilesystemEntityType get type => RemitFilesystemEntityType.folder;
}

class RemitVirtualFolder extends RemitFolder {
  RemitVirtualFolder({
    required this.basename,
    required this.entities,
  });

  @override
  final String basename;
  final Map<String, RemitFilesystemEntity> entities;

  @override
  Stream<RemitFilesystemEntity> list() =>
      Stream<RemitFilesystemEntity>.fromIterable(entities.values);
}

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
      throw RemitException('Unexpected');
    });
  }

  @override
  String get basename => p.basename(directory.absolute.path);
}
