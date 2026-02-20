import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/room_info.dart';

class ResGetRecommendedScenes implements IToMsgPack {
    // [0]
    List<RoomInfo> roomInfos;

    ResGetRecommendedScenes({
      required this.roomInfos,
    });

    @override
    List toMsgPack() {
      return [
        roomInfos.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResGetRecommendedScenes.fromMsgPack(List list) {
      return ResGetRecommendedScenes(
        roomInfos: (list[0] as List)
          .map((e) => RoomInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}