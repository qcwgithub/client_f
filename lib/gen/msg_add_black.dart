import 'package:scene_hub/i_to_msg_pack.dart';

class MsgAddBlack implements IToMsgPack {
    // [0]
    int targetUserId;

    MsgAddBlack({
      required this.targetUserId,
    });

    @override
    List toMsgPack() {
      return [
        targetUserId,
      ];
    }

    factory MsgAddBlack.fromMsgPack(List list) {
      return MsgAddBlack(
        targetUserId: list[0] as int,
      );
    }
}