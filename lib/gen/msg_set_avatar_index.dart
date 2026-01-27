import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSetAvatarIndex implements IToMsgPack {
    // [0]
    int avatarIndex;

    MsgSetAvatarIndex({
      required this.avatarIndex,
    });

    @override
    List toMsgPack() {
      return [
        avatarIndex,
      ];
    }

    factory MsgSetAvatarIndex.fromMsgPack(List list) {
      return MsgSetAvatarIndex(
        avatarIndex: list[0] as int,
      );
    }
}