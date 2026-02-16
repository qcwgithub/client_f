import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/friend_info.dart';

class MsgAOtherAcceptFriendRequest implements IToMsgPack {
    // [0]
    int otherUserId;
    // [1]
    FriendInfo friendInfo;

    MsgAOtherAcceptFriendRequest({
      required this.otherUserId,
      required this.friendInfo,
    });

    @override
    List toMsgPack() {
      return [
        otherUserId,
        friendInfo.toMsgPack(),
      ];
    }

    factory MsgAOtherAcceptFriendRequest.fromMsgPack(List list) {
      return MsgAOtherAcceptFriendRequest(
        otherUserId: list[0] as int,
        friendInfo: FriendInfo.fromMsgPack(list[1] as List),
      );
    }
}