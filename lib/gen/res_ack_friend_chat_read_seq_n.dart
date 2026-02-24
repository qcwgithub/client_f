import 'package:scene_hub/i_to_msg_pack.dart';

class ResAckFriendChatReadSeqN implements IToMsgPack {
    ResAckFriendChatReadSeqN();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResAckFriendChatReadSeqN.fromMsgPack(List list) {
      return ResAckFriendChatReadSeqN(
      );
    }
}