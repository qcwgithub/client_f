import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/pages/user_page.dart';
import 'package:scene_hub/providers/message_provider.dart';

class ChatMessageItem extends StatelessWidget {
  final MessageItem messageItem;
  final bool showTime;
  const ChatMessageItem({
    super.key,
    required this.messageItem,
    required this.showTime,
  });

  void _onClickAvatar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return UserPage(
            userId: messageItem.senderId,
            userName: messageItem.senderName,
            avatarUrl: messageItem.senderAvatarUrl,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Radius radius = Radius.circular(12);
    final timeString = _formatTimestamp(messageItem.timestamp);

    bool isMe = Me.instance!.isMe(messageItem.senderId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(isMe, context, _onClickAvatar),

          // const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    messageItem.senderName ?? "(No name)",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                if (!isMe) const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  // margin: EdgeInsets.only(
                  //   left: isMe ? 50 : 8,
                  //   right: isMe ? 8 : 50,
                  // ),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                    borderRadius: BorderRadius.only(
                      topLeft: radius,
                      topRight: radius,
                      bottomLeft: isMe ? radius : Radius.zero,
                      bottomRight: isMe ? Radius.zero : radius,
                    ),
                  ),
                  child: Text(
                    messageItem.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                if (showTime) const SizedBox(height: 4),

                if (showTime != 0)
                  Text(
                    timeString,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),

          if (isMe) _buildAvatar(isMe, context, _onClickAvatar),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    bool isMe,
    BuildContext context,
    Function(BuildContext) onClick,
  ) {
    return GestureDetector(
      onTap: () => onClick(context),

      child: Container(
        // padding: isMe ? EdgeInsets.only() : EdgeInsets.only(top: 5),
        width: 38,
        height: 38,
        margin: isMe
            ? const EdgeInsets.only(right: 6, left: 6)
            : const EdgeInsets.only(right: 6, left: 6, top: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6), // 圆角方形
          child: Image.network(
            messageItem.senderAvatarUrl ?? "",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(dt);
  }
}
