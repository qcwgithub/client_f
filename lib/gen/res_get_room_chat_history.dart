import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ResGetRoomChatHistory implements IToMsgPack {
    // [0]
    List<ChatMessage> history;

    ResGetRoomChatHistory({
      required this.history,
    });

    @override
    List toMsgPack() {
      return [
        history.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResGetRoomChatHistory.fromMsgPack(List list) {
      return ResGetRoomChatHistory(
        history: (list[0] as List)
          .map((e) => ChatMessage.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}