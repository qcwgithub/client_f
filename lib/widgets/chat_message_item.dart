import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessageItem extends StatelessWidget {
  final String text;
  final bool isMe;
  final String userName;
  final String avatarUrl;
  final int timeS; // 0 == not show
  const ChatMessageItem({
    super.key,
    required this.text,
    required this.isMe,
    required this.userName,
    required this.avatarUrl,
    required this.timeS,
  });

  @override
  Widget build(BuildContext context) {
    final Radius radius = Radius.circular(12);
    final timeString = _formatTimestamp(timeS);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),

          // const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    userName,
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
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                if (timeS != 0) const SizedBox(height: 4),
                if (timeS != 0)
                  Text(
                    timeString,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),

          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      // padding: isMe ? EdgeInsets.only() : EdgeInsets.only(top: 5),
      width: 38,
      height: 38,
      margin: isMe
          ? const EdgeInsets.only(right: 6, left: 6)
          : const EdgeInsets.only(right: 6, left: 6, top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6), // 圆角方形
        child: Image.network(avatarUrl, fit: BoxFit.cover),
      ),
    );
  }

  String _formatTimestamp(int timeS) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timeS * 1000);
    return DateFormat('HH:mm').format(dt);
  }
}
