import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/logic/events/conversation_unread_count_changed_event.dart';
import 'package:scene_hub/sc.dart';

/// 聊天页面内「有新消息 xN」悬浮提示的未读计数。
/// key: roomId
class ConversationUnreadHintNotifier extends StateNotifier<int> {
  final int roomId;
  StreamSubscription<ConversationUnreadCountChangedEvent>? _sub1;
  ConversationUnreadHintNotifier(this.roomId) : super(0) {
    _sub1 = sc.eventBus.on<ConversationUnreadCountChangedEvent>().listen((
      event,
    ) {
      if (event.roomId == roomId) {
        state = event.unreadCount;
      }
    });

    final c = sc.conversationManager.getByRoomId(roomId);
    if (c != null) {
      state = c.unreadCount;
    }
  }
  @override
  void dispose() {
    _sub1?.cancel();
    _sub1 = null;

    super.dispose();
  }
}

final conversationUnreadHintProvider = StateNotifierProvider.autoDispose
    .family<ConversationUnreadHintNotifier, int, int>(
      (ref, roomId) => ConversationUnreadHintNotifier(roomId),
    );
