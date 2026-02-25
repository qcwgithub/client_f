import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSetFriendChatReadSeq implements IToMsgPack {
    // [0]
    int friendUserId;
    // [1]
    int readSeq;

    MsgSetFriendChatReadSeq({
      required this.friendUserId,
      required this.readSeq,
    });

    @override
    List toMsgPack() {
      return [
        friendUserId,
        readSeq,
      ];
    }

    factory MsgSetFriendChatReadSeq.fromMsgPack(List list) {
      return MsgSetFriendChatReadSeq(
        friendUserId: list[0] as int,
        readSeq: list[1] as int,
      );
    }
}