import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ResSendSceneChat implements IToMsgPack {
    // [0]
    ChatMessage message;

    ResSendSceneChat({
      required this.message,
    });

    @override
    List toMsgPack() {
      return [
        message.toMsgPack(),
      ];
    }

    factory ResSendSceneChat.fromMsgPack(List list) {
      return ResSendSceneChat(
        message: ChatMessage.fromMsgPack(list[0] as List),
      );
    }
}