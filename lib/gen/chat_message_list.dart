import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ChatMessageList implements IToMsgPack {
    // [0]
    List<ChatMessage> list;

    ChatMessageList({
      required this.list,
    });

    @override
    List toMsgPack() {
      return [
        list.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ChatMessageList.fromMsgPack(List list) {
      return ChatMessageList(
        list: (list[0] as List)
          .map((e) => ChatMessage.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}