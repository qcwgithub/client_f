import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class MsgAChatMessage implements IToMsgPack {
    // [0]
    ChatMessage message;

    MsgAChatMessage({
      required this.message,
    });

    @override
    List toMsgPack() {
      return [
        message.toMsgPack(),
      ];
    }

    factory MsgAChatMessage.fromMsgPack(List list) {
      return MsgAChatMessage(
        message: ChatMessage.fromMsgPack(list[0] as List),
      );
    }
}