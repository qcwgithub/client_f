import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAckFriendChatReadSeq1 implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int readSeq;

    MsgAckFriendChatReadSeq1({
      required this.roomId,
      required this.readSeq,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        readSeq,
      ];
    }

    factory MsgAckFriendChatReadSeq1.fromMsgPack(List list) {
      return MsgAckFriendChatReadSeq1(
        roomId: list[0] as int,
        readSeq: list[1] as int,
      );
    }
}