import 'package:scene_hub/i_to_msg_pack.dart';

class PrivateRoomUser implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int joinTimeS;

    PrivateRoomUser({
      required this.userId,
      required this.joinTimeS,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        joinTimeS,
      ];
    }

    factory PrivateRoomUser.fromMsgPack(List list) {
      return PrivateRoomUser(
        userId: list[0] as int,
        joinTimeS: list[1] as int,
      );
    }
}