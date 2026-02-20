import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';

class MsgSendPrivateChat implements IToMsgPack {
    // [0]
    int friendUserId;
    // [1]
    ChatMessageType chatMessageType;
    // [2]
    String content;
    // [3]
    int clientMessageId;
    // [4]
    ChatMessageImageContent? imageContent;

    MsgSendPrivateChat({
      required this.friendUserId,
      required this.chatMessageType,
      required this.content,
      required this.clientMessageId,
      required this.imageContent,
    });

    @override
    List toMsgPack() {
      return [
        friendUserId,
        chatMessageType.code,
        content,
        clientMessageId,
        imageContent?.toMsgPack(),
      ];
    }

    factory MsgSendPrivateChat.fromMsgPack(List list) {
      return MsgSendPrivateChat(
        friendUserId: list[0] as int,
        chatMessageType: ChatMessageType.fromCode(list[1] as int),
        content: list[2] as String,
        clientMessageId: list[3] as int,
        imageContent: list[4] == null ? null : ChatMessageImageContent.fromMsgPack(list[4] as List),
      );
    }
}