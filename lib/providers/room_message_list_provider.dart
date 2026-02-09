import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/sc.dart';

enum RoomMessageListStatus { idle, refreshing, success, empty, error }

class RoomMessageListModel {
  final List<ClientChatMessage> messages;
  final RoomMessageListStatus status;
  RoomMessageListModel({required this.messages, required this.status});

  factory RoomMessageListModel.initial() {
    return RoomMessageListModel.create([], RoomMessageListStatus.idle);
  }

  factory RoomMessageListModel.create(
    List<ClientChatMessage> messages,
    RoomMessageListStatus status,
  ) {
    return RoomMessageListModel(messages: messages, status: status);
  }

  // TODO
  ClientChatMessage findMessage(bool useClientId, int messageId) {
    return messages.firstWhere((message) {
      if (useClientId) {
        return message.useClientId && message.clientMessageId == messageId;
      } else {
        return !message.useClientId && message.messageId == messageId;
      }
    });
  }
}

class RoomMessageListNotifier extends StateNotifier<RoomMessageListModel> {
  final int roomId;
  RoomMessageListNotifier(this.roomId) : super(RoomMessageListModel.initial());

  void setInitialMessages(List<ClientChatMessage> messages) {
    state = RoomMessageListModel.create(
      messages,
      messages.isEmpty
          ? RoomMessageListStatus.empty
          : RoomMessageListStatus.success,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = RoomMessageListModel(
      messages: [...state.messages, message],
      status: state.status == RoomMessageListStatus.empty
          ? RoomMessageListStatus.success
          : state.status,
    );
  }

  void _updateMessage(
    ClientChatMessage oldMessage,
    ClientChatMessage newMessage,
  ) {
    int index = state.messages.indexOf(oldMessage);
    if (index == -1) {
      assert(false, "_updateMessage() index == -1");
      return;
    }

    state = RoomMessageListModel(
      messages: [...state.messages]..[index] = newMessage,
      status: state.status,
    );
  }

  Future<void> sendChat(
    ChatMessageType type,
    String content,
    int replyTo,
  ) async {
    final room = sc.roomManager.getRoom(roomId)!;
    ClientChatMessage message = room.createSending(type, content, replyTo);
    _addMessage(message);

    bool success = await room.sendChat(message);
    if (success) {
      ClientChatMessage newMessage = message.modifyClientStatus(
        ClientChatMessageStatus.normal,
      );
      _updateMessage(message, newMessage);
    } else {
      ClientChatMessage newMessage = message.modifyClientStatus(
        ClientChatMessageStatus.failed,
      );
      _updateMessage(message, newMessage);
    }
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
