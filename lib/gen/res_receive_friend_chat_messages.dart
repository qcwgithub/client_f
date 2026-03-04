import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/chat_message_list.dart';

class ResReceiveFriendChatMessages implements IToMsgPack {
    // [0]
    Map<int, ChatMessageList> messageListDict;
    // [1]
    bool hasMore;

    ResReceiveFriendChatMessages({
      required this.messageListDict,
      required this.hasMore,
    });

    @override
    List toMsgPack() {
      return [
        messageListDict.map((k, v) => MapEntry(k, v.toMsgPack())),
        hasMore,
      ];
    }

    factory ResReceiveFriendChatMessages.fromMsgPack(List list) {
      return ResReceiveFriendChatMessages(
        messageListDict: (list[0] as Map)
          .map((k, v) => MapEntry(k as int, ChatMessageList.fromMsgPack(v as List))),
        hasMore: list[1] as bool,
      );
    }
}