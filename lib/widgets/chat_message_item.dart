import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/fullscreen_image_page.dart';
import 'package:scene_hub/pages/user_info_page.dart';
import 'package:scene_hub/sc.dart';

abstract class ChatMessageItemBase extends ConsumerWidget {
  final bool showTime;

  const ChatMessageItemBase({super.key, required this.showTime});

  /// Watch the appropriate message provider and return the message.
  ClientChatMessage watchMessage(WidgetRef ref);

  /// Called when a server message is viewed. Default: no-op.
  void onMessageViewed(ClientChatMessage message) {}

  /// Resend a failed message via the appropriate provider.
  void onResendChat(WidgetRef ref, int clientSeq);

  /// Called when an avatar is tapped. Default: navigate to UserInfoPage.
  void onClickAvatar(BuildContext context, ClientChatMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserInfoPage(
          userId: message.senderId,
          userName: message.senderName,
          senderAvatarIndex: message.senderAvatarIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ClientChatMessage message = watchMessage(ref);
    bool isMe = sc.me.isMe(message.senderId);
    if (!message.useClientSeq) {
      onMessageViewed(message);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(isMe, context, message),

          _buildMessageBubble(context, message, isMe),

          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 6),
              child: SizedBox(
                width: 16,
                height: 16,
                child: _buildClientStatus(
                  message,
                  () => onResendChat(ref, message.clientSeq),
                ),
              ),
            ),

          if (isMe) _buildAvatar(isMe, context, message),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ClientChatMessage message,
    bool isMe,
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
        showMessageMenu(context, message, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
          "[${message.seq}] ${message.content}",
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildImageBubble(
    BuildContext context,
    ClientChatMessage message,
    bool isMe,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                FullscreenImagePage(imageUrl: message.inner.imageContent!.url),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 180,
          height: 180,
          child: CachedNetworkImage(
            imageUrl: message.inner.imageContent!.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            ),
          ),
        ),
      ),
    );
  }

  /// Override to customize menu items.
  void showMessageMenu(
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
      items: [const PopupMenuItem(value: "copy", child: Text("Copy"))],
    );

    if (selected == null) return;

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
  ) {
    return GestureDetector(
      onTap: () => onClickAvatar(context, message),
      child: Container(
        width: 38,
        height: 38,
        margin: isMe
            ? const EdgeInsets.only(right: 6, left: 6)
            : const EdgeInsets.only(right: 6, left: 6, top: 12),
        decoration: BoxDecoration(
          color: Colors.indigo.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          message.senderName.isNotEmpty
              ? message.senderName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade700,
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
