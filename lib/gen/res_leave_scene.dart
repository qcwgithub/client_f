import 'package:scene_hub/i_to_msg_pack.dart';

class ResLeaveScene implements IToMsgPack {
    ResLeaveScene();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResLeaveScene.fromMsgPack(List list) {
      return ResLeaveScene(
      );
    }
}