import 'dart:async';
import 'package:remit/exports.dart';

abstract class RemitFile extends RemitFilesystemEntity {
  FutureOr<Stream<List<int>>> openRead([final int? start, final int? end]);
  FutureOr<StreamSink<List<int>>> openWrite();
  FutureOr<int> size();

  @override
  RemitFilesystemEntityType get type => RemitFilesystemEntityType.file;
}
