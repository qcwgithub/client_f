import 'package:scene_hub/i_to_msg_pack.dart';

class MsgBlockUser implements IToMsgPack {
    // [0]
    int targetUserId;

    MsgBlockUser({
      required this.targetUserId,
    });

    @override
    List toMsgPack() {
      return [
        targetUserId,
      ];
    }

    factory MsgBlockUser.fromMsgPack(List list) {
      return MsgBlockUser(
        targetUserId: list[0] as int,
      );
    }
}