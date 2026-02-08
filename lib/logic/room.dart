import 'package:scene_hub/gen/a__msg_room_chat.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_get_room_chat_history.dart';
import 'package:scene_hub/gen/msg_report_room_message.dart';
import 'package:scene_hub/gen/msg_send_room_chat.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_get_room_chat_history.dart';
// import 'package:scene_hub/gen/res_report_room_message.dart';
import 'package:scene_hub/gen/room_info.dart';
import 'package:scene_hub/gen/room_message_report_reason.dart';
import 'package:scene_hub/logic/time_utils.dart';
import 'package:scene_hub/sc.dart';

enum SendingRoomChatStatus { sending, failed }

class SendingRoomChat {
  final ChatMessage message;
  final SendingRoomChatStatus status;
  SendingRoomChat(this.message, this.status);
}

class Room {
  final RoomInfo roomInfo;
  final List<ChatMessage> messages;
  final List<SendingRoomChat> sendings = [];
  Room(this.roomInfo, this.messages);

  int get roomId {
    return roomInfo.roomId;
  }

  Future<bool> sendChat(
    ChatMessageType chatMessageType,
    String content,
    int replyTo,
    int clientMessageId,
  ) async {
    final message = ChatMessage(
      messageId: 0,
      roomId: roomId,
      senderId: sc.me.userId,
      senderName: sc.me.userName,
      senderAvatar: "",
      type: chatMessageType,
      content: content,
      timestamp: TimeUtils.now(),
      replyTo: replyTo,
      senderAvatarIndex: sc.me.userInfo.avatarIndex,
      clientMessageId: clientMessageId,
    );
    final sending = SendingRoomChat(message, SendingRoomChatStatus.sending);
    sendings.add(sending);

    var msg = MsgSendRoomChat(
      roomId: roomId,
      chatMessageType: chatMessageType,
      content: content,
      clientMessageId: clientMessageId,
    );

    final r = await sc.server.request(MsgType.sendRoomChat, msg);
    sendings.remove(sending);

    if (r.e != ECode.success) {
      return false;
    }

    // final res =
    return true;
  }

  Future<bool> getChatHistory() async {
    int last = 0;
    if (messages.isNotEmpty) {
      last = messages[0].messageId;
    }
    var msg = MsgGetRoomChatHistory(roomId: roomId, lastMessageId: last);

    final r = await sc.server.request(MsgType.getRoomChatHistory, msg);
    if (r.e != ECode.success) {
      return false;
    }

    var res = ResGetRoomChatHistory.fromMsgPack(r.res!);
    messages.insertAll(0, res.history);

    return true;
  }

  Future<bool> reportRoomMessage(
    int messageId,
    RoomMessageReportReason reason,
  ) async {
    var msg = MsgReportRoomMessage(
      roomId: roomId,
      messageId: messageId,
      reason: reason,
    );

    final r = await sc.server.request(MsgType.reportRoomMessage, msg);
    if (r.e != ECode.success) {
      return false;
    }

    // final res = ResReportRoomMessage.fromMsgPack(r.res!);

    return true;
  }

  void onChatMessage(A_MsgRoomChat msg) {}
}
