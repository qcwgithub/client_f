import 'package:scene_hub/gen/chat_message.dart';

class Conversation {
  int roomId;
  ChatMessage lastMessage;
  int readSeq;
  int get unreadCount {
    return lastMessage.seq - readSeq;
  }

  Conversation({
    required this.roomId,
    required this.lastMessage,
    required this.readSeq,
  });
}
