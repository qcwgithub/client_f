import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/sc.dart';

/// 聊天页面内「有新消息 xN」悬浮提示的未读计数。
/// key: roomId
class ConversationUnreadHintNotifier extends StateNotifier<int> {
  final int roomId;
  ConversationUnreadHintNotifier(this.roomId) : super(0) {
    final c = sc.conversationManager.getByRoomId(roomId);
    if (c != null) {
      state = c.unreadCount;
    }

    sc.conversationManager.unreadCountChanged.on(_onUnreadCountChanged);
  }

  void _onUnreadCountChanged(int changedRoomId, int unreadCount) {
    if (changedRoomId == roomId) {
      state = unreadCount;
    }
  }

  @override
  void dispose() {
    sc.conversationManager.unreadCountChanged.off(_onUnreadCountChanged);

    super.dispose();
  }
}

final conversationUnreadHintProvider = StateNotifierProvider.autoDispose
    .family<ConversationUnreadHintNotifier, int, int>(
      (ref, roomId) => ConversationUnreadHintNotifier(roomId),
    );
