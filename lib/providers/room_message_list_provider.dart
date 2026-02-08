import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';

enum RoomMessageListStatus { idle, refreshing, success, empty, error }

class RoomMessageListModel {
  final List<ChatMessage> messageList;
  final RoomMessageListStatus status;
  final bool hasMore;
  RoomMessageListModel({
    required this.messageList,
    required this.status,
    required this.hasMore,
  });

  factory RoomMessageListModel.initial() {
    return RoomMessageListModel(
      messageList: [],
      status: RoomMessageListStatus.idle,
      hasMore: false,
    );
  }

  RoomMessageListModel copyWith({
    List<ChatMessage>? messageList,
    RoomMessageListStatus? status,
    bool? hasMore,
  }) {
    return RoomMessageListModel(
      messageList: messageList ?? this.messageList,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class RoomMessageListNotifier extends StateNotifier<RoomMessageListModel> {
  final int roomId;
  RoomMessageListNotifier(this.roomId) : super(RoomMessageListModel.initial());

  // Future<void> loadInitial() async {
  //   if (state.status == RoomMessageListStatus.refreshing) return;

  //   state = state.copyWith(status: RoomMessageListStatus.refreshing);

  // }

  void setInitialMessages(List<ChatMessage> messages) {
    state = state.copyWith(
      messageList: messages,
      status: messages.isEmpty
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
