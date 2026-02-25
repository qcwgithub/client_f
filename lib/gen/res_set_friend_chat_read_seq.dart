import 'package:scene_hub/i_to_msg_pack.dart';

class ResSetFriendChatReadSeq implements IToMsgPack {
    ResSetFriendChatReadSeq();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResSetFriendChatReadSeq.fromMsgPack(List list) {
      return ResSetFriendChatReadSeq(
      );
    }
}