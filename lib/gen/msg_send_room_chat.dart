import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/room_type.dart';

class MsgSendRoomChat implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    ChatMessageType chatMessageType;
    // [2]
    String content;
    // [3]
    int clientMessageId;
    // [4]
    ChatMessageImageContent? imageContent;
    // [5]
    RoomType roomType;

    MsgSendRoomChat({
      required this.roomId,
      required this.chatMessageType,
      required this.content,
      required this.clientMessageId,
      required this.imageContent,
      required this.roomType,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        chatMessageType.code,
        content,
        clientMessageId,
        imageContent?.toMsgPack(),
        roomType.code,
      ];
    }

    factory MsgSendRoomChat.fromMsgPack(List list) {
      return MsgSendRoomChat(
        roomId: list[0] as int,
        chatMessageType: ChatMessageType.fromCode(list[1] as int),
        content: list[2] as String,
        clientMessageId: list[3] as int,
        imageContent: list[4] == null ? null : ChatMessageImageContent.fromMsgPack(list[4] as List),
        roomType: RoomType.fromCode(list[5] as int),
      );
    }
}