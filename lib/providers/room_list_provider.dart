import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_recommended_rooms.dart';
import 'package:scene_hub/gen/msg_search_room.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_recommended_rooms.dart';
import 'package:scene_hub/gen/res_search_room.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/sc.dart';

enum RoomListStatus { idle, refreshing, success, empty, error }

class RoomListModel {
  final List<RoomInfo> roomInfos;
  final RoomListStatus status;

  const RoomListModel({required this.roomInfos, required this.status});

  factory RoomListModel.initial() {
    return RoomListModel(roomInfos: [], status: RoomListStatus.idle);
  }

  RoomListModel copyWith({List<RoomInfo>? roomInfos, RoomListStatus? status}) {
    return RoomListModel(
      roomInfos: roomInfos ?? this.roomInfos,
      status: status ?? this.status,
    );
  }
}

class RoomListNotifier extends StateNotifier<RoomListModel> {
  RoomListNotifier() : super(RoomListModel.initial());

  Future<bool> getRecommendedRooms() async {
    if (state.status == RoomListStatus.refreshing) return false;

    state = state.copyWith(status: RoomListStatus.refreshing);

    final r = await sc.server.request(
      MsgType.getRecommendedRooms,
      MsgGetRecommendedRooms(),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: RoomListStatus.error);
      return false;
    }

    final res = ResGetRecommendedRooms.fromMsgPack(r.res!);

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(roomInfos: [], status: RoomListStatus.empty);
    } else {
      state = state.copyWith(
        roomInfos: res.roomInfos,
        status: RoomListStatus.idle,
      );
    }
    return true;
  }

  Future<void> search(String keyword) async {
    if (state.status == RoomListStatus.refreshing) return;

    state = state.copyWith(status: RoomListStatus.refreshing);

    MyResponse r = await sc.server.request(
      MsgType.searchRoom,
      MsgSearchRoom(keyword: keyword),
    );

    if (r.e != ECode.success) {
      state = state.copyWith(status: RoomListStatus.error);
      return;
    }

    var res = ResSearchRoom.fromMsgPack(r.res!);
    final rooms = res.roomInfos;

    if (res.roomInfos.isEmpty) {
      state = state.copyWith(roomInfos: [], status: RoomListStatus.empty);
    } else {
      state = state.copyWith(roomInfos: rooms, status: RoomListStatus.idle);
    }
  }
}

final roomListProvider = StateNotifierProvider<RoomListNotifier, RoomListModel>(
  (ref) => RoomListNotifier(),
);
