import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/user_page.dart';
import 'package:scene_hub/providers/room_message_list_provider.dart';
import 'package:scene_hub/providers/room_message_provider.dart';
import 'package:scene_hub/sc.dart';

class RoomChatMessageItem extends ConsumerWidget {
  final int roomId;
  final bool useClientId;
  final int messageId;
  final bool showTime;
  const RoomChatMessageItem({
    super.key,
    required this.roomId,
    required this.useClientId,
    required this.messageId,
    required this.showTime,
  });

  void _onClickAvatar(BuildContext context, ClientChatMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return UserPage(
            userId: message.senderId,
            userName: message.senderName,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ClientChatMessage message = ref.watch(
      roomMessageProvider((roomId, useClientId, messageId)),
    );
    bool isMe = sc.me.isMe(message.senderId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(isMe, context, message, _onClickAvatar),

          // const SizedBox(width: 8),
          _buildMessageBubble(context, message, isMe),

          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 6),
              child: SizedBox(
                width: 16,
                height: 16,
                child: _buildClientStatus(
                  message,
                  () => ref
                      .read(roomMessageListProvider(roomId).notifier)
                      .resendChat(message),
                ),
              ),
            ),

          if (isMe) _buildAvatar(isMe, context, message, _onClickAvatar),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ClientChatMessage message,
    isMe,
  ) {
    final timeString = _formatTimestamp(message.timestamp);

    return Flexible(
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,

        children: [
          if (!isMe)
            Text(
              message.senderName,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

          if (!isMe) const SizedBox(height: 4),

          if (message.type == ChatMessageType.text)
            _buildTextBubble(context, message, isMe),

          // if (messageItem.type == "image") _buildImageBubble(context, isMe),
          if (showTime) const SizedBox(height: 4),

          if (showTime)
            Text(
              timeString,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(
    BuildContext context,
    ClientChatMessage message,
    bool isMe,
  ) {
    final Radius radius = Radius.circular(12);
    return GestureDetector(
      onLongPressStart: (details) {
        _showMessageMenu(context, message, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
          message.content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  // Widget _buildImageBubble(BuildContext context, bool isMe) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (_) {
  //             return FullscreenImagePage(imageUrl: messageItem.imageUrl!);
  //           },
  //         ),
  //       );
  //     },

  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12),
  //       child: Image.network(
  //         messageItem.imageUrl!,
  //         width: 180,
  //         height: 180,
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

  void _showMessageMenu(
    BuildContext context,
    ClientChatMessage message,
    Offset position,
  ) async {
    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: "copy", child: Text("Copy")),
        const PopupMenuItem(value: "reply", child: Text("Reply")),
      ],
    );

    if (selected == null) {
      return;
    }

    switch (selected) {
      case "copy":
        if (context.mounted) {
          if (message.type == ChatMessageType.text) {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Copied!")));
          }
        }
        break;

      case "reply":
        print("todo: reply");
        break;
    }
  }

  Widget _buildClientStatus(ClientChatMessage message, VoidCallback resend) {
    switch (message.clientStatus) {
      case ClientChatMessageStatus.normal:
        return const Icon(Icons.check, color: Colors.green, size: 16);

      case ClientChatMessageStatus.sending:
        return CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );

      case ClientChatMessageStatus.failed:
        return GestureDetector(
          onTap: resend,
          child: const Icon(Icons.error, color: Colors.red, size: 16),
        );
    }
  }

  Widget _buildAvatar(
    bool isMe,
    BuildContext context,
    ClientChatMessage message,
    Function(BuildContext, ClientChatMessage) onClick,
  ) {
    return GestureDetector(
      onTap: () => onClick(context, message),

      child: Container(
        // padding: isMe ? EdgeInsets.only() : EdgeInsets.only(top: 5),
        width: 38,
        height: 38,
        margin: isMe
            ? const EdgeInsets.only(right: 6, left: 6)
            : const EdgeInsets.only(right: 6, left: 6, top: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6), // 圆角方形
          // child: Image.network(
          //   messageItem.senderAvatarUrl ?? "",
          //   fit: BoxFit.cover,
          // ),
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(dt);
  }
}
