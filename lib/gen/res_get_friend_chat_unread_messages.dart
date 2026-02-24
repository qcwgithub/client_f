import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message.dart';

class ResGetFriendChatUnreadMessages implements IToMsgPack {
    // [0]
    List<ChatMessage> messages;
    // [1]
    bool hasMore;

    ResGetFriendChatUnreadMessages({
      required this.messages,
      required this.hasMore,
    });

    @override
    List toMsgPack() {
      return [
        messages.map((e) => e.toMsgPack()).toList(growable: false),
        hasMore,
      ];
    }

    factory ResGetFriendChatUnreadMessages.fromMsgPack(List list) {
      return ResGetFriendChatUnreadMessages(
        messages: (list[0] as List)
          .map((e) => ChatMessage.fromMsgPack(e as List))
          .toList(growable: true),
        hasMore: list[1] as bool,
      );
    }
}