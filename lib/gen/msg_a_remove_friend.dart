import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/remove_friend_reason.dart';

class MsgARemoveFriend implements IToMsgPack {
    // [0]
    int friendUserId;
    // [1]
    RemoveFriendReason reason;

    MsgARemoveFriend({
      required this.friendUserId,
      required this.reason,
    });

    @override
    List toMsgPack() {
      return [
        friendUserId,
        reason.code,
      ];
    }

    factory MsgARemoveFriend.fromMsgPack(List list) {
      return MsgARemoveFriend(
        friendUserId: list[0] as int,
        reason: RemoveFriendReason.fromCode(list[1] as int),
      );
    }
}