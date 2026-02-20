import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ResEnterScene implements IToMsgPack {
    // [0]
    List<ChatMessage> recentMessages;

    ResEnterScene({
      required this.recentMessages,
    });

    @override
    List toMsgPack() {
      return [
        recentMessages.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResEnterScene.fromMsgPack(List list) {
      return ResEnterScene(
        recentMessages: (list[0] as List)
          .map((e) => ChatMessage.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}