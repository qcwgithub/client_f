import 'package:scene_hub/i_to_msg_pack.dart';

class MsgEnterScene implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int lastMessageId;

    MsgEnterScene({
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

    factory MsgEnterScene.fromMsgPack(List list) {
      return MsgEnterScene(
        roomId: list[0] as int,
        lastMessageId: list[1] as int,
      );
    }
}