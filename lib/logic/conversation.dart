import 'package:scene_hub/gen/chat_message.dart';

class Conversation {
  int roomId;
  ChatMessage lastMessage;

  // 这个记提当前内存里最大值，有别于 friendInfo.readSeq 和 StorageConversation.readSeq
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
