typedef RemitEventListener<T> = void Function(T data);

class RemitEventer<T> {
  final List<RemitEventListener<T>> listeners = <RemitEventListener<T>>[];

  void subscribe(final RemitEventListener<T> listener) {
    listeners.add(listener);
  }

  void unsubscribe(final RemitEventListener<T> listener) {
    listeners.remove(listener);
  }
}
