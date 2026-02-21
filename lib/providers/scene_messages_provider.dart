import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/msg_get_scene_chat_history.dart';
import 'package:scene_hub/gen/msg_send_scene_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_scene_chat_history.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/event_bus.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/my_logger.dart';
import 'package:scene_hub/sc.dart';

enum SceneMessagesStatus { idle, refreshing, success, empty, error }

class SceneMessagesModel {
  final List<ClientChatMessage> messages;
  final SceneMessagesStatus status;
  SceneMessagesModel({required this.messages, required this.status});

  bool hasMore = true;

  factory SceneMessagesModel.initial() {
    return SceneMessagesModel(messages: [], status: SceneMessagesStatus.idle);
  }

  SceneMessagesModel copyWith({
    List<ClientChatMessage>? messages,
    SceneMessagesStatus? status,
  }) {
    return SceneMessagesModel(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }

  // TODO
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
        if (!message.useClientId && message.messageId == messageId) {
          return i;
        }
      }
    }
    if (logErrorIfNotExist) {
      logger.e(
        "findMessage failed, userClientId $useClientId messageId $messageId",
      );
    }
    return -1;
  }

  ClientChatMessage getMessageAt(int index) {
    return messages[index];
  }
}

class SceneMessagesNotifier extends StateNotifier<SceneMessagesModel> {
  final int roomId;
  StreamSubscription<MsgAChatMessage>? _aChatSubscription;
  final List<int> _clientMessageIds = [];
  SceneMessagesNotifier(this.roomId) : super(SceneMessagesModel.initial()) {
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
    state = SceneMessagesModel(
      messages: messages,
      status: messages.isEmpty
          ? SceneMessagesStatus.empty
          : SceneMessagesStatus.success,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      status: state.status == SceneMessagesStatus.empty
          ? SceneMessagesStatus.success
          : state.status,
    );
  }

  void _updateMessageAt(
    int index,
    ClientChatMessage Function(ClientChatMessage) newMessageFunc,
  ) {
    final message = state.messages[index];

    final newMessage = newMessageFunc(message);
    state = state.copyWith(messages: [...state.messages]..[index] = newMessage);
  }

  static ClientChatMessage _createSending(
    int roomId,
    ChatMessageType type,
    String content,
    int replyTo,
    ChatMessageImageContent? imageContent,
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
      imageContent: imageContent,
    );
    final message = ClientChatMessage.client(
      inner: inner,
      clientStatus: ClientChatMessageStatus.sending,
    );

    return message;
  }

  static Future<bool> _requestSendChat(
    int roomId,
    ClientChatMessage message,
  ) async {
    assert(message.clientStatus == ClientChatMessageStatus.sending);

    final r = await sc.server.request(
      MsgType.sendSceneChat,
      MsgSendSceneChat(
        roomId: roomId,
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

    // final res = ResSendRoomChat.fromMsgPack(r.res!);
    return true;
  }

  Future<void> sendChat(
    ChatMessageType type,
    String content,
    int replyTo,
    ChatMessageImageContent? imageContent,
  ) async {
    ClientChatMessage message = _createSending(
      roomId,
      type,
      content,
      replyTo,
      imageContent,
    );
    _clientMessageIds.add(message.clientMessageId);
    _addMessage(message);

    bool success = await _requestSendChat(roomId, message);
    int index = state.findMessageIndex(true, message.clientMessageId, true);
    if (index < 0) {
      return;
    }

    _updateMessageAt(
      index,
      (m) => m.copyWith(
        clientStatus: success
            ? ClientChatMessageStatus.normal
            : ClientChatMessageStatus.failed,
      ),
    );
  }

  Future<void> resendChat(ClientChatMessage message) async {
    int index = state.findMessageIndex(true, message.clientMessageId, true);
    if (index <= 0) {
      return;
    }

    _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.sending),
    );

    bool success = await _requestSendChat(roomId, message);
    index = state.findMessageIndex(true, message.clientMessageId, true);

    _updateMessageAt(
      index,
      (m) => m.copyWith(
        clientStatus: success
            ? ClientChatMessageStatus.normal
            : ClientChatMessageStatus.failed,
      ),
    );
  }

  Future<bool> requestHistory(VoidCallback beforeChangeState) async {
    if (!state.hasMore) {
      logger.d("!hasMore");
      return false;
    }

    int lastMessageId = 0;
    for (int i = 0; i < state.messages.length; i++) {
      if (!state.messages[i].useClientId) {
        lastMessageId = state.messages[i].messageId;
        break;
      }
    }

    final r = await sc.server.request(
      MsgType.getSceneChatHistory,
      MsgGetSceneChatHistory(roomId: roomId, lastMessageId: lastMessageId),
    );

    if (r.e != ECode.success) {
      return false;
    }

    final res = ResGetSceneChatHistory.fromMsgPack(r.res!);
    if (res.history.isEmpty) {
      state.hasMore = false;
      return false;
    }

    logger.d(
      "requestHistory ok, got messageIds ${res.history.map((m) => m.messageId).toList()}",
    );

    final history = res.history
        .map((m) => ClientChatMessage.server(inner: m))
        .toList();

    beforeChangeState();

    state = state.copyWith(
      messages: [...history, ...state.messages],
      status: SceneMessagesStatus.idle,
    );

    return true;
  }
}

final sceneMessagesProvider =
    StateNotifierProvider.family<
      SceneMessagesNotifier,
      SceneMessagesModel,
      int
    >((ref, roomId) {
      final notifier = SceneMessagesNotifier(roomId);
      return notifier;
    });
