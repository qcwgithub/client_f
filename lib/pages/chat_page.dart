import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/providers/conversation_unread_hint_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/chat_input.dart';
import 'package:scene_hub/widgets/chat_unread_hint.dart';

/// Base state class for chat pages. Provides:
/// - ScrollController + TextEditingController management
/// - Scroll listener with 200px pre-load threshold (reverse ListView)
/// - [scrollToBottom], [buildChatList]
abstract class ChatPageState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();

  bool _isNearBottom = true;

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

      _isNearBottom = nearBottom;

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

  /// The roomId used as key for the unread hint provider.
  int get roomId;

  /// The title shown in the AppBar.
  String get chatTitle;

  /// Watch the chat messages model. Called inside [build].
  ChatMessagesModel watchChatModel();

  /// Send a chat message via the appropriate provider.
  void sendChat(
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent,
  );

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

  @override
  Widget build(BuildContext context) {
    final model = watchChatModel();

    if (_isNearBottom) {
      // 在底部，自动滚到最新
      sc.postFrameCallbackManager.registerNoDuplicate(scrollToBottom);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chatTitle),
            if (model.status == ChatMessagesStatus.refreshing)
              buildRefreshing(model.status),
            if (model.status == ChatMessagesStatus.refreshError)
              buildRefreshError(model.status),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              buildChatList(model.messages),
              ChatInput(
                controller: inputController,
                callback: (type, content, imageContent) {
                  sendChat(type, content, imageContent);
                },
              ),
            ],
          ),
          ChatUnreadHint(roomId: roomId, onTap: scrollToBottom),
        ],
      ),
    );
  }
}
