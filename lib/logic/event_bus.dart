import 'dart:async';

class EventBus {
  final _map = <Type, StreamController>{};
  Stream<T> on<T>() {
    if (!_map.containsKey(T)) {
      _map[T] = StreamController<T>.broadcast();
    }
    return _map[T]!.stream as Stream<T>;
  }

  void emit<T>(T event) {
    _map[T]?.add(event);
  }
}

final eventBus = EventBus();
