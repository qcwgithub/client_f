import 'package:flutter/material.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_recommended_rooms.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_recommended_rooms.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/server.dart';

enum RoomListStatus {
  idle, // 初始 & 空
  refreshing, // 下拉刷新中
  success, // 有数据
  empty, // 请求成功但 0 条
  error, // 请求失败
}

class RoomListState extends ChangeNotifier {
  static RoomListState? instance;
  RoomListState() {
    instance = this;
  }

  List<RoomInfo> roomInfos = [];
  RoomListStatus status = RoomListStatus.idle;

  Future<void> getRecommendedRooms() async {
    if (Server.instance.isPending(MsgType.getRecommendedRooms)) {
      return;
    }

    status = RoomListStatus.refreshing;
    notifyListeners();

    MyResponse r = await Server.instance.request(
      MsgType.getRecommendedRooms,
      MsgGetRecommendedRooms(),
    );

    if (r.e != ECode.success) {
      status = RoomListStatus.error;
      notifyListeners();
      return;
    }

    var res = ResGetRecommendedRooms.fromMsgPack(r.res!);
    if (res.roomInfos.isEmpty) {
      roomInfos = [];
      status = RoomListStatus.empty;
    } else {
      roomInfos = res.roomInfos;
      status = RoomListStatus.success;
    }

    notifyListeners();
  }

  Future<void> search(String keyword) async {
    if (Server.instance.isPending(MsgType.searchRoom)) {
      return;
    }
    
    status = RoomListStatus.refreshing;
    notifyListeners();

    MyResponse r = await Server.instance.request(
      MsgType.searchRoom,
      MsgSearchRoom(keyword: keyword),
    );
    
    if (r.e != ECode.success) {
      status = RoomListStatus.success;
      notifyListeners();
      return;
    }

    var res = ResSearchRoom.fromMsgPack(r.res!);
    if (res.roomInfos.isEmpty) {
      roomInfos = [];
      status = RoomListStatus.empty;
    } else {
      roomInfos = res.roomInfos;
      status = RoomListStatus.success;
    }

    notifyListeners();
  }
}
