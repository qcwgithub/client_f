import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAckFriendChatReadSeqDict implements IToMsgPack {
    // [0]
    Map<int, int> roomIdToReadSeqs;

    MsgAckFriendChatReadSeqDict({
      required this.roomIdToReadSeqs,
    });

    @override
    List toMsgPack() {
      return [
        roomIdToReadSeqs,
      ];
    }

    factory MsgAckFriendChatReadSeqDict.fromMsgPack(List list) {
      return MsgAckFriendChatReadSeqDict(
        roomIdToReadSeqs: (list[0] as Map)
          .map((k, v) => MapEntry(k as int, v as int)),
      );
    }
}