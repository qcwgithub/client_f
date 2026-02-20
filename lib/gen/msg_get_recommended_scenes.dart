import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetRecommendedScenes implements IToMsgPack {
    MsgGetRecommendedScenes();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory MsgGetRecommendedScenes.fromMsgPack(List list) {
      return MsgGetRecommendedScenes(
      );
    }
}