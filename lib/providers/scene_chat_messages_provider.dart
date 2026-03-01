import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_scene_chat_history.dart';
import 'package:scene_hub/gen/msg_send_scene_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_scene_chat_history.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_seq_generator.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/providers/chat_messages_notifier.dart';
import 'package:scene_hub/sc.dart';

class SceneChatMessagesNotifier extends StateNotifier<ChatMessagesModel> {
  final int roomId;
  StreamSubscription<ChatMessage>? _subscription;
  final List<int> _clientSeqs = [];
  SceneChatMessagesNotifier(this.roomId) : super(ChatMessagesModel.initial()) {
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

    if (sc.me.isMe(inner.senderId) && _clientSeqs.contains(inner.clientSeq)) {
      final index = state.findMessageIndex(true, inner.clientSeq, true);
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
    state = ChatMessagesModel(
      messages: messages,
      status: ChatMessagesStatus.idle,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
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
    int clientSeq = clientSeqGenerator.nextId();
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
      clientSeq: clientSeq,
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
        clientSeq: message.clientSeq,
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
    _clientSeqs.add(message.clientSeq);
    _addMessage(message);

    bool success = await _requestSendChat(roomId, message);
    int index = state.findMessageIndex(true, message.clientSeq, true);
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

  Future<void> resendChat(int clientSeq) async {
    int index = state.findMessageIndex(true, clientSeq, true);
    if (index <= 0) {
      return;
    }

    ClientChatMessage message = _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.sending),
    );

    bool success = await _requestSendChat(roomId, message);
    index = state.findMessageIndex(true, clientSeq, true);

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
      if (!state.messages[i].useClientSeq) {
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
      "requestHistory ok, got seqs ${res.history.map((m) => m.seq).toList()}",
    );

    final history = res.history
        .map((m) => ClientChatMessage.server(inner: m))
        .toList();

    beforeChangeState();

    state = state.copyWith(
      messages: [...history, ...state.messages],
      status: ChatMessagesStatus.idle,
    );

    return true;
  }
}

final sceneChatMessagesProvider =
    StateNotifierProvider.family<
      SceneChatMessagesNotifier,
      ChatMessagesModel,
      int
    >((ref, roomId) {
      final notifier = SceneChatMessagesNotifier(roomId);
      return notifier;
    });
