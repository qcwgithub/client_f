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
import 'package:scene_hub/logic/events/chat_refresh_event.dart';
import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/logic/managers/chat_message_manager.dart';
import 'package:scene_hub/sc.dart';

class FriendChatMessageManager extends ChatMessageManager {
  void init() {
    sc.eventBus.on<LoginEvent>().listen(_onLogin);
  }

  Future<void> onQuit() async {
    _toReportReceivedSeqs.clear();
    _toReportReadSeqs.clear();
    _registeredPostFrameCallback = false;
  }

  void _onLogin(LoginEvent event) async {
    if (event.count > 1) {
      await requestReceiveFriendChatMessages();
    }
  }

  Future<void> requestReceiveFriendChatMessages() async {
    sc.eventBus.emit(ChatRefreshEvent(ChatRefreshStatus.refreshing));

    final r = await sc.server.request(
      MsgType.receiveFriendChatMessages,
      MsgReceiveFriendChatMessages(),
    );

    if (r.e == ECode.success) {
      final res = ResReceiveFriendChatMessages.fromMsgPack(r.res!);
      if (res.messages.isNotEmpty) {
        sc.chatMessageStorage.upsertMessages(res.messages);
        controllerAdd(res.messages);
        sc.eventBus.emit(ChatRefreshEvent(ChatRefreshStatus.success));
      }
    } else {
      sc.eventBus.emit(ChatRefreshEvent(ChatRefreshStatus.error));
    }
  }

  @override
  Future<void> initialLoadMessages(int roomId, int count) async {
    final messages = await sc.chatMessageStorage.getMessages(
      roomId,
      limit: count,
    );
    controllerAdd(messages);
  }

  @override
  Future<void> unloadMessages(int roomId) async {}

  @override
  Future<void> loadOlderMessages(int roomId, int beforeSeq, int count) async {
    final messages = await sc.chatMessageStorage.getMessagesBefore(
      roomId,
      beforeSeq,
      limit: count,
    );
    controllerAdd(messages);
  }

  @override
  Future<void> loadNewerMessages(int roomId, int afterSeq, int count) async {
    final messages = await sc.chatMessageStorage.getMessagesAfter(
      roomId,
      afterSeq,
      limit: count,
    );
    controllerAdd(messages);
  }

  @override
  Future<bool> requestSendChat(ChatMessage message) async {
    final friendInfo = sc.friendManager.getFriendByRoomId(message.roomId);
    if (friendInfo == null) {
      sc.logger.e("未找到好友信息，无法发送消息，roomId: ${message.roomId}");
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
  final Map<int, int> _toReportReceivedSeqs = {};
  void onMsgAChatMessage(MsgAChatMessage msg, FriendInfo friendInfo) {
    ChatMessage message = msg.message;

    sc.chatMessageStorage.upsertMessage(message);
    controllerAdd([message]);

    int friendUserId = friendInfo.userId;
    int seq = message.seq;
    if (seq > friendInfo.receivedSeq) {
      if (_toReportReceivedSeqs[friendUserId] == null ||
          seq > _toReportReceivedSeqs[friendUserId]!) {
        _toReportReceivedSeqs[friendUserId] = seq;
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
    if (_toReportReceivedSeqs.isNotEmpty) {
      _toReportReceivedSeqs.forEach((friendUserId, receivedSeq) {
        _requestSetReceivedSeq(friendUserId, receivedSeq);
      });
    }

    //
    if (_toReportReadSeqs.isNotEmpty) {
      _toReportReadSeqs.forEach((friendUserId, readSeq) {
        _requestSetReadSeq(friendUserId, readSeq);

        final friendInfo = sc.friendManager.getFriend(friendUserId);
        if (friendInfo != null) {
          sc.conversationManager.tryUpdateReadSeq(friendInfo.roomId, readSeq);
        }
      });
    }
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

      final rrs = _toReportReceivedSeqs[friendUserId];
      if (rrs == null) {
        sc.logger.e(
          "上报 received seq 成功，但本地没有缓存的待上报 received seq，friendUserId: $friendUserId, receivedSeq: ${res.receivedSeq}",
        );
      } else if (res.receivedSeq >= rrs) {
        _toReportReceivedSeqs.remove(friendUserId);
      }
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

      final rrs = _toReportReadSeqs[friendUserId];
      if (rrs == null) {
        sc.logger.e(
          "上报 read seq 成功，但本地没有缓存的待上报 read seq，friendUserId: $friendUserId, readSeq: ${res.readSeq}",
        );
      } else if (res.readSeq >= rrs) {
        _toReportReadSeqs.remove(friendUserId);
      }
    }
  }

  // 上报 read seq

  final Map<int, int> _toReportReadSeqs = {};
  void onMessageViewed(int roomId, int seq) {
    final FriendInfo? friendInfo = sc.friendManager.getFriendByRoomId(roomId);
    if (friendInfo != null && seq > friendInfo.readSeq) {
      int friendUserId = friendInfo.userId;
      if (_toReportReadSeqs[friendUserId] == null ||
          seq > _toReportReadSeqs[friendUserId]!) {
        _toReportReadSeqs[friendUserId] = seq;
        _tryRegisterPostFrameCallback();
      }
    }
  }
}
