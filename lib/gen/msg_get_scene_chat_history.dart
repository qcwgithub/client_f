import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetSceneChatHistory implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int lastSeq;

    MsgGetSceneChatHistory({
      required this.roomId,
      required this.lastSeq,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        lastSeq,
      ];
    }

    factory MsgGetSceneChatHistory.fromMsgPack(List list) {
      return MsgGetSceneChatHistory(
        roomId: list[0] as int,
        lastSeq: list[1] as int,
      );
    }
}