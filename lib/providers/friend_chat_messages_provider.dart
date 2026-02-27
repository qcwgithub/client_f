import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_set_friend_chat_received_seq.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_set_friend_chat_received_seq.dart';
import 'package:scene_hub/logic/client_chat_message.dart';
import 'package:scene_hub/logic/client_message_id_generator.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

enum FriendChatMessagesStatus { idle, refreshing, success, empty, error }

class FriendChatMessagesModel {
  final List<ClientChatMessage> messages;
  final FriendChatMessagesStatus status;
  FriendChatMessagesModel({required this.messages, required this.status});

  bool hasMore = true;

  factory FriendChatMessagesModel.initial() {
    return FriendChatMessagesModel(messages: [], status: FriendChatMessagesStatus.idle);
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
        "findMessage failed, useClientId $useClientId messageId $messageId",
      );
    }
    return -1;
  }

  ClientChatMessage getMessageAt(int index) {
    return messages[index];
  }
}

class FriendChatMessagesNotifier extends StateNotifier<FriendChatMessagesModel> {
  final int friendUserId;
  final int roomId;
  StreamSubscription<ChatMessage>? _subscription;
  final List<int> _clientMessageIds = [];

  FriendChatMessagesNotifier(this.friendUserId, this.roomId)
    : super(FriendChatMessagesModel.initial()) {
    _subscription = sc.friendChatMessageManager.stream.listen(_onChatMessage);
    _loadFromStorage();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  Future<void> _loadFromStorage() async {
    final chatMessages = await sc.friendChatMessageManager.loadFromStorage(
      roomId,
    );
    if (chatMessages.isEmpty) {
      state = state.copyWith(status: FriendChatMessagesStatus.empty);
      return;
    }
    final messages = chatMessages
        .map((m) => ClientChatMessage.server(inner: m))
        .toList();
    state = FriendChatMessagesModel(
      messages: messages,
      status: FriendChatMessagesStatus.success,
    );
  }

  void _onChatMessage(ChatMessage inner) async {
    if (inner.roomId != roomId) return;

    if (sc.me.isMe(inner.senderId) &&
        _clientMessageIds.contains(inner.clientMessageId)) {
      // 我发的 - 服务器冗余推送：更新内存中的消息状态
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
      // 别人发的消息（或我在其他设备发的）
      final message = ClientChatMessage.server(inner: inner);
      _addMessage(message);
    }

    var r = await sc.server.request(
      MsgType.setFriendChatReceivedSeq,
      MsgSetFriendChatReceivedSeq(
        friendUserId: friendUserId,
        receivedSeq: inner.seq,
      ),
    );
    if (r.e == ECode.success) {
      var res = ResSetFriendChatReceivedSeq.fromMsgPack(r.res!);
      sc.friendManager.getFriend(friendUserId)?.receivedSeq = res.receivedSeq;
    }
  }

  void setInitialMessages(List<ClientChatMessage> messages) {
    state = FriendChatMessagesModel(
      messages: messages,
      status: messages.isEmpty
          ? FriendChatMessagesStatus.empty
          : FriendChatMessagesStatus.success,
    );
  }

  void _addMessage(ClientChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      status: state.status == FriendChatMessagesStatus.empty
          ? FriendChatMessagesStatus.success
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

  Future<ChatMessage?> _requestSendChat(ClientChatMessage message) async {
    assert(message.clientStatus == ClientChatMessageStatus.sending);

    ChatMessage? serverMessage = await sc.friendChatMessageManager
        .requestSendChat(message.inner, friendUserId);
    return serverMessage;
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

    bool success = await _requestSendChat(message) != null;
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

    bool success = await _requestSendChat(message) != null;
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
final friendChatMessagesProvider =
    StateNotifierProvider.family<
      FriendChatMessagesNotifier,
      FriendChatMessagesModel,
      (int, int)
    >((ref, params) {
      final (int friendUserId, int roomId) = params;
      return FriendChatMessagesNotifier(friendUserId, roomId);
    });
