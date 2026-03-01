import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/msg_receive_friend_chat_messages.dart';
import 'package:scene_hub/gen/msg_send_friend_chat.dart';
import 'package:scene_hub/gen/msg_set_friend_chat_read_seq.dart';
import 'package:scene_hub/gen/msg_set_friend_chat_received_seq.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_receive_friend_chat_messages.dart';
import 'package:scene_hub/gen/res_send_friend_chat.dart';
import 'package:scene_hub/gen/res_set_friend_chat_read_seq.dart';
import 'package:scene_hub/gen/res_set_friend_chat_received_seq.dart';
import 'package:scene_hub/logic/events/friend_chat_refresh_event.dart';
import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/logic/managers/chat_message_manager.dart';
import 'package:scene_hub/sc.dart';

class FriendChatMessageManager extends ChatMessageManager {
  StreamSubscription<LoginEvent>? _loginSub;
  void init() {
    _loginSub = sc.eventBus.on<LoginEvent>().listen(_onLogin);
  }

  Future<void> firstLoginReceive() async {
    await _requestReceiveFriendChatMessages();
  }

  Future<void> onQuit() async {
    await _loginSub?.cancel();
    _loginSub = null;
  }

  void _onLogin(LoginEvent event) async {
    if (event.count > 1) {
      await _requestReceiveFriendChatMessages();
    }
  }

  Future<void> _requestReceiveFriendChatMessages() async {
    sc.eventBus.emit(
      FriendChatRefreshEvent(FriendChatRefreshStatus.refreshing),
    );

    final r = await sc.server.request(
      MsgType.receiveFriendChatMessages,
      MsgReceiveFriendChatMessages(),
    );

    if (r.e == ECode.success) {
      final res = ResReceiveFriendChatMessages.fromMsgPack(r.res!);
      if (res.messages.isNotEmpty) {
        sc.chatMessageStorage.upsertMessages(res.messages);
        controllerAdd(res.messages);
        sc.eventBus.emit(
          FriendChatRefreshEvent(FriendChatRefreshStatus.success),
        );
      }
    } else {
      sc.eventBus.emit(FriendChatRefreshEvent(FriendChatRefreshStatus.error));
    }
  }

  @override
  Future<void> initialLoad(int roomId, int count) async {
    final messages = await sc.chatMessageStorage.getMessages(
      roomId,
      limit: count,
    );
    if (messages.isNotEmpty) {
      controllerAdd(messages);
    }
  }

  @override
  Future<void> loadOlderMessages(int roomId, int beforeSeq, int count) async {
    final messages = await sc.chatMessageStorage.getMessagesBefore(
      roomId,
      beforeSeq,
      limit: count,
    );
    if (messages.isNotEmpty) {
      controllerAdd(messages);
    }
  }

  @override
  Future<void> loadNewerMessages(int roomId, int afterSeq, int count) async {
    final messages = await sc.chatMessageStorage.getMessagesAfter(
      roomId,
      afterSeq,
      limit: count,
    );
    if (messages.isNotEmpty) {
      controllerAdd(messages);
    }
  }

  @override
  Future<bool> requestSendChat(ChatMessage message) async {
    final friendInfo = sc.friendManager.getFriendByRoomId(message.roomId);
    if (friendInfo == null) {
      sc.logger.d("未找到好友信息，无法发送消息，roomId: ${message.roomId}");
      return false;
    }

    final r = await sc.server.request(
      MsgType.sendFriendChat,
      MsgSendFriendChat(
        friendUserId: friendInfo.userId,
        chatMessageType: message.type,
        content: message.content,
        clientSeq: message.clientSeq,
        imageContent: message.imageContent,
      ),
    );

    if (r.e == ECode.success) {
      final res = ResSendFriendChat.fromMsgPack(r.res as List);
      sc.chatMessageStorage.upsertMessage(res.message);
      controllerAdd([res.message]);
      return true;
    }

    return false;
  }

  // 收到服务器主动推送的消息
  final Map<int, int> _receivedSeqMap = {};
  void onMsgAChatMessage(MsgAChatMessage msg, FriendInfo friendInfo) {
    ChatMessage message = msg.message;

    sc.chatMessageStorage.upsertMessage(message);
    controllerAdd([message]);

    int friendUserId = friendInfo.userId;
    int seq = message.seq;
    if (seq > friendInfo.receivedSeq) {
      if (_receivedSeqMap[friendUserId] == null ||
          seq > _receivedSeqMap[friendUserId]!) {
        _receivedSeqMap[friendUserId] = seq;
        _tryRegisterPostFrameCallback();
      }
    }
  }

  // Post Frame Callback

  bool _registeredPostFrameCallback = false;
  void _tryRegisterPostFrameCallback() {
    if (_registeredPostFrameCallback) {
      return;
    }
    _registeredPostFrameCallback = true;
    SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
  }

  void _postFrameCallback(Duration timeStamp) {
    _registeredPostFrameCallback = false;

    //
    _receivedSeqMap.forEach((friendUserId, receivedSeq) {
      _requestSetReceivedSeq(friendUserId, receivedSeq);
    });
    _receivedSeqMap.clear();

    //
    _readSeqMap.forEach((friendUserId, readSeq) {
      _requestSetReadSeq(friendUserId, readSeq);
    });
    _readSeqMap.clear();
  }

  void _requestSetReceivedSeq(int friendUserId, int receivedSeq) async {
    final r = await sc.server.request(
      MsgType.setFriendChatReceivedSeq,
      MsgSetFriendChatReceivedSeq(
        friendUserId: friendUserId,
        receivedSeq: receivedSeq,
      ),
    );

    if (r.e == ECode.success) {
      final res = ResSetFriendChatReceivedSeq.fromMsgPack(r.res!);
      sc.friendManager.getFriend(friendUserId)?.receivedSeq = res.receivedSeq;
    }
  }

  void _requestSetReadSeq(int friendUserId, int readSeq) async {
    final r = await sc.server.request(
      MsgType.setFriendChatReadSeq,
      MsgSetFriendChatReadSeq(friendUserId: friendUserId, readSeq: readSeq),
    );
    if (r.e == ECode.success) {
      final res = ResSetFriendChatReadSeq.fromMsgPack(r.res!);
      sc.friendManager.getFriend(friendUserId)?.readSeq = res.readSeq;
    }
  }

  // 上报 read seq

  final Map<int, int> _readSeqMap = {};
  void onMessageViewed(int friendUserId, int seq) {
    final FriendInfo? friendInfo = sc.friendManager.getFriend(friendUserId);
    if (friendInfo != null && seq > friendInfo.readSeq) {
      if (_readSeqMap[friendUserId] == null ||
          seq > _readSeqMap[friendUserId]!) {
        _readSeqMap[friendUserId] = seq;
        _tryRegisterPostFrameCallback();
      }
    }
  }
}
