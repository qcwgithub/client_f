import 'package:scene_hub/i_to_msg_pack.dart';

class ResSetFriendChatReadSeq implements IToMsgPack {
    // [0]
    int readSeq;

    ResSetFriendChatReadSeq({
      required this.readSeq,
    });

    @override
    List toMsgPack() {
      return [
        readSeq,
      ];
    }

    factory ResSetFriendChatReadSeq.fromMsgPack(List list) {
      return ResSetFriendChatReadSeq(
        readSeq: list[0] as int,
      );
    }
}