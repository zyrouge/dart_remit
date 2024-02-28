import 'dart:async';
import 'package:remit/exports.dart';

abstract class RemitFile extends RemitFilesystemEntity {
  FutureOr<Stream<List<int>>> openRead([final int? start, final int? end]);
  FutureOr<StreamSink<List<int>>> openWrite();
  FutureOr<int> size();

  Future<RemitFileStaticData> toStaticData() async =>
      RemitFileStaticData(basename: basename, size: await size());

  @override
  RemitFilesystemEntityType get type => RemitFilesystemEntityType.file;
}

class RemitFileStaticData {
  const RemitFileStaticData({
    required this.basename,
    required this.size,
  });

  factory RemitFileStaticData.fromJson(final Map<dynamic, dynamic> json) =>
      RemitFileStaticData(
        basename: json['0'] as String,
        size: json['1'] as int,
      );

  final String basename;
  final int size;

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'0': basename, '1': size};
}
