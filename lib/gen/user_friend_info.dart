import 'package:scene_hub/i_to_msg_pack.dart';

class UserFriendInfo implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int timeS;

    UserFriendInfo({
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

    factory UserFriendInfo.fromMsgPack(List list) {
      return UserFriendInfo(
        userId: list[0] as int,
        timeS: list[1] as int,
      );
    }
}