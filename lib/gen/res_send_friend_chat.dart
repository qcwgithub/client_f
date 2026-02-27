import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ResSendFriendChat implements IToMsgPack {
    // [0]
    ChatMessage message;

    ResSendFriendChat({
      required this.message,
    });

    @override
    List toMsgPack() {
      return [
        message.toMsgPack(),
      ];
    }

    factory ResSendFriendChat.fromMsgPack(List list) {
      return ResSendFriendChat(
        message: ChatMessage.fromMsgPack(list[0] as List),
      );
    }
}