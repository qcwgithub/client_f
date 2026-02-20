import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSearchScene implements IToMsgPack {
    // [0]
    String keyword;

    MsgSearchScene({
      required this.keyword,
    });

    @override
    List toMsgPack() {
      return [
        keyword,
      ];
    }

    factory MsgSearchScene.fromMsgPack(List list) {
      return MsgSearchScene(
        keyword: list[0] as String,
      );
    }
}