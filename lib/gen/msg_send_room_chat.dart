import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message_type.dart';

class MsgSendRoomChat implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    ChatMessageType chatMessageType;
    // [2]
    String content;
    // [3]
    int clientMessageId;

    MsgSendRoomChat({
      required this.roomId,
      required this.chatMessageType,
      required this.content,
      required this.clientMessageId,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        chatMessageType.code,
        content,
        clientMessageId,
      ];
    }

    factory MsgSendRoomChat.fromMsgPack(List list) {
      return MsgSendRoomChat(
        roomId: list[0] as int,
        chatMessageType: ChatMessageType.fromCode(list[1] as int),
        content: list[2] as String,
        clientMessageId: list[3] as int,
      );
    }
}