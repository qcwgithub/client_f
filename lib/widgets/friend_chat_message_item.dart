import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/friend_chat_message_provider.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/chat_message_item.dart';

class FriendChatMessageItem extends ChatMessageItemBase {
  final int friendUserId;
  final int roomId;
  final bool useClientSeq;
  final int seq;

  const FriendChatMessageItem({
    super.key,
    required this.friendUserId,
    required this.roomId,
    required this.useClientSeq,
    required this.seq,
    required super.showTime,
  });

  @override
  ClientChatMessage watchMessage(WidgetRef ref) {
    return ref.watch(
      friendChatMessageProvider((roomId, useClientSeq, seq)),
    );
  }

  @override
  void onMessageViewed(ClientChatMessage message) {
    sc.friendChatMessageManager.onMessageViewed(
      roomId,
      message.inner.seq,
    );
  }

  @override
  void onResendChat(WidgetRef ref, int clientSeq) {
    ref
        .read(friendChatMessagesProvider(roomId).notifier)
        .resendChat(clientSeq);
  }
}
