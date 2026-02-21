import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/room_participant.dart';

class PrivateRoomInfo implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int createTimeS;
    // [2]
    int messageId;
    // [3]
    List<RoomParticipant> participants;

    PrivateRoomInfo({
      required this.roomId,
      required this.createTimeS,
      required this.messageId,
      required this.participants,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        createTimeS,
        messageId,
        participants.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory PrivateRoomInfo.fromMsgPack(List list) {
      return PrivateRoomInfo(
        roomId: list[0] as int,
        createTimeS: list[1] as int,
        messageId: list[2] as int,
        participants: (list[3] as List)
          .map((e) => RoomParticipant.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}