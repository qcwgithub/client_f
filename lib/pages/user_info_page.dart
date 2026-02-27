import 'package:flutter/material.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_send_friend_request.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/pages/friend_chat_page.dart';
import 'package:scene_hub/sc.dart';

class UserInfoPage extends StatelessWidget {
  final int userId;
  final String? userName;
  final int senderAvatarIndex;
  const UserInfoPage({
    super.key,
    required this.userId,
    this.userName,
    required this.senderAvatarIndex,
  });

  bool get _isMe => sc.me.isMe(userId);
  bool get _isFriend => sc.me.isFriend(userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Info")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 头像
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  (userName != null && userName!.isNotEmpty)
                      ? userName![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 名字
              Text(
                userName ?? '(No name)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              // ID
              Text(
                'ID: $userId',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // 操作按钮区域
              if (!_isMe) _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (_isFriend) {
      // 好友 → 发消息
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            final friend = sc.me.userInfo.friends.firstWhere(
              (f) => f.userId == userId,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendChatPage(
                  friendUserId: userId,
                  friendName: userName ?? '',
                  friendAvatarIndex: senderAvatarIndex,
                  roomId: friend.roomId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Send Message'),
        ),
      );
    } else {
      // 非好友 → 加好友
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _sendFriendRequest(context),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add Friend'),
        ),
      );
    }
  }

  void _sendFriendRequest(BuildContext context) async {
    final res = await sc.server.request(
      MsgType.sendFriendRequest,
      MsgSendFriendRequest(toUserId: userId, say: ''),
    );

    if (!context.mounted) return;

    if (res.e == ECode.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.e}')),
      );
    }
  }
}
