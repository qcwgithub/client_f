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
import 'package:scene_hub/sc.dart';

enum SceneChatMessagesStatus { idle, refreshing, success, empty, error }

class SceneChatMessagesModel {
  final List<ClientChatMessage> messages;
  final SceneChatMessagesStatus status;
  SceneChatMessagesModel({required this.messages, required this.status});

  bool hasMore = true;

  factory SceneChatMessagesModel.initial() {
    return SceneChatMessagesModel(messages: [], status: SceneChatMessagesStatus.idle);
  }

  SceneChatMessagesModel copyWith({
    List<ClientChatMessage>? messages,
    SceneChatMessagesStatus? status,
  }) {
    return SceneChatMessagesModel(
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
        if (!message.useClientId && message.seq == messageId) {
          return i;
        }
      }
    }
    if (logErrorIfNotExist) {
      sc.logger.e(
        "findMessage failed, userClientId $useClientId messageId $messageId",
      );
    }
    return -1;
  }

  ClientChatMessage getMessageAt(int index) {
    return messages[index];
  }
}

class SceneChatMessagesNotifier extends StateNotifier<SceneChatMessagesModel> {
  final int roomId;
  StreamSubscription<ChatMessage>? _subscription;
  final List<int> _clientMessageIds = [];
  SceneChatMessagesNotifier(this.roomId) : super(SceneChatMessagesModel.initial()) {
    _subscription = sc.sceneChatMessageManager.stream.listen(_onChatMessage);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  void _onChatMessage(ChatMessage inner) {
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
    state = SceneChatMessagesModel(
      messages: messages,
      status: messages.isEmpty
          ? SceneChatMessagesStatus.empty
          : SceneChatMessagesStatus.success,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      status: state.status == SceneChatMessagesStatus.empty
          ? SceneChatMessagesStatus.success
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
    ChatMessageType type,
    String content,
    int replyTo,
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

  Future<void> resendChat(int clientMessageId) async {
    int index = state.findMessageIndex(true, clientMessageId, true);
    if (index <= 0) {
      return;
    }

    ClientChatMessage message = _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.sending),
    );

    bool success = await _requestSendChat(roomId, message);
    index = state.findMessageIndex(true, clientMessageId, true);

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
      sc.logger.d("!hasMore");
      return false;
    }

    int lastSeq = 0;
    for (int i = 0; i < state.messages.length; i++) {
      if (!state.messages[i].useClientId) {
        lastSeq = state.messages[i].seq;
        break;
      }
    }

    final r = await sc.server.request(
      MsgType.getSceneChatHistory,
      MsgGetSceneChatHistory(roomId: roomId, lastSeq: lastSeq),
    );

    if (r.e != ECode.success) {
      return false;
    }

    final res = ResGetSceneChatHistory.fromMsgPack(r.res!);
    if (res.history.isEmpty) {
      state.hasMore = false;
      return false;
    }

    sc.logger.d(
      "requestHistory ok, got messageIds ${res.history.map((m) => m.seq).toList()}",
    );

    final history = res.history
        .map((m) => ClientChatMessage.server(inner: m))
        .toList();

    beforeChangeState();

    state = state.copyWith(
      messages: [...history, ...state.messages],
      status: SceneChatMessagesStatus.idle,
    );

    return true;
  }
}

final sceneChatMessagesProvider =
    StateNotifierProvider.family<
      SceneChatMessagesNotifier,
      SceneChatMessagesModel,
      int
    >((ref, roomId) {
      final notifier = SceneChatMessagesNotifier(roomId);
      return notifier;
    });
