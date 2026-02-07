import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_enter_room.dart';
import 'package:scene_hub/gen/msg_get_recommended_rooms.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_enter_room.dart';
import 'package:scene_hub/gen/res_get_recommended_rooms.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/logic/room.dart';
import 'package:scene_hub/sc.dart';

class RoomManager {
  final List<RoomInfo> recommendedRoomInfos = [];
  final roomMap = <int, Room>{};

  Future<bool> getRecommendedRooms() async {
    if (sc.server.isPending(MsgType.getRecommendedRooms)) {
      return false;
    }

    final r = await sc.server.request(
      MsgType.getRecommendedRooms,
      MsgGetRecommendedRooms(),
    );

    if (r.e != ECode.success) {
      return false;
    }

    final res = ResGetRecommendedRooms.fromMsgPack(r.res!);
    recommendedRoomInfos.clear();
    recommendedRoomInfos.addAll(res.roomInfos);
    return true;
  }

  Future<bool> enterRoom(RoomInfo roomInfo) async {
    if (sc.server.isPending(MsgType.enterRoom)) {
      return false;
    }

    var msg = MsgEnterRoom(roomId: roomInfo.roomId, lastMessageId: 0);
    final r = await sc.server.request(MsgType.enterRoom, msg);

    if (r.e != ECode.success) {
      return false;
    }

    var res = ResEnterRoom.fromMsgPack(r.res!);
    final room = Room(roomInfo, res.recentMessages);
    roomMap[roomInfo.roomId] = room;

    return true;
  }

  Room? getRoom(int roomId) {
    return roomMap[roomId];
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
