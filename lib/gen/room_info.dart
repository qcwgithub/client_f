import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/room_participant.dart';

class RoomInfo implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int createTimeS;
    // [2]
    String title;
    // [3]
    String desc;
    // [4]
    int messageId;
    // [5]
    List<RoomParticipant> participants;

    RoomInfo({
      required this.roomId,
      required this.createTimeS,
      required this.title,
      required this.desc,
      required this.messageId,
      required this.participants,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        createTimeS,
        title,
        desc,
        messageId,
        participants.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory RoomInfo.fromMsgPack(List list) {
      return RoomInfo(
        roomId: list[0] as int,
        createTimeS: list[1] as int,
        title: list[2] as String,
        desc: list[3] as String,
        messageId: list[4] as int,
        participants: (list[5] as List)
          .map((e) => RoomParticipant.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}