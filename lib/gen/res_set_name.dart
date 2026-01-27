import 'package:scene_hub/i_to_msg_pack.dart';

class ResSetName implements IToMsgPack {
    // [0]
    String userName;

    ResSetName({
      required this.userName,
    });

    @override
    List toMsgPack() {
      return [
        userName,
      ];
    }

    factory ResSetName.fromMsgPack(List list) {
      return ResSetName(
        userName: list[0] as String,
      );
    }
}