import 'package:scene_hub/i_to_msg_pack.dart';

class ResAddBlack implements IToMsgPack {
    ResAddBlack();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResAddBlack.fromMsgPack(List list) {
      return ResAddBlack(
      );
    }
}