import 'package:scene_hub/i_to_msg_pack.dart';

class MsgRemoveFriend implements IToMsgPack {
    // [0]
    int friendUserId;

    MsgRemoveFriend({
      required this.friendUserId,
    });

    @override
    List toMsgPack() {
      return [
        friendUserId,
      ];
    }

    factory MsgRemoveFriend.fromMsgPack(List list) {
      return MsgRemoveFriend(
        friendUserId: list[0] as int,
      );
    }
}