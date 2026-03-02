import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/msg_leave_scene.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/scene_room_info.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/chat_page.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/providers/scene_chat_messages_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/chat_input.dart';
import 'package:scene_hub/widgets/scene_chat_message_item.dart';
import 'package:flutter/material.dart';

class SceneChatPage extends ConsumerStatefulWidget {
  final SceneRoomInfo roomInfo;
  int get roomId => roomInfo.roomId;

  const SceneChatPage({super.key, required this.roomInfo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends ChatPageState<SceneChatPage> {
  @override
  Future<void> onScrollNearTop() async {
    await ref
        .read(sceneChatMessagesProvider(widget.roomId).notifier)
        .loadOlderMessages();
  }

  @override
  Future<void> onScrollNearBottom() async {
    await ref
        .read(sceneChatMessagesProvider(widget.roomId).notifier)
        .loadNewerMessages();
  }

  @override
  Widget buildMessageItem(ClientChatMessage message, bool showTime) {
    return SceneChatMessageItem(
      key: ValueKey(message.useClientSeq ? message.clientSeq : message.seq),
      roomId: widget.roomId,
      useClientId: message.useClientSeq,
      seq: message.useClientSeq ? message.clientSeq : message.seq,
      showTime: showTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatMessagesModel model = ref.watch(
      sceneChatMessagesProvider(widget.roomId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomInfo.title),
            if (model.status == ChatMessagesStatus.refreshing)
              buildRefreshing(model.status),
            if (model.status == ChatMessagesStatus.refreshError)
              buildRefreshError(model.status),
          ],
        ),
      ),
      body: Column(
        children: [
          buildChatList(model.messages),
          ChatInput(
            controller: inputController,
            callback: (type, content, imageContent) {
              ref
                  .read(sceneChatMessagesProvider(widget.roomId).notifier)
                  .sendChat(type, content, imageContent);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO retry!
    sc.server.request(MsgType.leaveScene, MsgLeaveScene(roomId: widget.roomId));
    super.dispose();
  }
}
