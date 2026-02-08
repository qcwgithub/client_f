import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/sc.dart';

enum RoomListStatus { idle, refreshing, success, empty, error }

class RoomListModel {
  final List<RoomInfo> roomInfos;
  final RoomListStatus status;

  const RoomListModel(this.roomInfos, this.status);

  factory RoomListModel.initial() {
    return const RoomListModel([], RoomListStatus.idle);
  }
}

class RoomListNotifier extends StateNotifier<RoomListModel> {
  RoomListNotifier() : super(RoomListModel.initial());

  Future<bool> getRecommendedRooms() async {
    if (state.status == RoomListStatus.refreshing) {
      return false;
    }

    state = RoomListModel([], RoomListStatus.refreshing);

    bool success = await sc.roomManager.getRecommendedRooms();

    if (!success) {
      state = RoomListModel([], RoomListStatus.error);
      return false;
    }

    final rooms = sc.roomManager.recommendedRoomInfos;
    if (rooms.isEmpty) {
      state = RoomListModel([], RoomListStatus.empty);
    } else {
      state = RoomListModel(rooms, RoomListStatus.idle);
    }
    return true;
  }

  Future<void> search(String keyword) async {
    if (state.status == RoomListStatus.refreshing) {
      return;
    }

    state = RoomListModel([], RoomListStatus.refreshing);

    MyResponse r = await sc.server.request(
      MsgType.searchRoom,
      MsgSearchRoom(keyword: keyword),
    );

    if (r.e != ECode.success) {
      state = RoomListModel([], RoomListStatus.error);
      return;
    }

    var res = ResSearchRoom.fromMsgPack(r.res!);
    final rooms = res.roomInfos;

    if (res.roomInfos.isEmpty) {
      state = RoomListModel([], RoomListStatus.empty);
    } else {
      state = RoomListModel(rooms, RoomListStatus.idle);
    }
  }
}

final roomListProvider = StateNotifierProvider<RoomListNotifier, RoomListModel>(
  (ref) => RoomListNotifier(),
);
