import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/logic/events/friend_chat_refresh_event.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

export 'package:scene_hub/providers/chat_messages_notifier.dart';

class FriendChatMessagesNotifier extends ChatMessagesNotifier {
  StreamSubscription<FriendChatRefreshEvent>? _refreshSub;

  FriendChatMessagesNotifier(int roomId)
    : super(sc.friendChatMessageManager, roomId) {
    _refreshSub = sc.eventBus.on<FriendChatRefreshEvent>().listen(
      _onRefreshEvent,
    );
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    _refreshSub = null;
    super.dispose();
  }

  void _onRefreshEvent(FriendChatRefreshEvent event) {
    switch (event.status) {
      case FriendChatRefreshStatus.refreshing:
        state = state.copyWith(status: ChatMessagesStatus.refreshing);
        break;
      case FriendChatRefreshStatus.success:
        state = state.copyWith(status: ChatMessagesStatus.idle);
        break;
      case FriendChatRefreshStatus.error:
        state = state.copyWith(status: ChatMessagesStatus.refreshError);
        break;
    }
  }
}

/// key: (friendUserId, roomId)
final friendChatMessagesProvider =
    StateNotifierProvider.family<
      FriendChatMessagesNotifier,
      ChatMessagesModel,
      int
    >((ref, roomId) {
      return FriendChatMessagesNotifier(roomId);
    });
