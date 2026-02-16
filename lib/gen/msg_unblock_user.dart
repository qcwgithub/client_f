import 'package:scene_hub/i_to_msg_pack.dart';

class MsgUnblockUser implements IToMsgPack {
    // [0]
    int targetUserId;

    MsgUnblockUser({
      required this.targetUserId,
    });

    @override
    List toMsgPack() {
      return [
        targetUserId,
      ];
    }

    factory MsgUnblockUser.fromMsgPack(List list) {
      return MsgUnblockUser(
        targetUserId: list[0] as int,
      );
    }
}