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

    _scrollController.addListener(() async {
      bool isTop =
          _scrollController.position.atEdge &&
          _scrollController.position.pixels != 0;

      if (isTop) {
        // print("isTop!");
        // double beforePixels = _scrollController.position.pixels;
        // double beforeExtent = 0;
        await ref
            .read(friendChatMessagesProvider(_providerKey).notifier)
            .loadOlderMessages();

        // if (loaded) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     double afterExtent = _scrollController.position.maxScrollExtent;
        //     double diff = afterExtent - beforeExtent;
        //     _scrollController.jumpTo(beforePixels + diff);
        //     print(
        //       "extent ${beforeExtent} -> ${afterExtent} jumpTo ${beforePixels + diff}",
        //     );
        //   });
        // }
      } else {
        bool isBottom =
            _scrollController.position.atEdge &&
            _scrollController.position.pixels == 0;

        if (isBottom) {
          await ref
              .read(friendChatMessagesProvider(_providerKey).notifier)
              .loadNewerMessages();
        }
      }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.friendName),
            if (model.status == FriendChatMessagesStatus.refreshing)
              const Text(
                '同步中...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            if (model.status == FriendChatMessagesStatus.refreshError)
              const Text(
                '同步失败',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
              ),
          ],
        ),
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
              message.useClientSeq ? message.clientSeq : message.seq,
            ),
            friendUserId: widget.friendUserId,
            roomId: widget.roomId,
            useClientSeq: message.useClientSeq,
            seq: message.useClientSeq ? message.clientSeq : message.seq,
            showTime: showTime,
          );
        },
      ),
    );
  }
}
