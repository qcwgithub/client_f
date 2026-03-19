import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_seq_generator.dart';
import 'package:scene_hub/logic/events/chat_rfresh_status.dart'
    show ChatRefreshStatus;
import 'package:scene_hub/logic/managers/chat_message_manager.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

enum ChatMessagesStatus { idle, refreshing, refreshError }

class ChatMessagesModel {
  final List<ClientChatMessage> messages;
  final ChatMessagesStatus status;
  int minSeq = 0;
  int maxSeq = 0;
  int serverMessageCount = 0;
  // 索引：seq -> list index
  final Map<int, int> _seqIndex = {};
  // 索引：clientSeq -> list index
  final Map<int, int> _clientSeqIndex = {};

  ChatMessagesModel({required this.messages, required this.status}) {
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];

      // 不论是否自己
      _clientSeqIndex[message.clientSeq] = i;

      if (message.seq > 0) {
        _seqIndex[message.seq] = i;

        if (minSeq == 0) {
          minSeq = message.seq;
        }
        maxSeq = message.seq;

        serverMessageCount++;
      }
    }
  }

  bool hasMore = true;

  factory ChatMessagesModel.initial() {
    return ChatMessagesModel(messages: [], status: ChatMessagesStatus.idle);
  }

  ChatMessagesModel copyWith({
    List<ClientChatMessage>? messages,
    ChatMessagesStatus? status,
  }) {
    return ChatMessagesModel(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }

  int findMessageIndex(bool useClientId, int seq, bool logErrorIfNotExist) {
    final index = useClientId ? _clientSeqIndex[seq] : _seqIndex[seq];
    if (index != null) return index;
    if (logErrorIfNotExist) {
      sc.logger.e("findMessage failed, useClientId $useClientId seq $seq");
    }
    return -1;
  }

  ClientChatMessage getMessageAt(int index) {
    return messages[index];
  }
}

abstract class ChatMessagesNotifier extends StateNotifier<ChatMessagesModel> {
  final ChatMessageManager manager;
  final int roomId;

  ChatMessagesNotifier(this.manager, this.roomId)
    : super(ChatMessagesModel.initial()) {
    manager.messagesCleared.on(_onChatCleared);
    manager.chatRefreshStatusChanged.on(_onRefreshStatus);
    manager.messagesAdded.on(_onMessagesAdded);

    _initialLoad();
  }

  Future<void> _initialLoad() async {
    var messages = await manager.initialLoadMessages(roomId, _loadBatchSize);
    _onMessagesAdded(messages);
  }

  @override
  void dispose() {
    manager.messagesCleared.off(_onChatCleared);
    manager.chatRefreshStatusChanged.off(_onRefreshStatus);
    manager.messagesAdded.off(_onMessagesAdded);
    manager.unloadMessages(roomId);

    super.dispose();
  }

  void _onChatCleared() {
    state = ChatMessagesModel.initial();
  }

  void _onRefreshStatus(ChatRefreshStatus status) {
    switch (status) {
      case ChatRefreshStatus.refreshing:
        state = state.copyWith(status: ChatMessagesStatus.refreshing);
        break;
      case ChatRefreshStatus.success:
        state = state.copyWith(status: ChatMessagesStatus.idle);
        break;
      case ChatRefreshStatus.error:
        state = state.copyWith(status: ChatMessagesStatus.refreshError);
        break;
    }
  }

  void _onMessagesAdded(List<ChatMessage> messages) {
    final roomMessages = messages.where((m) => m.roomId == roomId).toList();
    if (roomMessages.isEmpty) return;

    final updatedMessages = [...state.messages];

    bool hasOlder = false;
    if (updatedMessages.isEmpty) {
      hasOlder = false;
    } else {
      hasOlder = roomMessages.first.seq < updatedMessages.first.seq;
    }

    int delta = 0;
    for (final inner in roomMessages) {
      final result = _upsertIntoList(updatedMessages, inner);
      if (result) delta++;
    }

    if (delta > 0) {
      if (!hasOlder && _shouldTrim(state.serverMessageCount + delta)) {
        _trimOldest(updatedMessages);
      }
      state = state.copyWith(messages: updatedMessages);
    }
  }

  // ---- 消息窗口管理 ----

  static const int _maxServerMessages = 10000;
  static const int _loadBatchSize = 200;
  static const int _trimOnceCount = 1000;

  bool _shouldTrim(int serverMessageCount) {
    return serverMessageCount >= _maxServerMessages;
  }

  void _trimOldest(List<ClientChatMessage> list) {
    // sc.logger.e("_trimOldest, before: [${list.first.seq}, ${list.last.seq}]");

    int removed = 0;
    list.removeWhere((m) {
      if (removed >= _trimOnceCount) return false;
      if (m.useClientSeq) return false;
      removed++;
      return true;
    });

    // sc.logger.e("_trimOldest, after: [${list.first.seq}, ${list.last.seq}]");
  }

  void _trimNewest(List<ClientChatMessage> list) {
    // sc.logger.e("_trimNewest, before: [${list.first.seq}, ${list.last.seq}]");

    int removed = 0;
    for (int i = list.length - 1; i >= 0 && removed < _trimOnceCount; i--) {
      if (!list[i].useClientSeq) {
        list.removeAt(i);
        removed++;
      }
    }

    // sc.logger.e("_trimNewest, after: [${list.first.seq}, ${list.last.seq}]");
  }

  /// 将服务器消息插入或更新到 [list] 中，返回是否有变更。
  bool _upsertIntoList(List<ClientChatMessage> list, ChatMessage inner) {
    // 先按 seq 查是否已存在
    for (int i = 0; i < list.length; i++) {
      if (!list[i].useClientSeq && list[i].seq == inner.seq) {
        // 已存在，替换
        list[i] = ClientChatMessage.server(inner: inner);
        return true;
      }
    }
    // 再按 clientSeq 查是否是自己发的 sending 态消息
    if (sc.me.isMe(inner.senderId) && inner.clientSeq != 0) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].useClientSeq && list[i].clientSeq == inner.clientSeq) {
          list[i] = ClientChatMessage.server(inner: inner);
          return true;
        }
      }
    }
    // 不存在，按 seq 顺序插入
    final newMessage = ClientChatMessage.server(inner: inner);
    int insertIndex = list.length;
    for (int i = 0; i < list.length; i++) {
      if (list[i].seq > inner.seq) {
        insertIndex = i;
        break;
      }
    }
    list.insert(insertIndex, newMessage);
    return true;
  }

  // ---- 消息操作 ----

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
    ChatMessageImageContent? imageContent, {
    int replyTo = 0,
  }) {
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
    return ClientChatMessage.client(
      inner: inner,
      clientStatus: ClientChatMessageStatus.sending,
    );
  }

  Future<bool> requestSendChat(ClientChatMessage message) {
    return manager.requestSendChat(message.inner);
  }

  Future<void> sendChat(
    ChatMessageType type,
    String content,
    ChatMessageImageContent? imageContent, {
    int replyTo = 0,
  }) async {
    ClientChatMessage message = _createSending(
      roomId,
      type,
      content,
      imageContent,
      replyTo: replyTo,
    );
    _addMessage(message);

    bool success = await requestSendChat(message);
    if (success) return; // 成功由 stream 消息处理

    int index = state.findMessageIndex(true, message.clientSeq, false);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
    );
  }

  Future<void> resendChat(int clientSeq) async {
    int index = state.findMessageIndex(true, clientSeq, false);
    if (index < 0) return;

    ClientChatMessage message = _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.sending),
    );

    bool success = await requestSendChat(message);
    if (success) return; // 成功由 stream 消息处理

    index = state.findMessageIndex(true, clientSeq, true);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
    );
  }

  Future<void> loadOlderMessages() async {
    if (state.minSeq <= 1) return;

    // 先不干这个事了，演示一个 bug
    // 1、用户查看旧消息，导致这里 trim new
    // 2、后面又要查看新消息，那里 loadNewerMessages，新出来的消息会一次性显示到尾部，不连续了
    // 也就是说只 trim old
    // if (_shouldTrim(state.serverMessageCount)) {
    //   final trimmed = [...state.messages];
    //   _trimNewest(trimmed);
    //   state = state.copyWith(messages: trimmed);
    // }

    await manager.loadOlderMessages(roomId, state.minSeq, _loadBatchSize);
  }

  Future<void> loadNewerMessages() async {
    if (_shouldTrim(state.serverMessageCount)) {
      final trimmed = [...state.messages];
      _trimOldest(trimmed);
      state = state.copyWith(messages: trimmed);
    }

    await manager.loadNewerMessages(roomId, state.maxSeq, _loadBatchSize);
  }
}
