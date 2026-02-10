import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_room.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_room.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/logic/room.dart';
import 'package:scene_hub/my_logger.dart';
import 'package:scene_hub/sc.dart';

class RoomManager {
  final roomInfoMap = <int, RoomInfo>{};
  final roomMap = <int, Room>{};

  Future<bool> enterRoom(int roomId) async {
    if (sc.server.isPending(MsgType.enterRoom)) {
      return false;
    }

    final roomInfo = roomInfoMap[roomId];
    if (roomInfo == null) {
      MyLogger.instance.e("enterRoom() roomInfo == null");
      return false;
    }

    var msg = MsgEnterRoom(roomId: roomId, lastMessageId: 0);
    final r = await sc.server.request(MsgType.enterRoom, msg);

    if (r.e != ECode.success) {
      return false;
    }

    var res = ResEnterRoom.fromMsgPack(r.res!);
    final room = Room(roomInfo: roomInfo, recentMessages: res.recentMessages);
    roomMap[roomInfo.roomId] = room;

    return true;
  }

  Room? getRoom(int roomId) {
    return roomMap[roomId];
  }

  RoomInfo? getRoomInfo(int roomId) {
    return roomInfoMap[roomId];
  }

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
