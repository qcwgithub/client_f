import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';
import 'package:scene_hub/sc.dart';
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

class _FriendChatPageState extends ConsumerState<FriendChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  (int, int) get _providerKey => (widget.friendUserId, widget.roomId);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FriendChatMessagesModel model = ref.watch(
      friendChatMessagesProvider(_providerKey),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: Column(
        children: [
          _buildChatList(model),
          ChatInput(
            controller: _inputController,
            callback: (type, content, imageContent) {
              ref
                  .read(friendChatMessagesProvider(_providerKey).notifier)
                  .sendChat(type, content, imageContent);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(FriendChatMessagesModel model) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: model.messages.length,
        itemBuilder: (context, index) {
          int L = model.messages.length;
          int itemIndex = L - 1 - index;
          ClientChatMessage message = model.messages[itemIndex];
          bool showTime = true;

          if (itemIndex < L - 1) {
            var prev = model.messages[itemIndex + 1];
            if (sc.me.isMe(message.senderId) == sc.me.isMe(prev.senderId) &&
                message.timestamp - prev.timestamp < 300000) {
              showTime = false;
            }
          }

          return FriendChatMessageItem(
            key: ValueKey(
              message.useClientId ? message.clientMessageId : message.seq,
            ),
            friendUserId: widget.friendUserId,
            roomId: widget.roomId,
            useClientId: message.useClientId,
            messageId:
                message.useClientId ? message.clientMessageId : message.seq,
            showTime: showTime,
          );
        },
      ),
    );
  }
}
