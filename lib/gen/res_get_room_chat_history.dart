import 'package:scene_hub/gen/chat_message.dart';

class ResGetRoomChatHistory {
    // [0]
    List<ChatMessage> history;

    ResGetRoomChatHistory({
      required this.history,
    });

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