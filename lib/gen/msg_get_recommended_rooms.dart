import 'package:scene_hub/i_to_msg_pack.dart';

class MsgGetRecommendedRooms implements IToMsgPack {
    MsgGetRecommendedRooms();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory MsgGetRecommendedRooms.fromMsgPack(List list) {
      return MsgGetRecommendedRooms(
      );
    }
}