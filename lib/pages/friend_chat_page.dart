import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/chat_page.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';
import 'package:scene_hub/widgets/friend_chat_message_item.dart';

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
  int get roomId => widget.roomId;

  @override
  String get chatTitle => widget.friendName;

  @override
  ChatMessagesModel watchChatModel() =>
      ref.watch(friendChatMessagesProvider(widget.roomId));

  @override
  void sendChat(
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent,
  ) {
    ref
        .read(friendChatMessagesProvider(widget.roomId).notifier)
        .sendChat(type, content, imageContent);
  }

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
}
