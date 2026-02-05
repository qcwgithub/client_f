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
