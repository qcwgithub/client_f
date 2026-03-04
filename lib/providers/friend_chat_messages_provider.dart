import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

export 'package:scene_hub/providers/chat_messages_notifier.dart';

class FriendChatMessagesNotifier extends ChatMessagesNotifier {
  FriendChatMessagesNotifier(int roomId)
    : super(sc.friendChatMessageManager, roomId);
}

/// key: (friendUserId, roomId)
final friendChatMessagesProvider =
    StateNotifierProvider.autoDispose.family<
      FriendChatMessagesNotifier,
      ChatMessagesModel,
      int
    >((ref, roomId) {
      return FriendChatMessagesNotifier(roomId);
    });
