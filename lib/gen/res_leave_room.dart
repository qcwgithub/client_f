import 'package:scene_hub/i_to_msg_pack.dart';

class ResLeaveRoom implements IToMsgPack {
    ResLeaveRoom();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResLeaveRoom.fromMsgPack(List list) {
      return ResLeaveRoom(
      );
    }
}