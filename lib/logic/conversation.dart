import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/logic/storage/conversation_storage.dart';

class Conversation {
  StorageConversation sconv;
  ChatMessage lastMessage;

  int get unreadCount {
    switch (sconv.type) {
      case ConversationType.friend:
        return lastMessage.seq - sconv.readSeq;
      case ConversationType.scene:
        return 0;
    }
  }

  Conversation({required this.sconv, required this.lastMessage});
}
