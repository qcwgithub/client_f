import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetFriendChatUnreadMessages implements IToMsgPack {
    MsgGetFriendChatUnreadMessages();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory MsgGetFriendChatUnreadMessages.fromMsgPack(List list) {
      return MsgGetFriendChatUnreadMessages(
      );
    }
}