import 'package:scene_hub/i_to_msg_pack.dart';

class MsgRejectAddFriend implements IToMsgPack {
    // [0]
    int fromUserId;

    MsgRejectAddFriend({
      required this.fromUserId,
    });

    @override
    List toMsgPack() {
      return [
        fromUserId,
      ];
    }

    factory MsgRejectAddFriend.fromMsgPack(List list) {
      return MsgRejectAddFriend(
        fromUserId: list[0] as int,
      );
    }
}