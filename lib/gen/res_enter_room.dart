import 'package:scene_hub/gen/chat_message.dart';

class ResEnterRoom {
    // [0]
    List<ChatMessage> recentMessages;

    ResEnterRoom({
      required this.recentMessages,
    });

    List toMsgPack() {
      return [
        recentMessages.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResEnterRoom.fromMsgPack(List list) {
      return ResEnterRoom(
        recentMessages: (list[0] as List)
          .map((e) => ChatMessage.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}