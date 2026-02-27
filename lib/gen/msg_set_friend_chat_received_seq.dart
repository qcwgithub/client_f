import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSetFriendChatReceivedSeq implements IToMsgPack {
    // [0]
    int friendUserId;
    // [1]
    int receivedSeq;

    MsgSetFriendChatReceivedSeq({
      required this.friendUserId,
      required this.receivedSeq,
    });

    @override
    List toMsgPack() {
      return [
        friendUserId,
        receivedSeq,
      ];
    }

    factory MsgSetFriendChatReceivedSeq.fromMsgPack(List list) {
      return MsgSetFriendChatReceivedSeq(
        friendUserId: list[0] as int,
        receivedSeq: list[1] as int,
      );
    }
}