import 'package:scene_hub/i_to_msg_pack.dart';

class MsgReceiveFriendChatMessages implements IToMsgPack {
    MsgReceiveFriendChatMessages();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory MsgReceiveFriendChatMessages.fromMsgPack(List list) {
      return MsgReceiveFriendChatMessages(
      );
    }
}