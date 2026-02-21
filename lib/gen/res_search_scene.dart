import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/scene_room_info.dart';

class ResSearchScene implements IToMsgPack {
    // [0]
    List<SceneRoomInfo> sceneRoomInfos;

    ResSearchScene({
      required this.sceneRoomInfos,
    });

    @override
    List toMsgPack() {
      return [
        sceneRoomInfos.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResSearchScene.fromMsgPack(List list) {
      return ResSearchScene(
        sceneRoomInfos: (list[0] as List)
          .map((e) => SceneRoomInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}