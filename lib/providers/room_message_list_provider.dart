import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';

enum RoomMessageListStatus { idle, refreshing, success, empty, error }

class RoomMessageListModel {
  final List<ChatMessage> messageList;
  final RoomMessageListStatus status;
  RoomMessageListModel(this.messageList, this.status);

  factory RoomMessageListModel.initial() {
    return RoomMessageListModel([], RoomMessageListStatus.idle);
  }
}

class RoomMessageListNotifier extends StateNotifier<RoomMessageListModel> {
  final int roomId;
  RoomMessageListNotifier(this.roomId) : super(RoomMessageListModel.initial());

  void setInitialMessages(List<ChatMessage> messages) {
    state = RoomMessageListModel(
      messages,
      messages.isEmpty
          ? RoomMessageListStatus.empty
          : RoomMessageListStatus.success,
    );
  }
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
