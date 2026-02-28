import 'package:flutter/material.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/pages/avatar_pick_page.dart';
import 'package:scene_hub/pages/friend_chat_page.dart';
import 'package:scene_hub/sc.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  List<Conversation> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    sc.conversationManager.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    sc.conversationManager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {
      _conversations = sc.conversationManager.getAll();
    });
  }

  void _load() {
    final list = sc.conversationManager.getAll();
    if (!mounted) return;
    setState(() {
      _conversations = list;
      _loading = false;
    });
  }

  String _formatTime(int timestampMs) {
    if (timestampMs == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dt.year, dt.month, dt.day);

    if (messageDay == today) {
      // 今天：显示时:分
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else if (now.difference(dt).inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dt.weekday - 1];
    } else {
      return '${dt.month}/${dt.day}';
    }
  }

  void _onTap(Conversation conversation) async {
    if (conversation.type == 0) {
      // 好友聊天
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FriendChatPage(
            friendUserId: conversation.targetUserId,
            friendName: conversation.title,
            friendAvatarIndex: conversation.avatarIndex,
            roomId: conversation.roomId,
          ),
        ),
      );
    }
  }

  void _onDelete(Conversation conversation) {
    sc.conversationManager.delete(conversation.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? const Center(
              child: Text('暂无会话', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                return _buildItem(_conversations[index]);
              },
            ),
    );
  }

  Widget _buildItem(Conversation conversation) {
    final color = avatarColorFor(conversation.avatarIndex);
    final initial = conversation.title.isNotEmpty
        ? conversation.title[0].toUpperCase()
        : '?';

    return Dismissible(
      key: ValueKey(conversation.roomId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _onDelete(conversation),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(
              _formatTime(conversation.lastMessageTime),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount > 99
                      ? '99+'
                      : '${conversation.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
          ],
        ),
        onTap: () => _onTap(conversation),
      ),
    );
  }
}
