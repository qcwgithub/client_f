import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAcceptFriendRequest implements IToMsgPack {
    // [0]
    int fromUserId;

    MsgAcceptFriendRequest({
      required this.fromUserId,
    });

    @override
    List toMsgPack() {
      return [
        fromUserId,
      ];
    }

    factory MsgAcceptFriendRequest.fromMsgPack(List list) {
      return MsgAcceptFriendRequest(
        fromUserId: list[0] as int,
      );
    }
}