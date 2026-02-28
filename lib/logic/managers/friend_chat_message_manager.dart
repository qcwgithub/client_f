import 'dart:async';

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
import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/sc.dart';

class FriendChatMessageManager {
  final _controller = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get stream => _controller.stream;

  UserInfo get userInfo => sc.me.userInfo;

  StreamSubscription<LoginEvent>? _loginSub;
  void init() {
    _loginSub = sc.eventBus.on<LoginEvent>().listen(_onLogin);
  }

  Future<void> onFirstLogin() async {
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
    final r = await sc.server.request(
      MsgType.receiveFriendChatMessages,
      MsgReceiveFriendChatMessages(),
    );

    if (r.e == ECode.success) {
      final res = ResReceiveFriendChatMessages.fromMsgPack(r.res!);
      for (final message in res.messages) {
        sc.chatMessageStorage.upsertMessage(message);
        _controller.add(message);
      }
    }
  }

  Future<List<ChatMessage>> loadFromStorage(int roomId) async {
    final messages = await sc.chatMessageStorage.getMessages(roomId);
    return messages;
  }

  Future<ChatMessage?> requestSendChat(
    ChatMessage message,
    int friendUserId,
  ) async {
    final r = await sc.server.request(
      MsgType.sendFriendChat,
      MsgSendFriendChat(
        friendUserId: friendUserId,
        chatMessageType: message.type,
        content: message.content,
        clientMessageId: message.clientMessageId,
        imageContent: message.imageContent,
      ),
    );

    if (r.e != ECode.success) {
      return null;
    }

    final res = ResSendFriendChat.fromMsgPack(r.res as List);
    sc.chatMessageStorage.upsertMessage(res.message);
    return res.message;
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

  // 收到服务器主动推送的消息
  void onMsgAChatMessage(MsgAChatMessage msg, FriendInfo friendInfo) {
    ChatMessage message = msg.message;

    // 保存到本地存储（无论是谁发的，推送过来的都有 seq，直接存）
    sc.chatMessageStorage.upsertMessage(message);

    _controller.add(message);

    if (message.seq > friendInfo.receivedSeq) {
      _requestSetReceivedSeq(friendInfo.userId, message.seq);
    }
  }

  void onMessageViewed(int friendUserId, int seq) {
    final FriendInfo? friendInfo = sc.friendManager.getFriend(friendUserId);
    if (friendInfo != null && seq > friendInfo.readSeq) {
      _requestSetReadSeq(friendInfo.userId, seq);
    }
  }
}
