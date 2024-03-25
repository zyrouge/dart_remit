typedef RemitEventListener<T> = void Function(T data);

class RemitEventer<T> {
  final List<RemitEventListener<T>> listeners = <RemitEventListener<T>>[];

  void subscribe(final RemitEventListener<T> listener) {
    listeners.add(listener);
  }

  void unsubscribe(final RemitEventListener<T> listener) {
    listeners.remove(listener);
  }

  void dispatch(final T value) {
    for (final RemitEventListener<T> x in listeners) {
      x(value);
    }
  }
}
