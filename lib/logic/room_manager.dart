import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/sc.dart';

class RoomManager {
  List<RoomInfo> searchResult = [];
  Future<bool> search(String keyword) async {
    if (sc.server.isPending(MsgType.searchRoom)) {
      return false;
    }

    final r = await sc.server.request(
      MsgType.searchRoom,
      MsgSearchRoom(keyword: keyword),
    );

    if (r.e != ECode.success) {
      return false;
    }

    var res = ResSearchRoom.fromMsgPack(r.res!);
    searchResult = res.roomInfos;
    return true;
  }
}
