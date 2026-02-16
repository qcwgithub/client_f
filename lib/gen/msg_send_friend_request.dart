import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSendFriendRequest implements IToMsgPack {
    // [0]
    int toUserId;
    // [1]
    String say;

    MsgSendFriendRequest({
      required this.toUserId,
      required this.say,
    });

    @override
    List toMsgPack() {
      return [
        toUserId,
        say,
      ];
    }

    factory MsgSendFriendRequest.fromMsgPack(List list) {
      return MsgSendFriendRequest(
        toUserId: list[0] as int,
        say: list[1] as String,
      );
    }
}