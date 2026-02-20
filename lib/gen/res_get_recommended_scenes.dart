import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/scene_info.dart';

class ResGetRecommendedScenes implements IToMsgPack {
    // [0]
    List<SceneInfo> sceneInfos;

    ResGetRecommendedScenes({
      required this.sceneInfos,
    });

    @override
    List toMsgPack() {
      return [
        sceneInfos.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory ResGetRecommendedScenes.fromMsgPack(List list) {
      return ResGetRecommendedScenes(
        sceneInfos: (list[0] as List)
          .map((e) => SceneInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}