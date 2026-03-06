import 'package:flutter_riverpod/legacy.dart';

/// 聊天页面内「有新消息 xN」悬浮提示的未读计数。
/// key: roomId
class ChatUnreadHintNotifier extends StateNotifier<int> {
  ChatUnreadHintNotifier() : super(0);

  void increment([int delta = 1]) {
    state += delta;
  }

  void clear() {
    if (state > 0) state = 0;
  }
}

final chatUnreadHintProvider = StateNotifierProvider.autoDispose
    .family<ChatUnreadHintNotifier, int, int>(
      (ref, roomId) => ChatUnreadHintNotifier(),
    );
