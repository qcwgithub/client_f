import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/msg_send_friend_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/event_bus.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/my_logger.dart';
import 'package:scene_hub/sc.dart';

enum FriendMessagesStatus { idle, refreshing, success, empty, error }

class FriendMessagesModel {
  final List<ClientChatMessage> messages;
  final FriendMessagesStatus status;
  FriendMessagesModel({required this.messages, required this.status});

  bool hasMore = true;

  factory FriendMessagesModel.initial() {
    return FriendMessagesModel(messages: [], status: FriendMessagesStatus.idle);
  }

  FriendMessagesModel copyWith({
    List<ClientChatMessage>? messages,
    FriendMessagesStatus? status,
  }) {
    return FriendMessagesModel(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }

  int findMessageIndex(
    bool useClientId,
    int messageId,
    bool logErrorIfNotExist,
  ) {
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (useClientId) {
        if (message.useClientId && message.clientMessageId == messageId) {
          return i;
        }
      } else {
        if (!message.useClientId && message.seq == messageId) {
          return i;
        }
      }
    }
    if (logErrorIfNotExist) {
      logger.e(
        "findMessage failed, useClientId $useClientId messageId $messageId",
      );
    }
    return -1;
  }

  ClientChatMessage getMessageAt(int index) {
    return messages[index];
  }
}

class FriendMessagesNotifier extends StateNotifier<FriendMessagesModel> {
  final int friendUserId;
  final int roomId;
  StreamSubscription<MsgAChatMessage>? _aChatSubscription;
  final List<int> _clientMessageIds = [];

  FriendMessagesNotifier(this.friendUserId, this.roomId)
      : super(FriendMessagesModel.initial()) {
    _aChatSubscription = eventBus.on<MsgAChatMessage>().listen(_onAChatMessage);
  }

  @override
  void dispose() {
    _aChatSubscription?.cancel();
    super.dispose();
  }

  void _onAChatMessage(MsgAChatMessage aChatMessage) {
    final inner = aChatMessage.message;
    if (inner.roomId != roomId) return;

    if (sc.me.isMe(inner.senderId) &&
        _clientMessageIds.contains(inner.clientMessageId)) {
      final index = state.findMessageIndex(true, inner.clientMessageId, true);
      if (index >= 0) {
        final message = state.getMessageAt(index);
        if (message.clientStatus != ClientChatMessageStatus.normal) {
          _updateMessageAt(
            index,
            (m) => m.copyWith(clientStatus: ClientChatMessageStatus.normal),
          );
        }
      }
    } else {
      final message = ClientChatMessage.server(inner: inner);
      _addMessage(message);
    }
  }

  void setInitialMessages(List<ClientChatMessage> messages) {
    state = FriendMessagesModel(
      messages: messages,
      status: messages.isEmpty
          ? FriendMessagesStatus.empty
          : FriendMessagesStatus.success,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      status: state.status == FriendMessagesStatus.empty
          ? FriendMessagesStatus.success
          : state.status,
    );
  }

  ClientChatMessage _updateMessageAt(
    int index,
    ClientChatMessage Function(ClientChatMessage) newMessageFunc,
  ) {
    final message = state.messages[index];
    final newMessage = newMessageFunc(message);
    state = state.copyWith(messages: [...state.messages]..[index] = newMessage);
    return newMessage;
  }

  static ClientChatMessage _createSending(
    int roomId,
    int friendUserId,
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent,
  ) {
    int clientMessageId = clientMessageIdGenerator.nextId();
    final inner = ChatMessage(
      seq: 0,
      roomId: roomId,
      senderId: sc.me.userId,
      senderName: sc.me.userName,
      senderAvatar: "",
      type: type,
      content: content,
      timestamp: TimeUtils.now(),
      replyTo: 0,
      senderAvatarIndex: sc.me.userInfo.avatarIndex,
      clientMessageId: clientMessageId,
      status: ChatMessageStatus.normal,
      imageContent: imageContent,
    );
    return ClientChatMessage.client(
      inner: inner,
      clientStatus: ClientChatMessageStatus.sending,
    );
  }

  Future<bool> _requestSendChat(ClientChatMessage message) async {
    assert(message.clientStatus == ClientChatMessageStatus.sending);

    final r = await sc.server.request(
      MsgType.sendFriendChat,
      MsgSendFriendChat(
        friendUserId: friendUserId,
        chatMessageType: message.type,
        content: message.content,
        clientMessageId: message.clientMessageId,
        imageContent: message.inner.imageContent,
      ),
    );

    if (r.e != ECode.success) {
      message.clientStatus = ClientChatMessageStatus.failed;
      return false;
    }

    return true;
  }

  Future<void> sendChat(
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent,
  ) async {
    ClientChatMessage message = _createSending(
      roomId,
      friendUserId,
      type,
      content,
      imageContent,
    );
    _clientMessageIds.add(message.clientMessageId);
    _addMessage(message);

    bool success = await _requestSendChat(message);
    int index = state.findMessageIndex(true, message.clientMessageId, true);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(
        clientStatus: success
            ? ClientChatMessageStatus.normal
            : ClientChatMessageStatus.failed,
      ),
    );
  }

  Future<void> resendChat(int clientMessageId) async {
    int index = state.findMessageIndex(true, clientMessageId, true);
    if (index < 0) return;

    ClientChatMessage message = _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.sending),
    );

    bool success = await _requestSendChat(message);
    index = state.findMessageIndex(true, clientMessageId, true);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(
        clientStatus: success
            ? ClientChatMessageStatus.normal
            : ClientChatMessageStatus.failed,
      ),
    );
  }
}

/// key: friendUserId
final friendMessagesProvider = StateNotifierProvider.family<
    FriendMessagesNotifier,
    FriendMessagesModel,
    (int, int)>((ref, params) {
  final (int friendUserId, int roomId) = params;
  return FriendMessagesNotifier(friendUserId, roomId);
});
