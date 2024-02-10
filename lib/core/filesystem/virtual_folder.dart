import 'dart:async';
import 'package:remit/exports.dart';

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

  @override
  Future<RemitFile> createFile(
    final String basename, {
    required final bool overwrite,
  }) async {
    throw UnsupportedError('Cannot perform file creation on virtual folder');
  }

  @override
  Future<RemitFolder> createFolder(final String basename) async {
    throw UnsupportedError('Cannot perform folder creation on virtual folder');
  }

  void addEntity(final RemitFilesystemEntity entity) {
    entities[entity.basename] = entity;
  }
}
