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
import 'package:scene_hub/gen/user_info.dart';
import 'package:scene_hub/logic/events/friend_chat_refresh_event.dart';
import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/sc.dart';

class FriendChatMessageManager {
  final _controller1 = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get stream1 => _controller1.stream;

  final _controller2 = StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get stream2 => _controller2.stream;

  UserInfo get userInfo => sc.me.userInfo;

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
    sc.eventBus.fire(
      FriendChatRefreshEvent(FriendChatRefreshStatus.refreshing),
    );

    final r = await sc.server.request(
      MsgType.receiveFriendChatMessages,
      MsgReceiveFriendChatMessages(),
    );

    if (r.e == ECode.success) {
      final res = ResReceiveFriendChatMessages.fromMsgPack(r.res!);
      sc.chatMessageStorage.upsertMessages(res.messages);
      _controller2.add(res.messages);
      sc.eventBus.fire(FriendChatRefreshEvent(FriendChatRefreshStatus.success));
    } else {
      sc.eventBus.fire(FriendChatRefreshEvent(FriendChatRefreshStatus.error));
    }
  }

  Future<void> loadFromStorage(int roomId) async {
    final messages = await sc.chatMessageStorage.getMessages(roomId);
    _controller2.add(messages);
  }

  Future<bool> requestSendChat(ChatMessage message, int friendUserId) async {
    final r = await sc.server.request(
      MsgType.sendFriendChat,
      MsgSendFriendChat(
        friendUserId: friendUserId,
        chatMessageType: message.type,
        content: message.content,
        clientMessageId: message.clientSeq,
        imageContent: message.imageContent,
      ),
    );

    if (r.e == ECode.success) {
      final res = ResSendFriendChat.fromMsgPack(r.res as List);
      sc.chatMessageStorage.upsertMessage(res.message);
      _controller1.add(message);
      return true;
    }
    return false;
  }

  // 收到服务器主动推送的消息
  final Map<int, int> _receivedSeqMap = {};
  void onMsgAChatMessage(MsgAChatMessage msg, FriendInfo friendInfo) {
    ChatMessage message = msg.message;

    sc.chatMessageStorage.upsertMessage(message);
    _controller1.add(message);

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
