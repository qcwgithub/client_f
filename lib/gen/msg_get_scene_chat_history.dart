import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetSceneChatHistory implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int lastMessageId;

    MsgGetSceneChatHistory({
      required this.roomId,
      required this.lastMessageId,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        lastMessageId,
      ];
    }

    factory MsgGetSceneChatHistory.fromMsgPack(List list) {
      return MsgGetSceneChatHistory(
        roomId: list[0] as int,
        lastMessageId: list[1] as int,
      );
    }
}