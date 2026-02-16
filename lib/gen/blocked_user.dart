import 'package:scene_hub/i_to_msg_pack.dart';

class BlockedUser implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int timeS;

    BlockedUser({
      required this.userId,
      required this.timeS,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        timeS,
      ];
    }

    factory BlockedUser.fromMsgPack(List list) {
      return BlockedUser(
        userId: list[0] as int,
        timeS: list[1] as int,
      );
    }
}