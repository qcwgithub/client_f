import 'package:scene_hub/gen/room_info.dart';

enum RoomListStatus {
  idle, // 初始 & 空
  refreshing, // 下拉刷新中
  success, // 有数据
  empty, // 请求成功但 0 条
  error, // 请求失败
}

class RoomListModel {
  final List<RoomInfo> roomInfos;
  final RoomListStatus status;

  const RoomListModel({required this.roomInfos, required this.status});

  factory RoomListModel.initial() {
    return const RoomListModel(roomInfos: [], status: RoomListStatus.idle);
  }

  RoomListModel copyWith({List<RoomInfo>? roomInfos, RoomListStatus? status}) {
    return RoomListModel(
      roomInfos: roomInfos ?? this.roomInfos,
      status: status ?? this.status,
    );
  }
}
