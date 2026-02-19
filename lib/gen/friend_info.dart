import 'package:scene_hub/i_to_msg_pack.dart';

class FriendInfo implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int timeS;
    // [2]
    int privateRoomId;

    FriendInfo({
      required this.userId,
      required this.timeS,
      required this.privateRoomId,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        timeS,
        privateRoomId,
      ];
    }

    factory FriendInfo.fromMsgPack(List list) {
      return FriendInfo(
        userId: list[0] as int,
        timeS: list[1] as int,
        privateRoomId: list[2] as int,
      );
    }
}