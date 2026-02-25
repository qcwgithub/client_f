import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/scene_room_info.dart';

class ResGetRecommendedScenes implements IToMsgPack {
    // [0]
    List<SceneRoomInfo> roomInfos;

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
          .map((e) => SceneRoomInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}