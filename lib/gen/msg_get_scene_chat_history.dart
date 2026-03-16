import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetSceneChatHistory implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int beforeSeq;
    // [2]
    int count;

    MsgGetSceneChatHistory({
      required this.roomId,
      required this.beforeSeq,
      required this.count,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        beforeSeq,
        count,
      ];
    }

    factory MsgGetSceneChatHistory.fromMsgPack(List list) {
      return MsgGetSceneChatHistory(
        roomId: list[0] as int,
        beforeSeq: list[1] as int,
        count: list[2] as int,
      );
    }
}