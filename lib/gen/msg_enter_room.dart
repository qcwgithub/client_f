import 'package:scene_hub/i_to_msg_pack.dart';

class MsgEnterRoom implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int lastMessageId;

    MsgEnterRoom({
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

    factory MsgEnterRoom.fromMsgPack(List list) {
      return MsgEnterRoom(
        roomId: list[0] as int,
        lastMessageId: list[1] as int,
      );
    }
}