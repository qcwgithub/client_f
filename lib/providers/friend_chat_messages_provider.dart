import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/events/friend_chat_refresh_event.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

enum FriendChatMessagesStatus { idle, refreshing, refreshError }

class FriendChatMessagesModel {
  final List<ClientChatMessage> messages;
  final FriendChatMessagesStatus status;
  late int minSeq;
  late int maxSeq;
  // 索引：seq -> list index
  final Map<int, int> _seqIndex = {};
  // 索引：clientSeq -> list index
  final Map<int, int> _clientIdIndex = {};
  FriendChatMessagesModel({required this.messages, required this.status}) {
    minSeq = 0;
    maxSeq = 0;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.useClientSeq) {
        _clientIdIndex[message.clientSeq] = i;
      } else {
        _seqIndex[message.seq] = i;

        if (minSeq == 0) {
          minSeq = message.seq;
        }
        maxSeq = message.seq;
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

  int findMessageIndex(bool useClientId, int seq, bool logErrorIfNotExist) {
    final index = useClientId ? _clientIdIndex[seq] : _seqIndex[seq];
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

class FriendChatMessagesNotifier
    extends StateNotifier<FriendChatMessagesModel> {
  final int friendUserId;
  final int roomId;
  StreamSubscription<ChatMessage>? _sub1;
  StreamSubscription<List<ChatMessage>>? _sub2;
  StreamSubscription<FriendChatRefreshEvent>? _sub3;
  final List<int> _clientSeqs = [];

  FriendChatMessagesNotifier(this.friendUserId, this.roomId)
    : super(FriendChatMessagesModel.initial()) {
    _sub1 = sc.friendChatMessageManager.stream1.listen(_onChatMessage);
    _sub2 = sc.friendChatMessageManager.stream2.listen(_onChatMessages);
    _sub3 = sc.eventBus.on<FriendChatRefreshEvent>().listen(_onRefreshEvent);
    sc.friendChatMessageManager.initialLoad(roomId);
  }

  @override
  void dispose() {
    _sub1?.cancel();
    _sub1 = null;
    _sub2?.cancel();
    _sub2 = null;
    _sub3?.cancel();
    _sub3 = null;
    super.dispose();
  }

  void _onChatMessages(List<ChatMessage> messages) {
    final roomMessages = messages.where((m) => m.roomId == roomId).toList();
    if (roomMessages.isEmpty) return;

    final updatedMessages = [...state.messages];
    bool changed = false;

    for (final inner in roomMessages) {
      if (_isNewMessageOutOfRange(inner)) continue;
      final result = _upsertIntoList(updatedMessages, inner);
      if (result) changed = true;
    }

    if (changed) {
      _trimOldest(updatedMessages);
      state = state.copyWith(messages: updatedMessages);
    }
  }

  void _onChatMessage(ChatMessage inner) {
    if (inner.roomId != roomId) return;
    if (_isNewMessageOutOfRange(inner)) return;

    final updatedMessages = [...state.messages];
    if (_upsertIntoList(updatedMessages, inner)) {
      _trimOldest(updatedMessages);
      state = state.copyWith(messages: updatedMessages);
    }
  }

  void _onRefreshEvent(FriendChatRefreshEvent event) {
    switch (event.status) {
      case FriendChatRefreshStatus.refreshing:
        state = state.copyWith(status: FriendChatMessagesStatus.refreshing);
        break;
      case FriendChatRefreshStatus.success:
        state = state.copyWith(status: FriendChatMessagesStatus.idle);
        break;
      case FriendChatRefreshStatus.error:
        state = state.copyWith(status: FriendChatMessagesStatus.refreshError);
        break;
    }
  }

  // ---- 消息窗口管理 ----

  static const int _maxServerMessages = 5000;

  /// 判断消息是否在缓存范围外（seq < minSeq 且不是更新已有消息）
  bool _isNewMessageOutOfRange(ChatMessage inner) {
    if (state.minSeq == 0) return false; // 还没有消息，全部接受
    if (inner.seq >= state.minSeq) return false; // 在窗口内或更新
    // seq < minSeq，检查是否是更新已有消息
    if (state.findMessageIndex(false, inner.seq, false) >= 0) return false;
    if (sc.me.isMe(inner.senderId) &&
        inner.clientSeq != 0 &&
        state.findMessageIndex(true, inner.clientSeq, false) >= 0) {
      return false;
    }
    return true; // 超出缓存范围，丢弃
  }

  /// 从列表头部移除最旧的服务器消息，直到服务器消息数量 <= _maxServerMessages
  static void _trimOldest(List<ClientChatMessage> list) {
    int serverCount = 0;
    for (final m in list) {
      if (!m.useClientSeq) serverCount++;
    }
    if (serverCount <= _maxServerMessages) return;

    int toRemove = serverCount - _maxServerMessages;
    int removed = 0;
    list.removeWhere((m) {
      if (removed >= toRemove) return false;
      if (m.useClientSeq) return false;
      removed++;
      return true;
    });
  }

  /// 从列表尾部移除最新的服务器消息（保留客户端消息），直到服务器消息数量 <= _maxServerMessages
  static void _trimNewest(List<ClientChatMessage> list) {
    int serverCount = 0;
    for (final m in list) {
      if (!m.useClientSeq) serverCount++;
    }
    if (serverCount <= _maxServerMessages) return;

    int toRemove = serverCount - _maxServerMessages;
    int removed = 0;
    for (int i = list.length - 1; i >= 0 && removed < toRemove; i--) {
      if (!list[i].useClientSeq) {
        list.removeAt(i);
        removed++;
      }
    }
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
    int clientSeq = clientMessageIdGenerator.nextId();
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
      clientSeq: clientSeq,
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
    _clientSeqs.add(message.clientSeq);
    _addMessage(message);

    bool success = await _requestSendChat(message);
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

    bool success = await _requestSendChat(message);
    if (success) return; // 成功由 stream 消息处理

    index = state.findMessageIndex(true, clientSeq, true);
    if (index < 0) return;

    _updateMessageAt(
      index,
      (m) => m.copyWith(clientStatus: ClientChatMessageStatus.failed),
    );
  }

  Future<void> loadOlderMessages() async {
    if (state.minSeq <= 1) {
      return;
    }

    final messages = await sc.friendChatMessageManager.getOlderMessages(
      roomId,
      state.minSeq,
    );
    if (messages.isEmpty) return;

    final updatedMessages = [...state.messages];
    bool changed = false;
    for (final inner in messages) {
      if (_upsertIntoList(updatedMessages, inner)) changed = true;
    }
    if (changed) {
      _trimNewest(updatedMessages);
      state = state.copyWith(messages: updatedMessages);
    }
  }

  Future<void> loadNewerMessages() async {
    final messages = await sc.friendChatMessageManager.getNewerMessages(
      roomId,
      state.maxSeq,
    );
    if (messages.isEmpty) return;

    final updatedMessages = [...state.messages];
    bool changed = false;
    for (final inner in messages) {
      if (_upsertIntoList(updatedMessages, inner)) changed = true;
    }
    if (changed) {
      _trimOldest(updatedMessages);
      state = state.copyWith(messages: updatedMessages);
    }
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
