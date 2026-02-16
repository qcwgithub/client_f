import 'package:scene_hub/i_to_msg_pack.dart';

class UserBriefInfo implements IToMsgPack {
    // [0]
    int isPlaceholder;
    // [1]
    int userId;
    // [2]
    String userName;
    // [3]
    int avatarIndex;

    UserBriefInfo({
      required this.isPlaceholder,
      required this.userId,
      required this.userName,
      required this.avatarIndex,
    });

    @override
    List toMsgPack() {
      return [
        isPlaceholder,
        userId,
        userName,
        avatarIndex,
      ];
    }

    factory UserBriefInfo.fromMsgPack(List list) {
      return UserBriefInfo(
        isPlaceholder: list[0] as int,
        userId: list[1] as int,
        userName: list[2] as String,
        avatarIndex: list[3] as int,
      );
    }
}