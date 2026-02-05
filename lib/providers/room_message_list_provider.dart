import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/models/room_message_list_model.dart';

class RoomMessageListNotifier extends StateNotifier<RoomMessageListModel> {
  final int roomId;
  RoomMessageListNotifier(this.roomId) : super(RoomMessageListModel.initial());

  // Future<void> loadInitial() async {
  //   if (state.status == RoomMessageListStatus.refreshing) return;

  //   state = state.copyWith(status: RoomMessageListStatus.refreshing);

  // }
}

final roomMessageListProvider =
    StateNotifierProvider.family<
      RoomMessageListNotifier,
      RoomMessageListModel,
      int
    >((ref, roomId) {
      final notifier = RoomMessageListNotifier(roomId);
      return notifier;
    });
