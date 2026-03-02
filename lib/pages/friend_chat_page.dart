import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/chat_page.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';
import 'package:scene_hub/widgets/chat_input.dart';
import 'package:scene_hub/widgets/friend_chat_message_item.dart';
import 'package:flutter/material.dart';

class FriendChatPage extends ConsumerStatefulWidget {
  final int friendUserId;
  final String friendName;
  final int friendAvatarIndex;
  final int roomId;

  const FriendChatPage({
    super.key,
    required this.friendUserId,
    required this.friendName,
    required this.friendAvatarIndex,
    required this.roomId,
  });

  @override
  ConsumerState<FriendChatPage> createState() => _FriendChatPageState();
}

class _FriendChatPageState extends ChatPageState<FriendChatPage> {
  @override
  Future<void> onScrollNearTop() async {
    await ref
        .read(friendChatMessagesProvider(widget.roomId).notifier)
        .loadOlderMessages();
  }

  @override
  Future<void> onScrollNearBottom() async {
    await ref
        .read(friendChatMessagesProvider(widget.roomId).notifier)
        .loadNewerMessages();
  }

  @override
  Widget buildMessageItem(ClientChatMessage message, bool showTime) {
    return FriendChatMessageItem(
      key: ValueKey(message.useClientSeq ? message.clientSeq : message.seq),
      friendUserId: widget.friendUserId,
      roomId: widget.roomId,
      useClientSeq: message.useClientSeq,
      seq: message.useClientSeq ? message.clientSeq : message.seq,
      showTime: showTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatMessagesModel model = ref.watch(
      friendChatMessagesProvider(widget.roomId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.friendName),
            if (model.status == ChatMessagesStatus.refreshing)
              buildRefreshing(model.status),
            if (model.status == ChatMessagesStatus.refreshError)
              buildRefreshError(model.status),
          ],
        ),
      ),
      body: Column(
        children: [
          buildChatList(model.messages),
          ChatInput(
            controller: inputController,
            callback: (type, content, imageContent) {
              ref
                  .read(friendChatMessagesProvider(widget.roomId).notifier)
                  .sendChat(type, content, imageContent);
            },
          ),
        ],
      ),
    );
  }
}
