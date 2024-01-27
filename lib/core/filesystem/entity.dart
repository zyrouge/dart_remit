enum RemitFilesystemEntityType {
  file,
  folder,
}

abstract class RemitFilesystemEntity {
  String get basename;
  RemitFilesystemEntityType get type;
}
