import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAOtherRejectFriendRequest implements IToMsgPack {
    // [0]
    int otherUserId;

    MsgAOtherRejectFriendRequest({
      required this.otherUserId,
    });

    @override
    List toMsgPack() {
      return [
        otherUserId,
      ];
    }

    factory MsgAOtherRejectFriendRequest.fromMsgPack(List list) {
      return MsgAOtherRejectFriendRequest(
        otherUserId: list[0] as int,
      );
    }
}