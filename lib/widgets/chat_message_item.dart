import 'package:flutter/material.dart';

class ChatMessageItem extends StatelessWidget {
  final String text;
  final bool isMe;
  final String avatarUrl;
  const ChatMessageItem({
    super.key,
    required this.text,
    required this.isMe,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final Radius radius = Radius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.only(
                left: isMe ? 50 : 8,
                right: isMe ? 8 : 50,
              ),
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
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
            ),
          ),

          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 38,
      height: 38,
      margin: const EdgeInsets.only(right: 6, left: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6), // 圆角方形
        child: Image.network(avatarUrl, fit: BoxFit.cover),
      ),
    );
  }
}
