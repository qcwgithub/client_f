import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAcceptAddFriend implements IToMsgPack {
    // [0]
    int fromUserId;

    MsgAcceptAddFriend({
      required this.fromUserId,
    });

    @override
    List toMsgPack() {
      return [
        fromUserId,
      ];
    }

    factory MsgAcceptAddFriend.fromMsgPack(List list) {
      return MsgAcceptAddFriend(
        fromUserId: list[0] as int,
      );
    }
}