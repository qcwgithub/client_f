import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class MsgARoomChat implements IToMsgPack {
    // [0]
    ChatMessage message;

    MsgARoomChat({
      required this.message,
    });

    @override
    List toMsgPack() {
      return [
        message.toMsgPack(),
      ];
    }

    factory MsgARoomChat.fromMsgPack(List list) {
      return MsgARoomChat(
        message: ChatMessage.fromMsgPack(list[0] as List),
      );
    }
}