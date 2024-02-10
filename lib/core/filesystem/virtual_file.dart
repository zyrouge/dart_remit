import 'dart:async';
import 'package:remit/exports.dart';

class RemitVirtualFile extends RemitFile {
  RemitVirtualFile({
    required this.basename,
    required this.content,
  });

  @override
  final String basename;
  final List<int> content;

  @override
  Stream<List<int>> openRead([final int? start, final int? end]) =>
      Stream<List<int>>.value(content.sublist(start ?? 0, end));

  @override
  StreamSink<List<int>> openWrite() {
    throw UnsupportedError('Cannot perform write on virtual file');
  }

  @override
  int size() => content.length;
}
