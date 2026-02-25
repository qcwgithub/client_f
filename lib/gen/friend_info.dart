import 'package:scene_hub/i_to_msg_pack.dart';

class FriendInfo implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int timeS;
    // [2]
    int roomId;
    // [3]
    int readSeq;
    // [4]
    int receivedSeq;

    FriendInfo({
      required this.userId,
      required this.timeS,
      required this.roomId,
      required this.readSeq,
      required this.receivedSeq,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        timeS,
        roomId,
        readSeq,
        receivedSeq,
      ];
    }

    factory FriendInfo.fromMsgPack(List list) {
      return FriendInfo(
        userId: list[0] as int,
        timeS: list[1] as int,
        roomId: list[2] as int,
        readSeq: list[3] as int,
        receivedSeq: list[4] as int,
      );
    }
}