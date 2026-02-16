import 'package:scene_hub/i_to_msg_pack.dart';

class FriendInfo implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int timeS;

    FriendInfo({
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

    factory FriendInfo.fromMsgPack(List list) {
      return FriendInfo(
        userId: list[0] as int,
        timeS: list[1] as int,
      );
    }
}