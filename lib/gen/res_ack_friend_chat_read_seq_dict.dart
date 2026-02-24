import 'package:scene_hub/i_to_msg_pack.dart';

class ResAckFriendChatReadSeqDict implements IToMsgPack {
    ResAckFriendChatReadSeqDict();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResAckFriendChatReadSeqDict.fromMsgPack(List list) {
      return ResAckFriendChatReadSeqDict(
      );
    }
}