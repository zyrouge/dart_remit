class SemVer {
  const SemVer(this.major, this.minor, this.patch);

  factory SemVer.parse(final String value) {
    final List<String> split = value.split('.');
    final int major = int.parse(split[0]);
    final int minor = int.parse(split[1]);
    final int patch = int.parse(split[2]);
    return SemVer(major, minor, patch);
  }

  final int major;
  final int minor;
  final int patch;

  bool isCompatible(final SemVer other) => major == other.major;

  @override
  String toString() => '$major.$minor.$patch';

  @override
  bool operator ==(final Object other) =>
      other is SemVer &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);
}
