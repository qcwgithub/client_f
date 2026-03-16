import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';

class MsgSendSceneChat implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    ChatMessageType chatMessageType;
    // [2]
    String content;
    // [3]
    int clientSeq;
    // [4]
    ChatMessageImageContent? imageContent;

    MsgSendSceneChat({
      required this.roomId,
      required this.chatMessageType,
      required this.content,
      required this.clientSeq,
      required this.imageContent,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        chatMessageType.code,
        content,
        clientSeq,
        imageContent?.toMsgPack(),
      ];
    }

    factory MsgSendSceneChat.fromMsgPack(List list) {
      return MsgSendSceneChat(
        roomId: list[0] as int,
        chatMessageType: ChatMessageType.fromCode(list[1] as int),
        content: list[2] as String,
        clientSeq: list[3] as int,
        imageContent: list[4] == null ? null : ChatMessageImageContent.fromMsgPack(list[4] as List),
      );
    }
}