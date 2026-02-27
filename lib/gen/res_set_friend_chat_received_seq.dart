import 'package:scene_hub/i_to_msg_pack.dart';

class ResSetFriendChatReceivedSeq implements IToMsgPack {
    // [0]
    int receivedSeq;

    ResSetFriendChatReceivedSeq({
      required this.receivedSeq,
    });

    @override
    List toMsgPack() {
      return [
        receivedSeq,
      ];
    }

    factory ResSetFriendChatReceivedSeq.fromMsgPack(List list) {
      return ResSetFriendChatReceivedSeq(
        receivedSeq: list[0] as int,
      );
    }
}