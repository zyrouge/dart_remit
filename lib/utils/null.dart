V? nullTake<U, V>(
  final U? data,
  final V? Function(U) take,
) =>
    data != null ? take(data) : null;
