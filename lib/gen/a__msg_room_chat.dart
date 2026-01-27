import 'package:scene_hub/gen/chat_message_type.dart';

class A_MsgRoomChat {
    // [0]
    int roomId;
    // [1]
    int userId;
    // [2]
    ChatMessageType chatMessageType;
    // [3]
    String content;

    A_MsgRoomChat({
      required this.roomId,
      required this.userId,
      required this.chatMessageType,
      required this.content,
    });

    List toMsgPack() {
      return [
        roomId,
        userId,
        chatMessageType,
        content,
      ];
    }

    factory A_MsgRoomChat.fromMsgPack(List list) {
      return A_MsgRoomChat(
        roomId: list[0] as int,
        userId: list[1] as int,
        chatMessageType: ChatMessageType.fromCode(list[2] as int),
        content: list[3] as String,
      );
    }
}