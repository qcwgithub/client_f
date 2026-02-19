import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/remove_friend_reason.dart';
import 'package:scene_hub/gen/friend_info.dart';

class MsgARemoveFriend implements IToMsgPack {
    // [0]
    int friendUserId;
    // [1]
    RemoveFriendReason reason;
    // [2]
    FriendInfo removedFriendInfo;

    MsgARemoveFriend({
      required this.friendUserId,
      required this.reason,
      required this.removedFriendInfo,
    });

    @override
    List toMsgPack() {
      return [
        friendUserId,
        reason.code,
        removedFriendInfo.toMsgPack(),
      ];
    }

    factory MsgARemoveFriend.fromMsgPack(List list) {
      return MsgARemoveFriend(
        friendUserId: list[0] as int,
        reason: RemoveFriendReason.fromCode(list[1] as int),
        removedFriendInfo: FriendInfo.fromMsgPack(list[2] as List),
      );
    }
}