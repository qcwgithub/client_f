import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_recommended_rooms.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_recommended_rooms.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/models/room_list_model.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/server.dart';

class RoomListNotifier extends StateNotifier<RoomListModel> {
  RoomListNotifier() : super(RoomListModel.initial());

  Future<void> getRecommendedRooms() async {
    if (state.status == RoomListStatus.refreshing) return;

    state = state.copyWith(status: RoomListStatus.refreshing);

    MyResponse r = await Server.instance.request(
      MsgType.getRecommendedRooms,
      MsgGetRecommendedRooms(),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(
        status: RoomListStatus.error,
        roomInfos: [],
      );
      return;
    }

    final res = ResGetRecommendedRooms.fromMsgPack(r.res!);
    final rooms = res.roomInfos;

    if (rooms.isEmpty) {
      state = state.copyWith(
        status: RoomListStatus.empty,
        roomInfos: [],
      );
    } else {
      state = state.copyWith(
        status: RoomListStatus.idle,
        roomInfos: rooms,
      );
    }
  }

  Future<void> search(String keyword) async {
    if (state.status == RoomListStatus.refreshing) return;

    state = state.copyWith(status: RoomListStatus.refreshing);

    MyResponse r = await Server.instance.request(
      MsgType.searchRoom,
      MsgSearchRoom(keyword: keyword),
    );
    
    if (r.e != ECode.success) {
      state = state.copyWith(
        status: RoomListStatus.error,
        roomInfos: [],
      );
      return;
    }

    var res = ResSearchRoom.fromMsgPack(r.res!);
    final rooms = res.roomInfos;

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(
        status: RoomListStatus.empty,
        roomInfos: [],
      );
    } else {
      state = state.copyWith(
        status: RoomListStatus.idle,
        roomInfos: rooms,
      );
    }
  }
}

final roomListProvider =
    StateNotifierProvider<RoomListNotifier, RoomListModel>(
  (ref) => RoomListNotifier(),
);