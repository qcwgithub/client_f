import 'package:scene_hub/i_to_msg_pack.dart';

class MsgEnterScene implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int lastSeq;

    MsgEnterScene({
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

    factory MsgEnterScene.fromMsgPack(List list) {
      return MsgEnterScene(
        roomId: list[0] as int,
        lastSeq: list[1] as int,
      );
    }
}