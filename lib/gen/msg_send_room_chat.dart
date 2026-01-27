import 'package:scene_hub/gen/chat_message_type.dart';

class MsgSendRoomChat {
    // [0]
    int roomId;
    // [1]
    ChatMessageType chatMessageType;
    // [2]
    String content;

    MsgSendRoomChat({
      required this.roomId,
      required this.chatMessageType,
      required this.content,
    });

    List toMsgPack() {
      return [
        roomId,
        chatMessageType,
        content,
      ];
    }

    factory MsgSendRoomChat.fromMsgPack(List list) {
      return MsgSendRoomChat(
        roomId: list[0] as int,
        chatMessageType: ChatMessageType.fromCode(list[1] as int),
        content: list[2] as String,
      );
    }
}