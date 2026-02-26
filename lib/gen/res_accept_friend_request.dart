import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/friend_info.dart';

class ResAcceptFriendRequest implements IToMsgPack {
    // [0]
    FriendInfo friendInfo;

    ResAcceptFriendRequest({
      required this.friendInfo,
    });

    @override
    List toMsgPack() {
      return [
        friendInfo.toMsgPack(),
      ];
    }

    factory ResAcceptFriendRequest.fromMsgPack(List list) {
      return ResAcceptFriendRequest(
        friendInfo: FriendInfo.fromMsgPack(list[0] as List),
      );
    }
}