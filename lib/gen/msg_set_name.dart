import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSetName implements IToMsgPack {
    // [0]
    String userName;

    MsgSetName({
      required this.userName,
    });

    @override
    List toMsgPack() {
      return [
        userName,
      ];
    }

    factory MsgSetName.fromMsgPack(List list) {
      return MsgSetName(
        userName: list[0] as String,
      );
    }
}