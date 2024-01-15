class RemitException implements Exception {
  RemitException(
    this.text, {
    this.code,
  });

  final String? code;
  final String text;

  @override
  String toString() {
    if (code != null) return 'RemitException: [$code] $text';
    return 'RemitException: $text';
  }
}
