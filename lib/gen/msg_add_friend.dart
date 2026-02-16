import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAddFriend implements IToMsgPack {
    // [0]
    int targetUserId;

    MsgAddFriend({
      required this.targetUserId,
    });

    @override
    List toMsgPack() {
      return [
        targetUserId,
      ];
    }

    factory MsgAddFriend.fromMsgPack(List list) {
      return MsgAddFriend(
        targetUserId: list[0] as int,
      );
    }
}