import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/logic/room_list_notifier.dart';
import 'package:scene_hub/models/room_list_model.dart';

final roomListProvider =
    StateNotifierProvider<RoomListNotifier, RoomListModel>(
  (ref) => RoomListNotifier(),
);