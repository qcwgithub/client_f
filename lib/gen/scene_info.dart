import 'package:scene_hub/i_to_msg_pack.dart';

class SceneInfo implements IToMsgPack {
    // [0]
    int roomId;
    // [1]
    int createTimeS;
    // [2]
    String title;
    // [3]
    String desc;
    // [4]
    int messageSeq;

    SceneInfo({
      required this.roomId,
      required this.createTimeS,
      required this.title,
      required this.desc,
      required this.messageSeq,
    });

    @override
    List toMsgPack() {
      return [
        roomId,
        createTimeS,
        title,
        desc,
        messageSeq,
      ];
    }

    factory SceneInfo.fromMsgPack(List list) {
      return SceneInfo(
        roomId: list[0] as int,
        createTimeS: list[1] as int,
        title: list[2] as String,
        desc: list[3] as String,
        messageSeq: list[4] as int,
      );
    }
}