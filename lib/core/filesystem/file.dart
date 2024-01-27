import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:remit/exports.dart';

abstract class RemitFile extends RemitFilesystemEntity {
  FutureOr<Stream<List<int>>> openRead([final int? start, final int? end]);
  FutureOr<int> size();

  @override
  RemitFilesystemEntityType get type => RemitFilesystemEntityType.file;
}

class RemitNativeFile extends RemitFile {
  RemitNativeFile(this.file);

  final File file;

  @override
  Stream<List<int>> openRead([final int? start, final int? end]) =>
      file.openRead(start, end);

  @override
  Future<int> size() => file.length();

  @override
  String get basename => p.basename(file.absolute.path);
}
