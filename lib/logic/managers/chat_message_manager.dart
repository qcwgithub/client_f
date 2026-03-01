import 'dart:async';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/sc.dart';

abstract class ChatMessageManager {
  final _controller = StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get stream => _controller.stream;

  void controllerAdd(List<ChatMessage> messages) {
    for (int i = 0; i < messages.length - 1; i++) {
      if (messages[i].seq >= messages[i + 1].seq) {
        sc.logger.d("消息 seq 不递增！${messages[i].seq} >= ${messages[i + 1].seq}");
      }
    }
    _controller.add(messages);
  }

  Future<void> initialLoad(int roomId, int count);
  Future<void> loadOlderMessages(int roomId, int beforeSeq, int count);
  Future<void> loadNewerMessages(int roomId, int afterSeq, int count);
  Future<bool> requestSendChat(ChatMessage message, int friendUserId);
}
