import 'package:scene_hub/i_to_msg_pack.dart';

class RoomParticipant implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    int joinTimeS;

    RoomParticipant({
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

    factory RoomParticipant.fromMsgPack(List list) {
      return RoomParticipant(
        userId: list[0] as int,
        joinTimeS: list[1] as int,
      );
    }
}