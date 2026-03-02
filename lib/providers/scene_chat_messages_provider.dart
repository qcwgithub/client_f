import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/logic/events/scene_chat_refresh_event.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

class SceneChatMessagesNotifier extends ChatMessagesNotifier {
  StreamSubscription<SceneChatRefreshEvent>? _refreshSub;
  SceneChatMessagesNotifier(int roomId)
    : super(sc.sceneChatMessageManager, roomId) {
    _refreshSub = sc.eventBus.on<SceneChatRefreshEvent>().listen(
      _onRefreshEvent,
    );
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    _refreshSub = null;
    super.dispose();
  }

  void _onRefreshEvent(SceneChatRefreshEvent event) {
    switch (event.status) {
      case SceneChatRefreshStatus.refreshing:
        state = state.copyWith(status: ChatMessagesStatus.refreshing);
        break;
      case SceneChatRefreshStatus.success:
        state = state.copyWith(status: ChatMessagesStatus.idle);
        break;
      case SceneChatRefreshStatus.error:
        state = state.copyWith(status: ChatMessagesStatus.refreshError);
        break;
    }
  }
}

final sceneChatMessagesProvider =
    StateNotifierProvider.family<
      SceneChatMessagesNotifier,
      ChatMessagesModel,
      int
    >((ref, roomId) {
      final notifier = SceneChatMessagesNotifier(roomId);
      return notifier;
    });
