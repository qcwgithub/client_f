import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/room_info.dart';

class ResSearchRoom implements IToMsgPack {
    // [0]
    List<RoomInfo> roomInfos;

    ResSearchRoom({
      required this.roomInfos,
    });

    @override
    List toMsgPack() {
      return [
        roomInfos.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResSearchRoom.fromMsgPack(List list) {
      return ResSearchRoom(
        roomInfos: (list[0] as List)
          .map((e) => RoomInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}