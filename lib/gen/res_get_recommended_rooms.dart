import 'package:scene_hub/gen/room_info.dart';

class ResGetRecommendedRooms {
    // [0]
    List<RoomInfo> roomInfos;

    ResGetRecommendedRooms({
      required this.roomInfos,
    });

    List toMsgPack() {
      return [
        roomInfos.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResGetRecommendedRooms.fromMsgPack(List list) {
      return ResGetRecommendedRooms(
        roomInfos: (list[0] as List)
          .map((e) => RoomInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}