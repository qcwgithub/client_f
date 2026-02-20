import 'package:scene_hub/i_to_msg_pack.dart';

class MsgLeaveScene implements IToMsgPack {
    // [0]
    int roomId;

    MsgLeaveScene({
      required this.roomId,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
      ];
    }

    factory MsgLeaveScene.fromMsgPack(List list) {
      return MsgLeaveScene(
        roomId: list[0] as int,
      );
    }
}