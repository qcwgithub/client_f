import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

/// Base state class for chat pages. Provides:
/// - ScrollController + TextEditingController management
/// - Scroll listener with 200px pre-load threshold (reverse ListView)
/// - [scrollToBottom], [buildChatList]
abstract class ChatPageState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    sc.postFrameCallbackManager.registerNoDuplicate(scrollToBottom);

    scrollController.addListener(() async {
      final pos = scrollController.position;
      const threshold = 200.0;

      // reverse: true → pixels 越大越靠近旧消息（顶部）
      bool nearTop = pos.pixels >= pos.maxScrollExtent - threshold;
      bool nearBottom = pos.pixels <= pos.minScrollExtent + threshold;

      if (nearTop) {
        await onScrollNearTop();
      } else if (nearBottom) {
        await onScrollNearBottom();
      }
    });
  }

  /// Load older messages when scrolling near top. Must override.
  Future<void> onScrollNearTop();

  /// Load newer messages when scrolling near bottom. Default: no-op.
  Future<void> onScrollNearBottom() async {}

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    inputController.dispose();
    super.dispose();
  }

  Widget buildRefreshing(ChatMessagesStatus status) {
    return const Text(
      '同步中...',
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    );
  }

  Widget buildRefreshError(ChatMessagesStatus status) {
    return const Text(
      '同步失败',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.red,
      ),
    );
  }

  /// Build the item widget for a given message. Must override.
  Widget buildMessageItem(ClientChatMessage message, bool showTime);

  /// Build the chat list with shared showTime logic.
  Widget buildChatList(List<ClientChatMessage> messages) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          int L = messages.length;
          int itemIndex = L - 1 - index;
          ClientChatMessage message = messages[itemIndex];
          bool showTime = true;

          if (itemIndex < L - 1) {
            var prev = messages[itemIndex + 1];
            if (sc.me.isMe(message.senderId) == sc.me.isMe(prev.senderId) &&
                message.timestamp - prev.timestamp < 300000) {
              showTime = false;
            }
          }

          return buildMessageItem(message, showTime);
        },
      ),
    );
  }
}
