import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/pages/friend_chat_page.dart';
import 'package:scene_hub/providers/conversation_list_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/conversation_page_item.dart';

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  void _onTap(BuildContext context, Conversation conversation) {
    final friendInfo = sc.friendManager.getFriendByRoomId(conversation.roomId);
    if (friendInfo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FriendChatPage(
            friendUserId: friendInfo.userId,
            friendName: "",
            friendAvatarIndex: 0,
            roomId: conversation.roomId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(conversationListProvider);
    final conversations = model.conversations;

    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: conversations.isEmpty
          ? const Center(
              child: Text('暂无会话', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationPageItem(
                  key: ValueKey(conversation.roomId),
                  roomId: conversation.roomId,
                  onTap: () => _onTap(context, conversation),
                  onDelete: () {
                    ref
                        .read(conversationListProvider.notifier)
                        .delete(conversation.roomId);
                  },
                );
              },
            ),
    );
  }
}
