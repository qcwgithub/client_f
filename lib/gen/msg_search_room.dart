import 'package:scene_hub/i_to_msg_pack.dart';

class MsgSearchRoom implements IToMsgPack {
    // [0]
    String keyword;

    MsgSearchRoom({
      required this.keyword,
    });

    @override
    List toMsgPack() {
      return [
        keyword,
      ];
    }

    factory MsgSearchRoom.fromMsgPack(List list) {
      return MsgSearchRoom(
        keyword: list[0] as String,
      );
    }
}