import 'package:scene_hub/gen/room_info.dart';

enum RoomListStatus { idle, refreshing, success, empty, error }

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
