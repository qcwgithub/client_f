import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/logic/storage/conversation_storage.dart';
import 'package:scene_hub/pages/friend_chat_page.dart';
import 'package:scene_hub/pages/scene_chat_page.dart';
import 'package:scene_hub/providers/conversation_list_provider.dart';
import 'package:scene_hub/providers/enter_scene_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/conversation_page_item.dart';
import 'package:scene_hub/widgets/scene_card.dart';

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    Conversation conv,
  ) async {
    switch (conv.sconv.type) {
      case ConversationType.friend:
        {
          final friendInfo = sc.friendManager.getFriendByRoomId(
            conv.sconv.roomId,
          );
          if (friendInfo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendChatPage(
                  friendUserId: friendInfo.userId,
                  friendName: "",
                  friendAvatarIndex: 0,
                  roomId: conv.sconv.roomId,
                ),
              ),
            );
          }
        }
        break;
      case ConversationType.scene:
        {
          await SceneCard.s_enterScene(context, ref, conv.sconv.roomId);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(conversationListProvider);
    List<Conversation> conversations = model.conversations;

    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: conversations.isEmpty
          ? const Center(
              child: Text('暂无会话', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return ConversationPageItem(
                  key: ValueKey(conv.sconv.roomId),
                  type: conv.sconv.type,
                  roomId: conv.sconv.roomId,
                  onTap: () => _onTap(context, ref, conv),
                  onDelete: () {
                    ref
                        .read(conversationListProvider.notifier)
                        .delete(conv.sconv.roomId);
                  },
                );
              },
            ),
    );
  }
}
