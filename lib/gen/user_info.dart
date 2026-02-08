import 'package:scene_hub/i_to_msg_pack.dart';

class UserInfo implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    String userName;
    // [2]
    int createTimeS;
    // [3]
    int lastLoginTimeS;
    // [4]
    int lastSetNameTimeS;
    // [5]
    int avatarIndex;
    // [6]
    int lastSetAvatarIndexTimeS;

    UserInfo({
      required this.userId,
      required this.userName,
      required this.createTimeS,
      required this.lastLoginTimeS,
      required this.lastSetNameTimeS,
      required this.avatarIndex,
      required this.lastSetAvatarIndexTimeS,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        userName,
        createTimeS,
        lastLoginTimeS,
        lastSetNameTimeS,
        avatarIndex,
        lastSetAvatarIndexTimeS,
      ];
    }

    factory UserInfo.fromMsgPack(List list) {
      return UserInfo(
        userId: list[0] as int,
        userName: list[1] as String,
        createTimeS: list[2] as int,
        lastLoginTimeS: list[3] as int,
        lastSetNameTimeS: list[4] as int,
        avatarIndex: list[5] as int,
        lastSetAvatarIndexTimeS: list[6] as int,
      );
    }
}