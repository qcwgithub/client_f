import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/msg_leave_scene.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/scene_room_info.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/pages/chat_page.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/providers/scene_chat_messages_provider.dart';
import 'package:scene_hub/sc.dart';
import 'package:scene_hub/widgets/scene_chat_message_item.dart';

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
  String get chatTitle => widget.roomInfo.title;

  @override
  ChatMessagesModel watchChatModel() =>
      ref.watch(sceneChatMessagesProvider(widget.roomId));

  @override
  void sendChat(
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent,
  ) {
    ref
        .read(sceneChatMessagesProvider(widget.roomId).notifier)
        .sendChat(type, content, imageContent);
  }

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
  void dispose() {
    // TODO retry!
    sc.server.request(MsgType.leaveScene, MsgLeaveScene(roomId: widget.roomId));
    super.dispose();
  }
}
