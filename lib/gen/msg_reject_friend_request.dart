import 'package:scene_hub/i_to_msg_pack.dart';

class MsgRejectFriendRequest implements IToMsgPack {
    // [0]
    int fromUserId;

    MsgRejectFriendRequest({
      required this.fromUserId,
    });

    @override
    List toMsgPack() {
      return [
        fromUserId,
      ];
    }

    factory MsgRejectFriendRequest.fromMsgPack(List list) {
      return MsgRejectFriendRequest(
        fromUserId: list[0] as int,
      );
    }
}