import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/events/friend_chat_refresh_event.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

export 'package:scene_hub/providers/chat_messages_notifier.dart';

class FriendChatMessagesNotifier extends ChatMessagesNotifier {
  final int friendUserId;
  StreamSubscription<FriendChatRefreshEvent>? _refreshSub;

  FriendChatMessagesNotifier(this.friendUserId, int roomId)
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

  @override
  Future<bool> requestSendChat(ClientChatMessage message) {
    return manager.requestSendChat(message.inner);
  }
}

/// key: (friendUserId, roomId)
final friendChatMessagesProvider =
    StateNotifierProvider.family<
      FriendChatMessagesNotifier,
      ChatMessagesModel,
      (int, int)
    >((ref, params) {
      final (int friendUserId, int roomId) = params;
      return FriendChatMessagesNotifier(friendUserId, roomId);
    });
