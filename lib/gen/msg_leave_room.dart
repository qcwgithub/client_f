import 'package:scene_hub/i_to_msg_pack.dart';

class MsgLeaveRoom implements IToMsgPack {
    // [0]
    int roomId;

    MsgLeaveRoom({
      required this.roomId,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
      ];
    }

    factory MsgLeaveRoom.fromMsgPack(List list) {
      return MsgLeaveRoom(
        roomId: list[0] as int,
      );
    }
}