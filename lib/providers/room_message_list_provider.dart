import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_send_room_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

enum RoomMessageListStatus { idle, refreshing, success, empty, error }

class RoomMessageListModel {
  final List<ClientChatMessage> messages;
  final RoomMessageListStatus status;
  RoomMessageListModel({required this.messages, required this.status});

  factory RoomMessageListModel.initial() {
    return RoomMessageListModel(
      messages: [],
      status: RoomMessageListStatus.idle,
    );
  }

  RoomMessageListModel copyWith({
    List<ClientChatMessage>? messages,
    RoomMessageListStatus? status,
  }) {
    return RoomMessageListModel(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
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
    state = RoomMessageListModel(
      messages: messages,
      status: messages.isEmpty
          ? RoomMessageListStatus.empty
          : RoomMessageListStatus.success,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      status: state.status == RoomMessageListStatus.empty
          ? RoomMessageListStatus.success
          : state.status,
    );
  }

  ClientChatMessage _updateMessage(
    ClientChatMessage message,
    ClientChatMessage Function(ClientChatMessage) newMessageFunc,
  ) {
    int index = state.messages.indexOf(message);
    if (index == -1) {
      assert(false, "_updateMessage() index == -1");
      return message;
    }

    final newMessage = newMessageFunc(message);
    state = state.copyWith(messages: [...state.messages]..[index] = newMessage);

    return newMessage;
  }

  static ClientChatMessage _createSending(
    int roomId,
    ChatMessageType type,
    String content,
    int replyTo,
  ) {
    int clientMessageId = clientMessageIdGenerator.nextId();
    final inner = ChatMessage(
      messageId: 0,
      roomId: roomId,
      senderId: sc.me.userId,
      senderName: sc.me.userName,
      senderAvatar: "",
      type: type,
      content: content,
      timestamp: TimeUtils.now(),
      replyTo: replyTo,
      senderAvatarIndex: sc.me.userInfo.avatarIndex,
      clientMessageId: clientMessageId,
      status: ChatMessageStatus.normal,
    );
    final message = ClientChatMessage(
      inner: inner,
      clientStatus: ClientChatMessageStatus.sending,
      useClientId: true,
    );

    return message;
  }

  static Future<bool> _requestSendChat(
    int roomId,
    ClientChatMessage message,
  ) async {
    assert(message.clientStatus == ClientChatMessageStatus.sending);

    final r = await sc.server.request(
      MsgType.sendRoomChat,
      MsgSendRoomChat(
        roomId: roomId,
        chatMessageType: message.type,
        content: message.content,
        clientMessageId: message.clientMessageId,
      ),
    );

    if (r.e != ECode.success) {
      message.clientStatus = ClientChatMessageStatus.failed;
      return false;
    }

    // final res = ResSendRoomChat.fromMsgPack(r.res!);
    return true;
  }

  Future<void> sendChat(
    ChatMessageType type,
    String content,
    int replyTo,
  ) async {
    ClientChatMessage message = _createSending(roomId, type, content, replyTo);
    _addMessage(message);

    bool success = await _requestSendChat(roomId, message);
    if (success) {
      _updateMessage(
        message,
        (m) => m.copyWith(clientStatus: ClientChatMessageStatus.normal),
      );
    } else {
      _updateMessage(
        message,
        (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
      );
    }
  }

  Future<void> resendChat(ClientChatMessage message) async {
    message = _updateMessage(
      message,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.sending),
    );

    bool success = await _requestSendChat(roomId, message);
    if (success) {
      _updateMessage(
        message,
        (m) => m.copyWith(clientStatus: ClientChatMessageStatus.normal),
      );
    } else {
      _updateMessage(
        message,
        (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
      );
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
