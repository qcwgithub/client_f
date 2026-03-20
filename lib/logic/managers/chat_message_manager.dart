import 'dart:async';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/user_info.dart';
import 'package:scene_hub/logic/event.dart';
import 'package:scene_hub/logic/events/chat_rfresh_status.dart';
import 'package:scene_hub/sc.dart';

abstract class ChatMessageManager {
  UserInfo get userInfo => sc.me.userInfo;

  final Event1<ChatRefreshStatus> chatRefreshStatusChanged = Event1();
  final Event1<List<ChatMessage>> messagesAdded = Event1();
  final Event1<int> messagesCleared = Event1<int>();

  void addMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    for (int i = 0; i < messages.length - 1; i++) {
      if (messages[i].seq == 0) {
        sc.logger.e("消息 seq 不能为 0！message ${messages[i]}");
      }
      if (messages[i].seq >= messages[i + 1].seq) {
        sc.logger.d("消息 seq 不递增！${messages[i].seq} >= ${messages[i + 1].seq}");
      }
    }
    sc.logger.d(
      "addMessages seq range [${messages.first.seq}, ${messages.last.seq}]",
    );
    messagesAdded.emit(messages);
  }

  Future<List<ChatMessage>> initialLoadMessages(int roomId, int count);
  Future<void> unloadMessages(int roomId);
  Future<void> loadOlderMessages(int roomId, int beforeSeq, int count);
  Future<void> loadNewerMessages(int roomId, int afterSeq, int count);
  Future<bool> requestSendChat(ChatMessage message);
}
