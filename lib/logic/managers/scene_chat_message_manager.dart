import 'dart:async';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/msg_get_scene_chat_history.dart';
import 'package:scene_hub/gen/msg_send_scene_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_scene_chat_history.dart';
import 'package:scene_hub/gen/res_send_scene_chat.dart';
import 'package:scene_hub/logic/managers/chat_message_manager.dart';
import 'package:scene_hub/sc.dart';

class SceneChatMessageManager extends ChatMessageManager {
  void init() {}

  final Map<int, List<ChatMessage>> _sceneMessages = {};
  void onEnterSceneSuccess(int roomId, List<ChatMessage> recentMessages) {
    _sceneMessages[roomId] = recentMessages;
  }

  @override
  Future<void> initialLoadMessages(int roomId, int count) async {
    List<ChatMessage>? messages = _sceneMessages[roomId];
    if (messages == null) {
      return;
    }

    List<ChatMessage> result = messages.sublist(
      messages.length > count ? messages.length - count : 0,
    );
    controllerAdd(result);
  }

  @override
  Future<void> unloadMessages(int roomId) async {}

  @override
  Future<void> loadOlderMessages(int roomId, int beforeSeq, int count) async {
    final r = await sc.server.request(
      MsgType.getSceneChatHistory,
      MsgGetSceneChatHistory(
        roomId: roomId,
        beforeSeq: beforeSeq,
        count: count,
      ),
    );

    if (r.e == ECode.success) {
      final res = ResGetSceneChatHistory.fromMsgPack(r.res as List);
      controllerAdd(res.messages);
    }
  }

  @override
  Future<void> loadNewerMessages(int roomId, int afterSeq, int count) async {
    // Nothing todo
  }

  @override
  Future<bool> requestSendChat(ChatMessage message) async {
    final r = await sc.server.request(
      MsgType.sendSceneChat,
      MsgSendSceneChat(
        roomId: message.roomId,
        chatMessageType: message.type,
        content: message.content,
        clientSeq: message.clientSeq,
        imageContent: message.imageContent,
      ),
    );

    if (r.e == ECode.success) {
      final res = ResSendSceneChat.fromMsgPack(r.res as List);
      controllerAdd([res.message]);
      return true;
    }

    return false;
  }

  void onMsgAChatMessage(MsgAChatMessage msg) async {
    ChatMessage message = msg.message;
    controllerAdd([message]);
  }
}
