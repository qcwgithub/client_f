import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ResGetSceneChatHistory implements IToMsgPack {
    // [0]
    List<ChatMessage> messages;

    ResGetSceneChatHistory({
      required this.messages,
    });

    @override
    List toMsgPack() {
      return [
        messages.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResGetSceneChatHistory.fromMsgPack(List list) {
      return ResGetSceneChatHistory(
        messages: (list[0] as List)
          .map((e) => ChatMessage.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}