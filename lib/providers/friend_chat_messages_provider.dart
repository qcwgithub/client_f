import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

enum FriendChatMessagesStatus { idle, refreshing, refreshError }

class FriendChatMessagesModel {
  final List<ClientChatMessage> messages;
  final FriendChatMessagesStatus status;
  // 索引：seq -> list index
  final Map<int, int> _seqIndex;
  // 索引：clientMessageId -> list index
  final Map<int, int> _clientIdIndex;
  FriendChatMessagesModel({required this.messages, required this.status})
    : _seqIndex = {},
      _clientIdIndex = {} {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].useClientId) {
        _clientIdIndex[messages[i].clientMessageId] = i;
      } else {
        _seqIndex[messages[i].seq] = i;
      }
    }
  }

  bool hasMore = true;

  factory FriendChatMessagesModel.initial() {
    return FriendChatMessagesModel(
      messages: [],
      status: FriendChatMessagesStatus.idle,
    );
  }

  FriendChatMessagesModel copyWith({
    List<ClientChatMessage>? messages,
    FriendChatMessagesStatus? status,
  }) {
    return FriendChatMessagesModel(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }

  int findMessageIndex(
    bool useClientId,
    int messageId,
    bool logErrorIfNotExist,
  ) {
    final index = useClientId
        ? _clientIdIndex[messageId]
        : _seqIndex[messageId];
    if (index != null) return index;
    if (logErrorIfNotExist) {
      sc.logger.e(
        "findMessage failed, useClientId $useClientId messageId $messageId",
      );
    }
    return -1;
  }

  ClientChatMessage getMessageAt(int index) {
    return messages[index];
  }
}

class FriendChatMessagesNotifier
    extends StateNotifier<FriendChatMessagesModel> {
  final int friendUserId;
  final int roomId;
  StreamSubscription<ChatMessage>? _sub1;
  StreamSubscription<List<ChatMessage>>? _sub2;
  final List<int> _clientMessageIds = [];

  FriendChatMessagesNotifier(this.friendUserId, this.roomId)
    : super(FriendChatMessagesModel.initial()) {
    _sub1 = sc.friendChatMessageManager.stream1.listen(_onChatMessage);
    _sub2 = sc.friendChatMessageManager.stream2.listen(_onChatMessages);
    sc.friendChatMessageManager.loadFromStorage(roomId);
  }

  @override
  void dispose() {
    _sub1?.cancel();
    _sub1 = null;
    _sub2?.cancel();
    _sub2 = null;
    super.dispose();
  }

  void _onChatMessages(List<ChatMessage> messages) {
    final roomMessages = messages.where((m) => m.roomId == roomId).toList();
    if (roomMessages.isEmpty) return;

    final updatedMessages = [...state.messages];
    bool changed = false;

    for (final inner in roomMessages) {
      final result = _upsertIntoList(updatedMessages, inner);
      if (result) changed = true;
    }

    if (changed) {
      state = state.copyWith(messages: updatedMessages);
    }
  }

  void _onChatMessage(ChatMessage inner) {
    if (inner.roomId != roomId) return;

    final updatedMessages = [...state.messages];
    if (_upsertIntoList(updatedMessages, inner)) {
      state = state.copyWith(messages: updatedMessages);
    }
  }

  /// 将服务器消息插入或更新到 [list] 中，返回是否有变更。
  bool _upsertIntoList(List<ClientChatMessage> list, ChatMessage inner) {
    // 先按 seq 查是否已存在
    for (int i = 0; i < list.length; i++) {
      if (!list[i].useClientId && list[i].seq == inner.seq) {
        // 已存在，替换
        list[i] = ClientChatMessage.server(inner: inner);
        return true;
      }
    }
    // 再按 clientMessageId 查是否是自己发的 sending 态消息
    if (sc.me.isMe(inner.senderId) && inner.clientMessageId != 0) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].useClientId &&
            list[i].clientMessageId == inner.clientMessageId) {
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

  // 目前只用于添加客户端新的发送消息
  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  // 目前只用于更新客户端发送消息的状态 sending -> failed -> sending ->...，不包括 normal
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

    return sc.friendChatMessageManager.requestSendChat(
      message.inner,
      friendUserId,
    );
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
    if (success) return; // 成功由 stream 消息处理

    int index = state.findMessageIndex(true, message.clientMessageId, true);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
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
    if (success) return; // 成功由 stream 消息处理

    index = state.findMessageIndex(true, clientMessageId, true);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
    );
  }
}

/// key: friendUserId
final friendChatMessagesProvider =
    StateNotifierProvider.family<
      FriendChatMessagesNotifier,
      FriendChatMessagesModel,
      (int, int)
    >((ref, params) {
      final (int friendUserId, int roomId) = params;
      return FriendChatMessagesNotifier(friendUserId, roomId);
    });
