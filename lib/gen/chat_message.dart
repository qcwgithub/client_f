import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/chat_message_status.dart';

class ChatMessage implements IToMsgPack {
    // [0]
    int messageId;
    // [1]
    int roomId;
    // [2]
    int senderId;
    // [3]
    String senderName;
    // [4]
    String senderAvatar;
    // [5]
    ChatMessageType type;
    // [6]
    String content;
    // [7]
    int timestamp;
    // [8]
    int replyTo;
    // [9]
    int senderAvatarIndex;
    // [10]
    int clientMessageId;
    // [11]
    ChatMessageStatus status;

    ChatMessage({
      required this.messageId,
      required this.roomId,
      required this.senderId,
      required this.senderName,
      required this.senderAvatar,
      required this.type,
      required this.content,
      required this.timestamp,
      required this.replyTo,
      required this.senderAvatarIndex,
      required this.clientMessageId,
      required this.status,
    });

    @override
    List toMsgPack() {
      return [
        messageId,
        roomId,
        senderId,
        senderName,
        senderAvatar,
        type.code,
        content,
        timestamp,
        replyTo,
        senderAvatarIndex,
        clientMessageId,
        status.code,
      ];
    }

    factory ChatMessage.fromMsgPack(List list) {
      return ChatMessage(
        messageId: list[0] as int,
        roomId: list[1] as int,
        senderId: list[2] as int,
        senderName: list[3] as String,
        senderAvatar: list[4] as String,
        type: ChatMessageType.fromCode(list[5] as int),
        content: list[6] as String,
        timestamp: list[7] as int,
        replyTo: list[8] as int,
        senderAvatarIndex: list[9] as int,
        clientMessageId: list[10] as int,
        status: ChatMessageStatus.fromCode(list[11] as int),
      );
    }
}