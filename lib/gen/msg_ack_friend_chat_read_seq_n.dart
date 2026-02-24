import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAckFriendChatReadSeqN implements IToMsgPack {
    // [0]
    Map<int, int> roomIdToReadSeqs;

    MsgAckFriendChatReadSeqN({
      required this.roomIdToReadSeqs,
    });

    @override
    List toMsgPack() {
      return [
        roomIdToReadSeqs,
      ];
    }

    factory MsgAckFriendChatReadSeqN.fromMsgPack(List list) {
      return MsgAckFriendChatReadSeqN(
        roomIdToReadSeqs: (list[0] as Map)
          .map((k, v) => MapEntry(k as int, v as int)),
      );
    }
}