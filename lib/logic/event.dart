/// C#-style event system for Dart.
///
/// Dart 不支持同名类不同泛型参数个数，因此按参数数量分别定义：
/// - [Event]  — 0 个参数
/// - [Event1] — 1 个参数
/// - [Event2] — 2 个参数
/// - [Event3] — 3 个参数
/// - [Event4] — 4 个参数
/// - [Event5] — 5 个参数
///
/// 用法示例：
/// ```dart
/// final Event listChanged = Event();
/// final Event1<Conversation> newConversation = Event1();
/// final Event2<int, int> unreadCountChanged = Event2();
///
/// // 订阅
/// unreadCountChanged.on(_onUnreadCountChanged);
///
/// // 触发
/// unreadCountChanged.emit(roomId, count);
///
/// // 取消订阅
/// unreadCountChanged.off(_onUnreadCountChanged);
/// ```

// ──────────────────────────────────────────────
// 0 个参数
// ──────────────────────────────────────────────

class Event {
  final List<void Function()> _listeners = [];

  void on(void Function() listener) => _listeners.add(listener);

  void off(void Function() listener) => _listeners.remove(listener);

  void emit() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  void clear() => _listeners.clear();
}

// ──────────────────────────────────────────────
// 1 个参数
// ──────────────────────────────────────────────

class Event1<T> {
  final List<void Function(T)> _listeners = [];

  void on(void Function(T) listener) => _listeners.add(listener);

  void off(void Function(T) listener) => _listeners.remove(listener);

  void emit(T arg) {
    for (final l in List.of(_listeners)) {
      l(arg);
    }
  }

  void clear() => _listeners.clear();
}

// ──────────────────────────────────────────────
// 2 个参数
// ──────────────────────────────────────────────

class Event2<T1, T2> {
  final List<void Function(T1, T2)> _listeners = [];

  void on(void Function(T1, T2) listener) => _listeners.add(listener);

  void off(void Function(T1, T2) listener) => _listeners.remove(listener);

  void emit(T1 arg1, T2 arg2) {
    for (final l in List.of(_listeners)) {
      l(arg1, arg2);
    }
  }

  void clear() => _listeners.clear();
}

// ──────────────────────────────────────────────
// 3 个参数
// ──────────────────────────────────────────────

class Event3<T1, T2, T3> {
  final List<void Function(T1, T2, T3)> _listeners = [];

  void on(void Function(T1, T2, T3) listener) => _listeners.add(listener);

  void off(void Function(T1, T2, T3) listener) => _listeners.remove(listener);

  void emit(T1 arg1, T2 arg2, T3 arg3) {
    for (final l in List.of(_listeners)) {
      l(arg1, arg2, arg3);
    }
  }

  void clear() => _listeners.clear();
}

// ──────────────────────────────────────────────
// 4 个参数
// ──────────────────────────────────────────────

class Event4<T1, T2, T3, T4> {
  final List<void Function(T1, T2, T3, T4)> _listeners = [];

  void on(void Function(T1, T2, T3, T4) listener) => _listeners.add(listener);

  void off(void Function(T1, T2, T3, T4) listener) =>
      _listeners.remove(listener);

  void emit(T1 arg1, T2 arg2, T3 arg3, T4 arg4) {
    for (final l in List.of(_listeners)) {
      l(arg1, arg2, arg3, arg4);
    }
  }

  void clear() => _listeners.clear();
}

// ──────────────────────────────────────────────
// 5 个参数
// ──────────────────────────────────────────────

class Event5<T1, T2, T3, T4, T5> {
  final List<void Function(T1, T2, T3, T4, T5)> _listeners = [];

  void on(void Function(T1, T2, T3, T4, T5) listener) =>
      _listeners.add(listener);

  void off(void Function(T1, T2, T3, T4, T5) listener) =>
      _listeners.remove(listener);

  void emit(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5) {
    for (final l in List.of(_listeners)) {
      l(arg1, arg2, arg3, arg4, arg5);
    }
  }

  void clear() => _listeners.clear();
}
