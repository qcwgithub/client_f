import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/providers/recommended_room_list_provider.dart';
import 'package:scene_hub/providers/search_keyword_provider.dart';

final filteredRoomListProvider = Provider<List<RoomInfo>>((ref) {
  AsyncValue<List<RoomInfo>> roomListAsync = ref.watch(
    recommendedRoomListProvider,
  );
  List<RoomInfo>? roomList;
  if (roomListAsync.hasValue) {
    roomList = roomListAsync.value;
  } else {
    roomList = [];
  }

  String keyword = ref.watch(searchKeywordProvider);
  if (keyword.isEmpty) {
    return roomList!;
  }

  roomList = roomList!.where((r) => r.title.contains(keyword)).toList();
  return roomList;
});
